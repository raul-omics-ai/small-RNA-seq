#!/bin/bash

# Help function
show_help() {
    echo "Usage: $0 -i INPUT_FASTQ_DIR -o OUTPUT_DIR -g GENOME_INDEX_NAME -s SPECIES [-f DATABASE] [-t THREADS] [-h]"
    echo "  -i INPUT_FASTQ_DIR        Path containing .fastq.gz files"
    echo "  -o OUTPUT_DIR             Output directory"
    echo "  -g GENOME_INDEX_NAME      Path and basename of the indexed reference genome"
    echo "  -s SPECIES                3-letter species code (MirGeneDB requires first letter uppercase)"
    echo "  -f DATABASE               miRNA database (mirbase or mirgenedb)"
    echo "  -t THREADS                Number of threads (default: 14)"
    echo "  -h                        Show this help message"
    exit 1
}

# Default variables
THREADS=14
mirbase_mature_fa="/home/rfernandez/mirbase/mature.fa"
mirbase_hairpin_fa="/home/rfernandez/mirbase/hairpin.fa"
mirgenedb_mature_fa="/home/rfernandez/mirgenedb/ALL-mat.fa"
mirgenedb_hairpin_fa="/home/rfernandez/mirgenedb/ALL-pre.fa"
database="mirbase"

# Parse command-line options
while getopts ":i:o:g:s:f:t:h" opt; do
    case ${opt} in
        i ) input_dir="$OPTARG" ;;
        o ) output_dir="$OPTARG" ;;
        g ) genome_index_name="$OPTARG" ;;
        s ) species="$OPTARG" ;;
        f ) database="$OPTARG" ;;
        t ) THREADS="$OPTARG" ;;
        h ) show_help ;;
        \? ) echo "Invalid option: -$OPTARG" >&2; show_help ;;
        : ) echo "Option -$OPTARG requires an argument." >&2; show_help ;;
    esac
done

# Check required arguments
if [ -z "$input_dir" ] || [ -z "$output_dir" ] || [ -z "$genome_index_name" ] || [ -z "$species" ]; then
    echo "Options -i, -o, -g and -s are required."
    show_help
fi

# Create directory structure
mkdir -p "$output_dir"
uncompress_dir="${output_dir}/uncompress_tmp"
mkdir -p "$uncompress_dir"

# Output files
config_file="${output_dir}/config.txt"
> "$config_file"
mapping_report="${output_dir}/mapping_report.txt"
> "$mapping_report"
quantifier_report="${output_dir}/quantifier_report.txt"
> "$quantifier_report"

# Uncompress FASTQ files
echo "Uncompressing FASTQ files..."
for file in "$input_dir"/*_R1_001_trimmed.fastq.gz; do
    [ -f "$file" ] || { echo "No FASTQ files found."; exit 1; }

    gunzip -c "$file" > "${uncompress_dir}/$(basename "$file" .gz)" || exit 1

    code=$(echo "$file" | grep -oE "S[0-9]{1,2}" | head -1)
    if [[ $code =~ S([0-9]+) ]]; then
        num=$(printf "%02d" "${BASH_REMATCH[1]}")
        code="S$num"
    fi

    echo -e "${code}\t${uncompress_dir}/$(basename "$file" .gz)" >> "$config_file"
done

echo "Configuration file created: $config_file"

# Change to output directory
cd "$output_dir" || exit 1

# Mapping reads
echo "Starting read mapping..."
mapper.pl "$config_file" -e -d -h -i -j -l 18 -m \
    -p "$genome_index_name" \
    -s all_samples_reads_collapsed.fa \
    -t reads_vs_genome.arf \
    -v -o "$THREADS" 2> "$mapping_report"

echo "Read mapping finished."

# Quantification
echo "Starting miRNA quantification..."

if [[ "$database" == "mirbase" ]]; then
    extract_miRNAs.pl "$mirbase_mature_fa" "$species" mature > mature_tmp.fa
    extract_miRNAs.pl "$mirbase_mature_fa" "$species" star > star_tmp.fa
    extract_miRNAs.pl "$mirbase_hairpin_fa" "$species" > hairpin_tmp.fa

    quantifier.pl -p hairpin_tmp.fa -m mature_tmp.fa \
        -r all_samples_reads_collapsed.fa \
        -s star_tmp.fa -t "$species" -y now -d 2> "$quantifier_report"
else
    extract_miRNAs.pl "$mirgenedb_mature_fa" "$species" mature > mature_tmp.fa
    extract_miRNAs.pl "$mirgenedb_hairpin_fa" "$species" > hairpin_tmp.fa

    quantifier.pl -p hairpin_tmp.fa -m mature_tmp.fa \
        -r all_samples_reads_collapsed.fa \
        -y now -d -k 2> "$quantifier_report"
fi

mv expression_now.html quality_report.html
mv miRNAs_expressed_all_samples_now.csv miRNAs_count_matrix.csv

rm -rf *_tmp*
echo "Pipeline finished successfully."


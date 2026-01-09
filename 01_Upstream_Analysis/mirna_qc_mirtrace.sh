#!/bin/bash

# Automated script to perform quality control on microRNA sequencing data.
# miRTrace QC mode characterizes each sample based on:
# - Quality profile
# - Read length distribution
# - Sequencing depth
# - miRNA complexity
# - miRNA content

# QC steps performed by miRTrace:
# 1) Removal of low-quality reads (≥50% nucleotides with PHRED < 20)
# 2) 3' adapter trimming
# 3) Removal of low-complexity reads
# 4) Removal of reads shorter than 18 nt

# Help function
show_help() {
    echo "Usage: $0 -i <input_dir> -o <output_dir> -a <adapter_seq> -s <species>"
    echo
    echo "Parameters:"
    echo "  -i   Input directory containing FASTQ.gz files"
    echo "  -o   Output directory"
    echo "  -a   Adapter sequence (default: Illumina TruSeq universal adapter)"
    echo "  -s   3-letter species code (e.g. hsa, mmu)"
    exit 1
}

# Default adapter (Illumina TruSeq)
adapter_seq="AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"

# Parse command-line arguments
while getopts "i:o:a:s:" opt; do
    case "$opt" in
        i) input_dir="$OPTARG" ;;
        o) output_dir="$OPTARG" ;;
        a) adapter_seq="$OPTARG" ;;
        s) species="$OPTARG" ;;
        *) show_help ;;
    esac
done

# Check required arguments
if [ -z "$input_dir" ] || [ -z "$output_dir" ] || [ -z "$species" ]; then
    echo "Error: missing required arguments."
    show_help
fi

# Check dependency
command -v mirtrace >/dev/null 2>&1 || {
    echo "Error: mirtrace not found in PATH."
    exit 1
}

# Create output directory
mkdir -p "$output_dir"

# Output CSV file
csv_file="$output_dir/miRTrace_samples.csv"

# Create CSV header
echo "filename,name-displayed-in-report,adapter" > "$csv_file"

# Process FASTQ files
shopt -s nullglob
fastq_files=("$input_dir"/*.fastq.gz)

if [ ${#fastq_files[@]} -eq 0 ]; then
    echo "No FASTQ files found in $input_dir"
    exit 1
fi

for fastq_file in "${fastq_files[@]}"; do
    base_name=$(basename "$fastq_file")
    name_in_report=$(echo "$base_name" | sed 's/_R1_001\.fastq\.gz//')

    echo "$fastq_file,$name_in_report,$adapter_seq" >> "$csv_file"
    echo "Processed: $fastq_file"
done

echo "CSV file generated: $csv_file"

# Run miRTrace QC
mirtrace qc \
    --species "$species" \
    -c "$csv_file" \
    --output-dir "$output_dir" \
    --force


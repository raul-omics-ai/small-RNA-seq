# miRNA Analysis Pipeline 🧬

A collection of Bash scripts for the analysis of small RNA sequencing data, with a focus on **miRNA identification and quantification** using the **miRDeep2** framework.

## 📌 Overview
This repository contains pipelines designed to:
- Process trimmed FASTQ files
- Map reads against a reference genome
- Quantify known miRNAs
- Generate count matrices and QC reports

Supported databases:
- **miRBase**
- **MirGeneDB**

## ⚙️ Dependencies
- Bash ≥ 4.0
- miRDeep2
- Bowtie
- Perl
- GNU coreutils

## 🚀 Usage
```bash
bash mirna_pipeline.sh   -i fastq_trimmed/   -o results/   -g genome_index/genome   -s Hsa   -f mirbase   -t 14
```

## 📂 Output Structure
```
results/
├── config.txt
├── mapping_report.txt
├── quantifier_report.txt
├── miRNAs_count_matrix.csv
├── quality_report.html
```

## 🧪 Tested On
- Linux (Ubuntu 20.04 / 22.04)
- miRDeep2 v2.0.1.3

## 📄 License
MIT License

## 👤 Author
Raúl Fernández  
Bioinformatician

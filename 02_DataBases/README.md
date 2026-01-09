# miRNA Reference Sequences Download Guide 🧬

This document provides instructions for downloading **mature** and **precursor (hairpin)** miRNA reference sequences from **miRBase** and **MirGeneDB**, which are required for miRNA quantification pipelines such as **miRDeep2**.

---

## 1. miRBase Reference Sequences

miRBase provides FASTA files containing mature and hairpin miRNA sequences for all supported species.

### Download

The reference files can be downloaded directly using `wget`:

```bash
# Download mature miRNA sequences
wget https://mirbase.org/download/mature.fa

# Download precursor (hairpin) miRNA sequences
wget https://mirbase.org/download/hairpin.fa
```

### Description

- `mature.fa`: Mature miRNA sequences for all species
- `hairpin.fa`: Precursor (pre-miRNA) hairpin sequences for all species

These files can later be filtered by species using tools such as `extract_miRNAs.pl` from the miRDeep2 package.

---

## 2. MirGeneDB Reference Sequences

MirGeneDB provides high-confidence, manually curated miRNA annotations.  
In this pipeline, reference sequences were downloaded directly from the MirGeneDB website.

### Download Instructions

1. Go to the official MirGeneDB download page:
   https://mirgenedb.org/download

2. Download the FASTA files containing:
   - **All mature miRNA sequences**
   - **All precursor sequences**

The downloaded files are typically named similarly to:

- `ALL-mat.fa` — mature miRNA sequences
- `ALL-pre.fa` — precursor miRNA sequences

### Description

- `ALL-mat.fa`: Mature miRNA sequences from all species in MirGeneDB
- `ALL-pre.fa`: Precursor (hairpin) miRNA sequences from all species in MirGeneDB

As with miRBase, species-specific sequences can be extracted using downstream tools.

---

## Recommended Directory Structure

```text
reference/
├── mirbase/
│   ├── mature.fa
│   └── hairpin.fa
└── mirgenedb/
    ├── ALL-mat.fa
    └── ALL-pre.fa
```

---

## Notes

- Ensure that reference files are kept unmodified to maintain compatibility with miRDeep2.
- MirGeneDB species codes may require the first letter to be uppercase (e.g., `Hsa`).
- Always check for updates on the official databases to keep reference sequences current.

---

## License and Attribution

Please cite **miRBase** or **MirGeneDB** accordingly when using these reference sequences in publications.

- miRBase: https://mirbase.org
- MirGeneDB: https://mirgenedb.org

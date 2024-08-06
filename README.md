# tcga-wgs-kraken-microbial-quant

A Kraken2 + Bracken based pipeline for classifying and quantifying
microbial reads from GDC TCGA WGS data.

Feature highlights:

- Supports Kraken2 or KrakenUniq for read classification.
- Supports HISAT2 or Bowtie2 for host filtering.
- Automatically builds the latest MicrobialDB nucleotide and protein
  Kraken2 databases (or for KrakenUniq nucleotide only). MicrobialDB
  consists of archaea, bacteria, viral, human, UniVec_Core, and
  eukaryotic pathogen genomes (EuPathDBv54) with contaminants removed.
- Includes the option to do a second pass Kraken2 protein translated
  search of the unclassified reads from the Kraken2 first pass and
  combining the report results before feeding into Bracken.
- Properly handles TCGA WGS merged BAMs with mixed PE/SE reads and
  multiple read lengths by splitting them into read group level FASTQs
  and processing data through the pipeline at read group level before
  aggregating the Bracken count results back to GDC BAM level.

See [References](#references) for the general basis for this pipeline
and more information.

A high-level pipeline summary:

```
GDC TCGA WGS Unmapped Read BAMs
Biobambam2 Unmapped Read FASTQs (split by read group when BAM has mixed PE/SE or read lengths)
HISAT2 (or Bowtie2) Host Filtering (with T2T-CHM13v2.0)
Kraken2 (or KrakenUniq) Nucleotide Read Classification (with MicrobialDB)
Kraken2 Translated Search Read Classification of Unclassified Reads (with protein MicrobialDB)
KrakenTools Combine Nucleotide and Protein Reports
Bracken Read Quantification
Aggregate Read Group Level Counts/Abundances
Count/Abundance Matrix
```

## Workflow

![Snakemake rule graph](tcga-wgs-kraken-microbial-quant.svg)

## Prerequisites

The project was developed under GNU Linux and MacOS X and assumes the
use of a Unix command line shell. Both Linux and MacOS provide a
command line shell by default. Other needed tools will be installed
by the instructions below.

## Installation

Install and set up
[Miniforge3](https://github.com/conda-forge/miniforge#download)

Obtain the project source and create a conda environment with the tools
needed to run the project:

```bash
git clone https://github.com/hermidalc/tcga-wgs-kraken-microbial-quant.git
cd tcga-wgs-kraken-microbial-quant
mamba env create -f envs/tcga-wgs-kraken-microbial-quant.yaml
mamba activate tcga-wgs-kraken-microbial-quant
```

Test that the installation is working by doing a dry run (if you don't
have a GDC token yet and wish to test your install do
`GDC_TOKEN='' snakemake --dry-run`). Below are the job statistics you
would see for an analysis of all TCGA WGS primary tumors using Kraken2
with the optional addtional step of Kraken2 protein translated search of
unclassified reads:

```
$ snakemake --dry-run

Building DAG of jobs...
Job stats:
job                             count
----------------------------  -------
all                                 1
bracken_count_matrix                1
bracken_db                          7
bracken_merged_counts              82
bracken_read_quant              13955
eupathdb_fasta_archive              1
eupathdb_fastas                     1
eupathdb_merged_fasta               1
eupathdb_seqid2taxid_map            1
gdc_unmapped_bam                10838
gdc_unmapped_fastq_pe           13531
gdc_unmapped_fastq_se             424
host_filtered_fastq_pe          13531
host_filtered_fastq_se            424
host_genome_fasta                   1
host_genome_index                   1
kraken2_combined_report         13955
kraken2_db                          2
kraken2_db_taxonomy                 2
kraken2_eupathdb_library            1
kraken2_nucl_db_library             5
kraken2_nucl_read_classif_pe    13531
kraken2_nucl_read_classif_se      424
kraken2_prot_db_library             4
kraken2_prot_read_classif_pe    13531
kraken2_prot_read_classif_se      424
total                           94679
```

## Execution

Given the compute intensive nature of this pipeline and the large
number of jobs required to execute it we highly recommend running it
on an HPC cluster.

Set your GDC controlled access authentication token in the environment
variable `GDC_TOKEN` or `GDC_TOKEN_FILE`, or the file `~/.gdc_token`
so the pipeline can get the token.

Run the workflow:

```bash
snakemake
```

Run the workflow on a cluster:

```bash
snakemake --workflow-profile workflow/profiles/biowulf
```

I've provided a SLURM cluster configuration for the NIH HPC cluster,
though it is straightforward to create a Snakemake cluster config for
your particular needs.

The pipeline is configured to not require much storage, as intermediate
files are flagged as temporary and deleted when they are no longer
needed as the pipeline is running, except for Bracken outputs. If you
would like to keep intermediate files for other uses, specifiy the
`--notemp` snakemake option in the execution command above.

## References

1. Lu et al. [Metagenome analysis using the Kraken software suite](
    https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9725748/).
Nat Protoc. 2022 Dec;17(12):2815-2839. doi: 10.1038/s41596-022-00738-y
2. Ge et al. [Comprehensive analysis of microbial content in whole-genome
sequencing samples from The Cancer Genome Atlas project](
    https://doi.org/10.1101/2024.05.24.595788). bioRxiv 2024.05.24.595788

rule bowtie2_chm13_index:
    input:
        ref=CHM13_FASTQ_FILE,
    output:
        idx=multiext(
            BOWTIE2_CHM13_INDEX,
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        UNMAPPED_FASTQ_LOG,
    threads: BOWTIE2_BUILD_THREADS
    wrapper:
        BOWTIE2_BUILD_WRAPPER


rule bowtie2_unmapped_sam:
    input:
        sample=UNMAPPED_FASTQ_FILE,
        idx=multiext(
            BOWTIE2_CHM13_INDEX,
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    output:
        unaligned=BOWTIE2_UNMAPPED_SAM_FILE,
    log:
        BOWTIE2_UNMAPPED_SAM_LOG,
    threads: BOWTIE2_ALIGN_THREADS
    wrapper:
        BOWTIE2_ALIGN_WRAPPER

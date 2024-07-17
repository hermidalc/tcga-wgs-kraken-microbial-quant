rule gdc_unmapped_bam:
    params:
        token=config["input"]["gdc"]["token"],
        bam_id="{bam_id}",
    output:
        GDC_UNMAPPED_BAM_FILE,
    log:
        GDC_UNMAPPED_BAM_LOG,
    retries: config["download"]["retries"]
    script:
        "../scripts/gdc_unmapped_bam.py"


rule gdc_unmapped_fastq_pe:
    input:
        GDC_UNMAPPED_BAM_FILE,
    params:
        outdir=lambda wc: GDC_FILE_RESULTS_DIR if wc.method == "rg" else None,
        paired_end=True,
        per_readgrp=lambda wc: True if wc.method == "rg" else False,
        extra=lambda wc: (
            (
                f"{config['biobambam2']['bamtofastq']['extra']['common']} "
                f"{config['biobambam2']['bamtofastq']['extra']['paired_end']}"
                f"{config['biobambam2']['bamtofastq']['extra']['per_readgrp']}"
            )
            if wc.method == "rg"
            else (
                f"{config['biobambam2']['bamtofastq']['extra']['common']} "
                f"{config['biobambam2']['bamtofastq']['extra']['paired_end']}"
            )
        ),
    output:
        GDC_UNMAPPED_FASTQ_R1_FILE,
        GDC_UNMAPPED_FASTQ_R2_FILE,
        temp(GDC_UNMAPPED_FASTQ_O1_FILE),
        temp(GDC_UNMAPPED_FASTQ_O2_FILE),
    log:
        GDC_UNMAPPED_FASTQ_LOG,
    wrapper:
        BIOBAMBAM2_BAMTOFASTQ_WRAPPER


rule gdc_unmapped_fastq_se:
    input:
        GDC_UNMAPPED_BAM_FILE,
    params:
        outdir=lambda wc: GDC_FILE_RESULTS_DIR if wc.method == "rg" else None,
        paired_end=False,
        per_readgrp=lambda wc: True if wc.method == "rg" else False,
        extra=lambda wc: (
            (
                f"{config['biobambam2']['bamtofastq']['extra']['common']} "
                f"{config['biobambam2']['bamtofastq']['extra']['per_readgrp']}"
            )
            if wc.method == "rg"
            else config["biobambam2"]["bamtofastq"]["extra"]["common"]
        ),
    output:
        GDC_UNMAPPED_FASTQ_SE_FILE,
    log:
        GDC_UNMAPPED_FASTQ_LOG,
    wrapper:
        BIOBAMBAM2_BAMTOFASTQ_WRAPPER

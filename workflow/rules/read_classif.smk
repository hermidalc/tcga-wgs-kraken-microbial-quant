rule kraken2_svc_db:
    input:
        KRAKEN2_DB_DONE_FILE,
    params:
        db=KRAKEN2_DB_DIR,
        remote_dir=config["resources"]["db"]["svc"]["remote_dir"],
    output:
        temp(directory(KRAKEN2_SVC_DB_DIR)),
    log:
        KRAKEN2_SVC_DB_LOG,
    localrule: True
    shell:
        """
        if [[ -v SLURM_JOB_ID ]]; then
            if [[ ! -d "{params.remote_dir}/$SLURM_JOB_ID" ]]; then
                echo "{params.remote_dir}/$SLURM_JOB_ID doesn't exist" > log 2>&1
                exit 1
            fi
            SERVICE_DB_DIR={params.remote_dir}/$SLURM_JOB_ID/{params.db}
        else
            SERVICE_DB_DIR={output[0]}
        fi
        if [[ -d "$SERVICE_DB_DIR" ]]; then
            echo "$SERVICE_DB_DIR already exists!" > log 2>&1
            exit 1
        fi
        mkdir -pv $SERVICE_DB_DIR > {log} 2>&1
        cp -avf {params.db}/*.k2d $SERVICE_DB_DIR/ >> {log} 2>&1
        """


rule kraken2_nucl_read_classif_pe:
    input:
        fqs=[HOST_FILTERED_FASTQ_R1_FILE, HOST_FILTERED_FASTQ_R2_FILE],
        # db_done=KRAKEN2_NUCL_DB_DONE_FILE,
        db=KRAKEN2_NUCL_SVC_DB_DIR,
    params:
        db=KRAKEN2_NUCL_DB_DIR,
        output="-",
        paired_end=True,
        memory_mapping=True,
        extra=(
            f"{config['kraken2']['classify']['extra']['paired_end']} "
            f"{config['kraken2']['classify']['extra']['common']}"
        ),
    output:
        # classif=[
        #     temp(KRAKEN2_NUCL_CLASSIF_FASTQ_R1_FILE),
        #     temp(KRAKEN2_NUCL_CLASSIF_FASTQ_R2_FILE),
        # ],
        unclassif=[
            temp(KRAKEN2_NUCL_UNCLASSIF_FASTQ_R1_FILE),
            temp(KRAKEN2_NUCL_UNCLASSIF_FASTQ_R2_FILE),
        ],
        # output=KRAKEN2_NUCL_OUTPUT_PE_FILE,
        report=KRAKEN2_NUCL_REPORT_PE_FILE,
    log:
        KRAKEN2_NUCL_CLASSIFY_PE_LOG,
    localrule: True
    threads: KRAKEN2_CLASSIFY_THREADS
    wrapper:
        KRAKEN2_CLASSIFY_WRAPPER


rule kraken2_nucl_read_classif_se:
    input:
        fqs=HOST_FILTERED_FASTQ_SE_FILE,
        # db_done=KRAKEN2_NUCL_DB_DONE_FILE,
        db=KRAKEN2_NUCL_SVC_DB_DIR,
    params:
        db=KRAKEN2_NUCL_DB_DIR,
        output="-",
        paired_end=False,
        memory_mapping=True,
        extra=config["kraken2"]["classify"]["extra"]["common"],
    output:
        # classif=temp(KRAKEN2_NUCL_CLASSIF_FASTQ_SE_FILE),
        unclassif=temp(KRAKEN2_NUCL_UNCLASSIF_FASTQ_SE_FILE),
        # output=KRAKEN2_NUCL_OUTPUT_SE_FILE,
        report=KRAKEN2_NUCL_REPORT_SE_FILE,
    log:
        KRAKEN2_NUCL_CLASSIFY_SE_LOG,
    localrule: True
    threads: KRAKEN2_CLASSIFY_THREADS
    wrapper:
        KRAKEN2_CLASSIFY_WRAPPER


rule kraken2_prot_read_classif_pe:
    input:
        fqs=[
            KRAKEN2_NUCL_UNCLASSIF_FASTQ_R1_FILE,
            KRAKEN2_NUCL_UNCLASSIF_FASTQ_R2_FILE,
        ],
        # db_done=KRAKEN2_PROT_DB_DONE_FILE,
        db=KRAKEN2_PROT_SVC_DB_DIR,
    params:
        db=KRAKEN2_PROT_DB_DIR,
        output="-",
        paired_end=True,
        memory_mapping=True,
        extra=(
            f"{config['kraken2']['classify']['extra']['paired_end']} "
            f"{config['kraken2']['classify']['extra']['common']}"
        ),
    output:
        # classif=[
        #     temp(KRAKEN2_PROT_CLASSIF_FASTQ_R1_FILE),
        #     temp(KRAKEN2_PROT_CLASSIF_FASTQ_R2_FILE),
        # ],
        # unclassif=[
        #     temp(KRAKEN2_PROT_UNCLASSIF_FASTQ_R1_FILE),
        #     temp(KRAKEN2_PROT_UNCLASSIF_FASTQ_R2_FILE),
        # ],
        # output=KRAKEN2_PROT_OUTPUT_PE_FILE,
        report=KRAKEN2_PROT_REPORT_PE_FILE,
    log:
        KRAKEN2_PROT_CLASSIFY_PE_LOG,
    localrule: True
    threads: KRAKEN2_CLASSIFY_THREADS
    wrapper:
        KRAKEN2_CLASSIFY_WRAPPER


rule kraken2_prot_read_classif_se:
    input:
        fqs=KRAKEN2_NUCL_UNCLASSIF_FASTQ_SE_FILE,
        # db_done=KRAKEN2_PROT_DB_DONE_FILE,
        db=KRAKEN2_PROT_SVC_DB_DIR,
    params:
        db=KRAKEN2_PROT_DB_DIR,
        output="-",
        paired_end=False,
        memory_mapping=True,
        extra=config["kraken2"]["classify"]["extra"]["common"],
    output:
        # classif=temp(KRAKEN2_PROT_CLASSIF_FASTQ_SE_FILE),
        # unclassif=temp(KRAKEN2_PROT_UNCLASSIF_FASTQ_SE_FILE),
        # output=KRAKEN2_PROT_OUTPUT_SE_FILE,
        report=KRAKEN2_PROT_REPORT_SE_FILE,
    log:
        KRAKEN2_PROT_CLASSIFY_SE_LOG,
    localrule: True
    threads: KRAKEN2_CLASSIFY_THREADS
    wrapper:
        KRAKEN2_CLASSIFY_WRAPPER


rule krakenuniq_read_classif_pe:
    input:
        fqs=[HOST_FILTERED_FASTQ_R1_FILE, HOST_FILTERED_FASTQ_R2_FILE],
        db_done=KRAKENUNIQ_DB_DONE_FILE,
    params:
        db=KRAKENUNIQ_DB_DIR,
        output="off",
        paired_end=True,
        extra=(
            f"{config['krakenuniq']['classify']['extra']['paired_end']} "
            f"{config['krakenuniq']['classify']['extra']['common']}"
        ),
    output:
        # classif=[
        #     temp(KRAKENUNIQ_CLASSIF_FASTQ_R1_FILE),
        #     temp(KRAKENUNIQ_CLASSIF_FASTQ_R2_FILE),
        # ],
        unclassif=[
            temp(KRAKENUNIQ_UNCLASSIF_FASTQ_R1_FILE),
            temp(KRAKENUNIQ_UNCLASSIF_FASTQ_R2_FILE),
        ],
        # output=KRAKENUNIQ_OUTPUT_PE_FILE,
        report=KRAKENUNIQ_REPORT_PE_FILE,
    log:
        KRAKENUNIQ_CLASSIFY_PE_LOG,
    localrule: True
    threads: KRAKENUNIQ_CLASSIFY_THREADS
    wrapper:
        KRAKENUNIQ_CLASSIFY_WRAPPER


rule krakenuniq_read_classif_se:
    input:
        fqs=HOST_FILTERED_FASTQ_SE_FILE,
        db_done=KRAKENUNIQ_DB_DONE_FILE,
    params:
        db=KRAKENUNIQ_DB_DIR,
        output="off",
        paired_end=False,
        extra=config["krakenuniq"]["classify"]["extra"]["common"],
    output:
        # classif=temp(KRAKENUNIQ_CLASSIF_FASTQ_SE_FILE),
        unclassif=temp(KRAKENUNIQ_UNCLASSIF_FASTQ_SE_FILE),
        # output=KRAKENUNIQ_OUTPUT_SE_FILE,
        report=KRAKENUNIQ_REPORT_SE_FILE,
    log:
        KRAKENUNIQ_CLASSIFY_SE_LOG,
    localrule: True
    threads: KRAKENUNIQ_CLASSIFY_THREADS
    wrapper:
        KRAKENUNIQ_CLASSIFY_WRAPPER

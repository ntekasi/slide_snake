# fastqc before trimming
rule ont_readQC_preCutadapt:
    input:
        FQ="{OUTDIR}/{SAMPLE}/tmp/ont/adapter_scan_readids/merged_adapter_{READ}.fq.gz",
    output:
        TSV="{OUTDIR}/{SAMPLE}/ont/readqc/1_preCutadapt/{READ}_qc.tsv",  #TODO compress this?
    params:
        CHUNK_SIZE=500000        
    log:
        log="{OUTDIR}/{SAMPLE}/ont/readqc/1_preCutadapt/{READ}_qc.log",
    threads: config["CORES"]
    shell:
        """
        python scripts/py/fastq_read_qc.py \
            {input.FQ} \
            {output.TSV} \
            --threads {threads} \
            --chunk_size {params.CHUNK_SIZE} \
        2>&1 | tee {log.log}
        """


# fastqc after cutadapt trimming
rule ont_readQC_postCutadapt:
    input:
        FQ="{OUTDIR}/{SAMPLE}/tmp/ont/cut_{READ}.fq.gz",
    output:
        TSV="{OUTDIR}/{SAMPLE}/ont/readqc/2_postCutadapt/{READ}_qc.tsv",
    params:
        CHUNK_SIZE=500000     
    log:
        log="{OUTDIR}/{SAMPLE}/ont/readqc/2_postCutadapt/{READ}_qc.log",
    threads: config["CORES"]
    shell:
        """
        python scripts/py/fastq_read_qc.py \
            {input.FQ} \
            {output.TSV} \
            --threads {threads} \
            --chunk_size {params.CHUNK_SIZE} \
        2>&1 | tee {log.log}
        """


# ┌────┬──────┬───────────────────────────────────────────────────────┐
# │Tag │ Type │                      Description                      │
# ├────┼──────┼───────────────────────────────────────────────────────┤
# │ tp │  A   │ Type of aln: P/primary, S/secondary and I,i/inversion │
# │ cm │  i   │ Number of minimizers on the chain                     │
# │ s1 │  i   │ Chaining score                                        │
# │ s2 │  i   │ Chaining score of the best secondary chain            │
# │ NM │  i   │ Total number of mismatches and gaps in the alignment  │
# │ MD │  Z   │ To generate the ref sequence in the alignment         │
# │ AS │  i   │ DP alignment score                                    │
# │ ms │  i   │ DP score of the max scoring segment in the alignment  │
# │ nn │  i   │ Number of ambiguous bases in the alignment            │
# │ ts │  A   │ Transcript strand (splice mode only)                  │
# │ cg │  Z   │ CIGAR string (only in PAF)                            │
# │ cs │  Z   │ Difference string                                     │
# └────┴──────┴───────────────────────────────────────────────────────┘
rule readQC_bam:
    input:
        BAM="{OUTDIR}/{SAMPLE}/ont/minimap2/{RECIPE}/sorted_bc_corrected.bam",
        BAI="{OUTDIR}/{SAMPLE}/ont/minimap2/{RECIPE}/sorted_bc_corrected.bam.bai",
    output:
        TSV="{OUTDIR}/{SAMPLE}/ont/readqc/3_aligned/bam_qc.tsv",
    params:
        TAGS="AS NM GN",
        CHUNK_SIZE=500000,
    log:
        log="{OUTDIR}/{SAMPLE}/ont/readqc/3_aligned/bam_qc.log",
    threads: config["CORES"]
    shell:
        """
        python scripts/py/bam_read_qc.py \
            --tags {params.TAGS} \
            --chunk-size {params.CHUNK_SIZE} \
            --bam_file {input.BAM} \
            --tsv_file {output.TSV} \
        2>&1 | tee {log.log}
        """


# Grab the first million reads...
rule readQC_downsample:
    input:
        TSV="{OUTDIR}/{SAMPLE}/ont/readqc/3_aligned/bam_qc.tsv",
    output:
        TSV="{OUTDIR}/{SAMPLE}/ont/readqc/3_aligned/bam_qc_500000.tsv",
    threads: 1
    shell:
        """
        head -n 5000000 {input.TSV} > {output.TSV} 
        """

# Summary plot
rule ont_readQC_summaryplot:
    input:
        TSV="{OUTDIR}/{SAMPLE}/ont/readqc/{CUT}/{READ}_qc_500000.tsv",
    output:
        IMG="{OUTDIR}/{SAMPLE}/ont/readqc/{CUT}/{READ}_qc_500000.png",
    threads: 1
    conda:
        f"{workflow.basedir}/envs/ggplot2.yml"
    shell:
        """
        Rscript scripts/R/readqc_summary.R -f {input.TSV} -o {output.IMG}
        """

# QC on STAR outputs
## qualimap on deduplicated/aligned reads
rule qualimapQC_STAR:
    input:
        SORTEDBAM="{OUTDIR}/{SAMPLE}/STARsolo/short_read/{RECIPE}/Aligned.sortedByCoord.out.bam",
    output:
        TXT="{OUTDIR}/{SAMPLE}/qualimap/STAR/{RECIPE}/rnaseq_qc_results.txt",
        HTML="{OUTDIR}/{SAMPLE}/qualimap/STAR/{RECIPE}/qualimapReport.html",
    params:
        GENES_GTF=lambda wildcards: GTF_DICT[wildcards.SAMPLE],
    resources:
        threads=1,
        mem="32G",
    conda:
        f"{workflow.basedir}/envs/qualimap.yml"
    shell:
        """
        mkdir -p $(dirname {output.TXT})

        qualimap rnaseq \
            -bam {input.SORTEDBAM} \
            -gtf {params.GENES_GTF} \
            --sequencing-protocol strand-specific-forward \
            --sorted \
            --java-mem-size={resources.mem} \
            -outdir $(dirname {output.TXT}) \
            -outformat html
        """


rule qualimap_summary2csv_STAR:
    input:
        TXT="{OUTDIR}/{SAMPLE}/qualimap/STAR/{RECIPE}/rnaseq_qc_results.txt",
    output:
        CSV="{OUTDIR}/{SAMPLE}/qualimap/STAR/{RECIPE}/rnaseq_qc_result.csv",
    resources:
        threads=1,
    shell:
        """
        python scripts/py/qualimap_summary2csv.py {input.TXT} {output.CSV}
        """

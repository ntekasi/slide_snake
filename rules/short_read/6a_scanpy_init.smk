# initialize & cache the **raw** counts as an anndata file for easier loading later
## Removes barcodes for which there are no molecules detected [`--remove_zero_features`]


# STAR outputs
rule ilmn_6a_cache_preQC_h5ad_STAR:
    input:
        BCS="{OUTDIR}/{SAMPLE}/short_read/STARsolo/{RECIPE}/Solo.out/{SOLO}/raw/barcodes.tsv.gz",
        FEATS="{OUTDIR}/{SAMPLE}/short_read/STARsolo/{RECIPE}/Solo.out/{SOLO}/raw/features.tsv.gz",
        MAT="{OUTDIR}/{SAMPLE}/short_read/STARsolo/{RECIPE}/Solo.out/{SOLO}/raw/{ALGO}.mtx.gz",
        BC_map=lambda w: get_bc_map(w, mode="ILMN"),
    output:
        H5AD="{OUTDIR}/{SAMPLE}/short_read/STARsolo/{RECIPE}/Solo.out/{SOLO}/raw/{ALGO}.h5ad",
        QC_PLOTS="{OUTDIR}/{SAMPLE}/short_read/STARsolo/{RECIPE}/Solo.out/{SOLO}/raw/{ALGO}.h5ad.qc_plots.png",
    params:
        var_names="gene_symbols",  # scanpy.read_10x_mtx()
    threads: 1
    log:
        log="{OUTDIR}/{SAMPLE}/short_read/STARsolo/{RECIPE}/Solo.out/{SOLO}/raw/{ALGO}_cache.log",
        err="{OUTDIR}/{SAMPLE}/short_read/STARsolo/{RECIPE}/Solo.out/{SOLO}/raw/{ALGO}_cache.err",
    conda:
        f"{workflow.basedir}/envs/scanpy.yml"
    shell:
        """
        python scripts/py/cache_mtx_to_h5ad.py \
            --mat_in {input.MAT} \
            --feat_in {input.FEATS} \
            --bc_in {input.BCS} \
            --bc_map {input.BC_map} \
            --ad_out {output.H5AD} \
            --feat_col 1 0 \
            --transpose True \
            --remove_zero_features \
            --plot_qc \
            --qc_plot_file {output.QC_PLOTS} \
        1> {log.log} \
        2> {log.err}
        """

# kallisto/bustools outputs
rule cache_preQC_h5ad_kbpython_std:
    input:
        # BCS="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/cells_x_genes.barcodes.txt.gz",
        # FEATS="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/cells_x_genes.genes.txt.gz",
        # MAT="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/cells_x_genes.mtx.gz",
        BCS="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/cellranger/barcodes_noSuffix.tsv.gz",
        FEATS="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/cellranger/genes.tsv.gz",
        MAT="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/cellranger/matrix.mtx.gz",
        BC_map="{OUTDIR}/{SAMPLE}/bc/map_underscore.txt",
    output:
        H5AD="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/output.h5ad",
        QC_PLOTS="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/qc_plots.png",
    log:
        log="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/cache.log",
        err="{OUTDIR}/{SAMPLE}/short_read/kbpython_std/{RECIPE}/counts_unfiltered/cache.err",
    # params:
    #     var_names = "gene_symbols" # scanpy.read_10x_mtx()
    threads: 1
    conda:
        f"{workflow.basedir}/envs/scanpy.yml"
    shell:
        """
        python scripts/py/cache_mtx_to_h5ad.py \
            --mat_in {input.MAT} \
            --feat_in {input.FEATS} \
            --bc_in {input.BCS} \
            --bc_map {input.BC_map} \
            --ad_out {output.H5AD} \
            --feat_col 0 \
            --transpose True \
            --remove_zero_features \
            --plot_qc \
            --qc_plot_file {output.QC_PLOTS} \
        1> {log.log} \
        2> {log.err}
        """


# initialize & cache the **raw** counts as an anndata file for easier loading later
## Removes barcodes for which there are no molecules detected [`--remove_zero_features`]
# rule cache_preQC_h5ad_kb:
#     input:
#         BCS="{OUTDIR}/{SAMPLE}/kb/{RECIPE}/raw/output.barcodes.txt.gz",
#         FEATS="{OUTDIR}/{SAMPLE}/kb/{RECIPE}/raw/output.genes.txt.gz",
#         MAT="{OUTDIR}/{SAMPLE}/kb/{RECIPE}/raw/output.mtx.gz",
#         BC_map="{OUTDIR}/{SAMPLE}/bc/whitelist_underscore.txt",
#     output:
#         H5AD="{OUTDIR}/{SAMPLE}/kb/{RECIPE}/raw/output.h5ad",
#     log:
#         log="{OUTDIR}/{SAMPLE}/kb/{RECIPE}/raw/cache.log",
#     # params:
#     #     var_names = "gene_symbols" # scanpy.read_10x_mtx()
#     threads: 1
#     conda:
#         f"{workflow.basedir}/envs/scanpy.yml"
#     shell:
#         """
#         python scripts/py/cache_mtx_to_h5ad.py \
#             --mat_in {input.MAT} \
#             --feat_in {input.FEATS} \
#             --bc_in {input.BCS} \
#             --bc_map {input.BC_map} \
#             --ad_out {output.H5AD} \
#             --feat_col 0 \
#             --remove_zero_features \
#         1> {log.log}
#         """

rule plot_qc_metrics:
    input:
        H5AD="{OUTDIR}/{SAMPLE}/short_read/{TOOL}/{RECIPE}/counts_unfiltered/output.h5ad",
    output:
        TOTAL_COUNTS="{OUTDIR}/{SAMPLE}/short_read/{TOOL}/{RECIPE}/counts_unfiltered/total_counts_per_cell.png",
        NUMBER_GENES="{OUTDIR}/{SAMPLE}/short_read/{TOOL}/{RECIPE}/counts_unfiltered/number_of_genes_per_cell.png",
        SPATIAL_COUNTS="{OUTDIR}/{SAMPLE}/short_read/{TOOL}/{RECIPE}/counts_unfiltered/spatial_map_total_counts.png",
        SPATIAL_GENES="{OUTDIR}/{SAMPLE}/short_read/{TOOL}/{RECIPE}/counts_unfiltered/spatial_map_number_of_genes.png",
    log:
        log="{OUTDIR}/{SAMPLE}/short_read/{TOOL}/{RECIPE}/counts_unfiltered/plot_qc_metrics.log",
        err="{OUTDIR}/{SAMPLE}/short_read/{TOOL}/{RECIPE}/counts_unfiltered/plot_qc_metrics.err",
    conda:
        f"{workflow.basedir}/envs/scanpy.yml"
    shell:
        """
        python scripts/py/plot_qc_metrics.py \
            --h5ad_in {input.H5AD} \
            --output_dir {output_dir} \
        1> {log.log} \
        2> {log.err}
        """

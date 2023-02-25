# SPlit the bead barcodes and save whitelists
rule splitBBList:
    input:
        BB_map = lambda wildcards: BB_DICT[wildcards.sample]
    output:
        BB = "{OUTDIR}/{sample}/bb/whitelist.txt",
        BB_1 = "{OUTDIR}/{sample}/bb/whitelist_1.txt",
        BB_2 = "{OUTDIR}/{sample}/bb/whitelist_2.txt"
    run:
        #load bb
        bb_df = pd.read_csv(input.BB_map, sep="\t", header=None).iloc[:,0]

        # split for 2 separate barcodes
        bb_1 = pd.DataFrame(bb[0:8] for bb in list(bb_df.values))
        bb_2 = pd.DataFrame(bb[8:14] for bb in list(bb_df.values))

        # save bb files in {sample}/bb
        bb_df.to_csv(output.BB, sep="\t", header=False, index=False) # Full bead barcode
        bb_1.to_csv(output.BB_1, sep="\t", header=False, index=False) # Bead barcode #1
        bb_2.to_csv(output.BB_2, sep="\t", header=False, index=False) # Bead Barcode #2

# Insert the adapter sequence into the bead barcodes for easier barcode matching/alignment with STARsolo
rule insert_adapter_BB_list:
    input:
        BB_map = lambda wildcards: BB_DICT[wildcards.sample]
    output:
        BB = "{OUTDIR}/{sample}/bb/whitelist_adapter.txt"
    params:
        ADAPTER = config["R1_INTERNAL_ADAPTER"] # Curio R1 internal adapter
    run:
        #load bb
        bb_df = pd.read_csv(input.BB_map, sep="\t", header=None).iloc[:,0]

        # split for 2 separate barcodes
        bb_1 = pd.DataFrame(bb[0:8] for bb in list(bb_df.values))
        bb_2 = pd.DataFrame(bb[8:14] for bb in list(bb_df.values))

        # Stitch bb_1, adapter, and bb_2
        bb_adapter = bb_1 + params.ADAPTER + bb_2

        # save bb files in {sample}/bb
        bb_adapter.to_csv(output.BB, sep="\t", header=False, index=False) 
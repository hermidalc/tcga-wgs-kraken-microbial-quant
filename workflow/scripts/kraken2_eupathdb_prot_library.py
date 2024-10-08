import re
from contextlib import redirect_stdout, redirect_stderr

import pandas as pd

fasta_organism_regex = re.compile(
    r"\s*\|\s*organism=(.+?)\s*\|\s*", flags=re.IGNORECASE
)
with open(snakemake.log[0], "wt") as log_fh:
    with redirect_stdout(log_fh), redirect_stderr(log_fh):
        with open(snakemake.input.fasta, "rt") as fa_ifh:
            with open(snakemake.output.idmap, "wt") as id_ofh:
                with open(snakemake.output.fasta, "wt") as fa_ofh:
                    skipped_organisms = []
                    meta_df = pd.read_csv(
                        snakemake.input.meta, sep="\t", index_col="Organism"
                    )
                    for line in fa_ifh:
                        line = line.strip()
                        if line[0] == ">":
                            skip = False
                            organism = re.findall(fasta_organism_regex, line)
                            organism = organism[0].strip().replace("_", " ")
                            if organism in meta_df.index.values:
                                line_parts = re.split(r"\s*\|\s*", line)
                                seqid = line_parts[0].lstrip(">")
                                taxid = meta_df.loc[organism, "Species NCBI taxon ID"]
                                id_ofh.write(
                                    f"TAXID\tkraken:taxid|{taxid}|{seqid}\t{taxid}\n"
                                )
                                line = f">kraken:taxid|{taxid}|{seqid}"
                            else:
                                if organism not in skipped_organisms:
                                    log_fh.write(
                                        f"{organism} metadata not found, skipping\n"
                                    )
                                    skipped_organisms.append(organism)
                                skip = True
                        if not skip:
                            fa_ofh.write(f"{line}\n")

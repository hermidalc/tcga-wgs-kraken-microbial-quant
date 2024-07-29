__author__ = "Leandro C. Hermida"
__email__ = "leandro@leandrohermida.com"
__license__ = "BSD 3-Clause"

import re

from snakemake.shell import shell

log = snakemake.log_fmt_shell(stdout=True, stderr=True, append=True)

db = snakemake.params.get("db")
assert db is not None, "params: db is a required parameter"

task = snakemake.params.get("task")
assert task is not None, "params: task is a required parameter"
assert task in (
    "download-taxonomy",
    "download-library",
    "build",
), "params: invalid task"
if task == "download-library":
    lib = snakemake.params.get("lib")
    assert (
        lib is not None
    ), "params: lib is a required parameter when task=download-library"
    task = f"{task} {lib}"
task = f"--{task}"

extra = snakemake.params.get("extra", "")
protein = snakemake.params.get("protein")
if protein:
    extra = f"--protein {extra}"
use_ftp = snakemake.params.get("use_ftp")
if use_ftp:
    extra = f"--use-ftp {extra}"

# workaround for Kraken2 issue with --download-library human
kraken2_build = (
    "yes y | kraken2-build"
    if task == "download-library" and lib == "human"
    else "kraken2-build"
)

shellcmd = (
    f"{kraken2_build}"
    f" {task}"
    f" --db {db}"
    f" --threads {snakemake.threads}"
    f" {extra}"
    f" {log}"
)
shellcmd = re.sub(r"\s+", " ", shellcmd)
with open(snakemake.log[0], "wt") as log_fh:
    log_fh.write(f"{shellcmd}\n")

shell(shellcmd)

__author__ = "Leandro C. Hermida"
__email__ = "leandro@leandrohermida.com"
__license__ = "MIT"

import re

from snakemake.shell import shell

log = snakemake.log_fmt_shell(stdout=True, stderr=True, append=True)

k2 = snakemake.params.get("k2")
assert k2 is not None, "params: k2 path is a required parameter"

db = snakemake.params.get("db")
assert db is not None, "params: db is a required parameter"

task = snakemake.params.get("task")
assert task is not None, "params: task is a required parameter"
assert task in (
    "download-taxonomy",
    "download-library",
    "build",
), "params: invalid/not yet supported task"
if task == "download-library":
    lib = snakemake.params.get("lib")
    assert (
        lib is not None
    ), "params: lib is a required parameter when task=download-library"
    task = f"{task} {lib}"

extra = snakemake.params.get("extra", "")
protein = snakemake.params.get("protein")
if protein:
    extra = f"--protein {extra}"

if task in ("download-library", "build"):
    # workaround for snakemake bug *_NUM_THREADS env vars not passed to wrapper shell()
    k2 = f"OMP_NUM_THREADS={snakemake.threads} {k2}"
    extra = f"--threads {snakemake.threads} {extra}"

shellcmd = f"{k2} {task} --db {db} {extra} {log}"
shellcmd = re.sub(r"\s+", " ", shellcmd)
with open(snakemake.log[0], "wt") as log_fh:
    log_fh.write(f"{shellcmd}\n")

shell(shellcmd)

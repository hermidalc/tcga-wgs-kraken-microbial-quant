__author__ = "Leandro C. Hermida"
__email__ = "leandro@leandrohermida.com"
__license__ = "BSD 3-Clause"

from snakemake.shell import shell

log = snakemake.log_fmt_shell(stdout=True, stderr=True)

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
if protein is not None:
    extra = f"--protein {extra}"

# workaround for Kraken2 issue with --download-library human
kraken2_build = (
    "yes y | kraken2-build"
    if task == "download-library" and lib == "human"
    else "kraken2-build"
)

shell(
    "{kraken2_build}"
    " {task}"
    " --db {db}"
    " --threads {snakemake.threads}"
    " {extra}"
    " {log}"
)

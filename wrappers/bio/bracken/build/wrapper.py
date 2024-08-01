__author__ = "Leandro C. Hermida"
__email__ = "leandro@leandrohermida.com"
__license__ = "MIT"

import re

from snakemake.shell import shell

log = snakemake.log_fmt_shell(stdout=True, stderr=True, append=True)

db = snakemake.params.get("db") or snakemake.input[0]
assert db is not None, "input/params: db is a required position 0 or named parameter"

read_length = snakemake.params.get("readlen")
if read_length is None:
    read_length_file = snakemake.input.get("readlen")
    assert read_length_file is not None, "input/params: readlen is a required parameter"
    with open(read_length_file, "r") as fh:
        read_length = re.sub(r"\D+", "", fh.readline())

shellcmd = (
    f"bracken-build"
    f" -d {db}"
    f" -k {snakemake.params.klen}"
    f" -l {read_length}"
    f" -y {snakemake.params.ktype}"
    f" -t {snakemake.threads}"
    f" {log}"
)
shellcmd = re.sub(r"\s+", " ", shellcmd)
with open(snakemake.log[0], "wt") as log_fh:
    log_fh.write(f"{shellcmd}\n")

shell(shellcmd)

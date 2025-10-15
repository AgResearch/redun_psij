import logging
from redun import task, File
from redun_psij import JobContext

from example.tasks import fastqc, multiqc, fastq_generator

redun_namespace = "example"

logging.basicConfig(
    filename="example.log",
    level=logging.DEBUG,
    format="%(asctime)s %(name)-12s %(levelname)-8s %(message)s",
    datefmt="%Y-%m-%d %H:%M",
)
# for noisy_module in ["asyncio", "pulp.apis.core", "urllib3"]:
#     logging.getLogger(noisy_module).setLevel(logging.WARN)


@task()
def main(
    seqlen: int,
    numseq: int,
) -> list[File]:
    job_context = JobContext()
    out_dir = "out"

    fastq = fastq_generator(seqlen, numseq, out_dir)

    return [fastq]

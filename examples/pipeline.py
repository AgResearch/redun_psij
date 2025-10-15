import logging
import os
import os.path
from redun import task, File
from redun_psij import JobContext
from typing import Tuple

from example.tasks import fastqc_one, multiqc, fastq_generator, FastqcOutput

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
    seqlen: int = 300,
    numseq: int = 1000,
) -> Tuple[File, FastqcOutput]:
    job_context = JobContext()
    out_dir = os.path.join(os.getcwd(), "out")

    fastq_file = fastq_generator(seqlen, numseq, out_dir)

    fastqc_outputs = fastqc_one(
        fastq_file,
        out_dir=out_dir,
        job_context=job_context,
    )

    return (fastq_file, fastqc_outputs)

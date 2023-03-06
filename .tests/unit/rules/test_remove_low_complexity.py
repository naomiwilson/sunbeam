import gzip
import pytest
import shutil
import subprocess as sp
import sys
from pathlib import Path
from . import init

test_dir = Path(__file__).parent.parent.parent.resolve()
sys.path.append(str(test_dir))
from config_fixture import output_dir, config

data_dir = Path(__file__).parent / "data"


@pytest.fixture
def setup(init):
    output_dir = init

    shutil.copytree(
        data_dir / "qc" / "01_cutadapt",
        output_dir / "sunbeam_output" / "qc" / "01_cutadapt",
    )
    shutil.copytree(
        data_dir / "qc" / "02_trimmomatic",
        output_dir / "sunbeam_output" / "qc" / "02_trimmomatic",
    )
    shutil.copytree(
        data_dir / "qc" / "log" / "komplexity",
        output_dir / "sunbeam_output" / "qc" / "log" / "komplexity",
    )

    yield output_dir

    shutil.rmtree(output_dir / "sunbeam_output")


def test_remove_low_complexity(setup):
    output_dir = setup
    sunbeam_output_dir = output_dir / "sunbeam_output"
    r1 = sunbeam_output_dir / "qc" / "03_komplexity" / "TEST_1.fastq.gz"
    r2 = sunbeam_output_dir / "qc" / "03_komplexity" / "TEST_2.fastq.gz"

    sp.check_output(
        [
            "sunbeam",
            "run",
            "--profile",
            f"{output_dir}",
            "--notemp",
            "--rerun-triggers=input",
            f"{r1}",
            f"{r2}",
        ]
    )

    assert r1.stat().st_size >= 10000
    assert r2.stat().st_size >= 10000

    with gzip.open(r1) as f1, gzip.open(r2) as f2:
        assert len(f1.readlines()) == len(f2.readlines())

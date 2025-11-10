# redun_psij

This package enables Redun tasks to be scheduled on any job scheduler supported by PSI/J, which includes Slurm, PBS, LFS among others.

It is not tightly integrated into Redun, and therefore has a different flavour than the executors natively supported in Redun.

## Installation

The package is pure Python with its only dependencies being [redun](https://insitro.github.io/redun/index.html), [PSI/J](https://exaworks.org/psij-python/index.html), and [Jsonnet](https://jsonnet.org/).  It is available on PyPI as [redun_psij](https://pypi.org/project/redun_psij/) or as Nix flake.

## Overview and API documentation

See the [docs on GitHub pages](https://agresearch.github.io/redun_psij/index.html).

## Status

This code is in production using a Slurm backend.  No other job schedulers have been tested.

# Gromacs + Plumed Docker Container

Prebuild Gromacs patched with Plumed, wrapped in Docker container for convenient use. Supports multiple CPU architectures and NVIDIA GPUs.
Currently Cuda 11.2 is used, which requires NVIDIA drivers 450.80.02 and later (https://docs.nvidia.com/deploy/cuda-compatibility/index.html)

Versions of Gromacs and Docker are specified in Dockerfile here.

## Build

The up to date build command is the first line of Dockerfile, just run

	$(head -1 Dockerfile | sed 's/^#! //')

It builds a tagged container ljocha/gromacs:GROMACS_VERSION-LJOCHA_VERSION

## Run in Docker

At least Docker version 19 is required to run with GPU support, see https://github.com/NVIDIA/nvidia-docker for details

Typical usage

	docker run --gpus all -u $(id -u) -w /work -v $PWD:/work ljocha/gromacs:GROMACS_VERSION-LJOCHA_VERSION gmx ....

or use gmx_d for double precision (does not support GPU). The current working directory is visible to Gromacs due to the -w and -v options, all GPUs are available.
Effective UID is preserved with -u. 



## Run in Singularity

Proven to work with Singularity version 3.7

Set up the environment

	export SINGULARITY_CACHEDIR=$HOME/singularity	# some path to be reused
	export SINGULARITY_TMPDIR=$SCRATCHDIR/singularity	# few GB required 
	mkdir -p $SINGULARITY_TMPDIR

Pull and convert the image

	singularity pull docker://ljocha/gromacs:GROMACS_VERSION-LJOCHA_VERSION

Run 

	singularity run --nv --pwd /work -B $PWD:/work gromacs_GROMACS_VERSION-LJOCHA_VERSION.sif gmx ...





#!/bin/bash

set -- $(getopt j:a:s:rd "$@")

SRC=.
DOUBLE=OFF
GPU=CUDA
RDTSCP=OFF
ARCH=SSE2
JOBS=8

while test "$1" != --; do case $1 in
	-r) RDTSCP=ON;;
	-d) DOUBLE=ON; GPU=OFF;;
	-a) ARCH=$2; shift;;
	-j) JOBS=$2; shift;;
	-s) SRC=$2; shift;;
esac; shift; done

ARCHDIR=$ARCH
[ $DOUBLE = 'ON' ] && ARCHDIR=${ARCHDIR}_d
[ $RDTSCP = 'ON' ] && ARCHDIR=${ARCHDIR}_ts
BUILDIR=gromacs_build_$ARCHDIR
	
set -x 
mkdir -p $BUILDIR || exit 1
SRC=$(realpath $SRC)

cd $BUILDIR
CC=gcc CXX=g++ cmake $SRC \
	-DGMX_OPENMP=ON \
	-DGMX_GPU=$GPU \
	-DGMX_MPI=ON \
	-DGMX_DOUBLE=$DOUBLE \
	-DGMX_BUILD_OWN_FFTW=ON \
	-DGMX_DEFAULT_SUFFIX=OFF \
	-DCMAKE_INSTALL_PREFIX=/gromacs/$ARCHDIR \
	-DGMX_USE_RDTSCP=$RDTSCP \
	-DGMX_SIMD=$ARCH \
&& make -j $JOBS \
&& make install

if [ "$ARCH" = AVX_512 ]; then
	g++ -O3 -mavx512f -std=c++11 \
	    -DGMX_IDENTIFY_AVX512_FMA_UNITS_STANDALONE=1 \
	    -DGMX_X86_GCC_INLINE_ASM=1 \
	    -DSIMD_AVX_512_CXX_SUPPORTED=1 \
	    -o /gromacs/$ARCHDIR/bin/identifyavx512fmaunits \
	    $SRC/src/gromacs/hardware/identifyavx512fmaunits.cpp
fi

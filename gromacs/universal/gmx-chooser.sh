#!/bin/sh
FLAGS=`cat /proc/cpuinfo | grep ^flags | head -1`
if echo $FLAGS | grep " avx512f " > /dev/null; then
        PATH=$PATH:/gromacs/AVX_512/bin
elif echo $FLAGS | grep " avx2 " > /dev/null; then
        PATH=$PATH:/gromacs/AVX2_256/bin
else
		PATH=$PATH:/gromacs/SSE2/bin
fi

export PATH


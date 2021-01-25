#!/bin/sh

unset double
unset rdtscp
if [ ! -z $DOUBLE ]; then
        double="_d"
fi

if [ ! -z $RDTSCP ]; then
        rdtscp="_ts"
fi

FLAGS=`cat /proc/cpuinfo | grep ^flags | head -1`
if echo $FLAGS | grep " avx512f " > /dev/null && test -d /gromacs/bin.AVX_512 && echo `/gromacs/bin.AVX_512/identifyavx512fmaunits` | grep "2" > /dev/null; then
        PATH=$PATH:/gromacs/AVX_512${double}${rdtscp}/bin
elif echo $FLAGS | grep " avx2 " > /dev/null; then
        PATH=$PATH:/gromacs/AVX2_256${double}${rdtscp}/bin
else
        PATH=$PATH:/gromacs/SSE2${double}/bin
fi

export PATH


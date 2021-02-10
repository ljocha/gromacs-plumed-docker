#!/bin/sh
  
unset double
unset rdtscp

if [ -z "$PATH_LENGTH" ]; then
        PATH_LENGTH=${#PATH}
        export PATH_LENGTH
fi

PATH=${PATH:0:PATH_LENGTH}
if [ "$DOUBLE" = "ON" ]; then
        double="_d"
fi
if [ "$RDTSCP" = "ON" ]; then
        rdtscp="_ts"
fi
if [ ! -z "$ARCH" ]; then
        PATH=$PATH:/gromacs/${ARCH}${double}${rdtscp}/bin
        export PATH
        return 0
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

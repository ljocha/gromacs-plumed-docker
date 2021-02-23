#!/bin/sh
  
unset double
unset rdtscp
unset arch

FLAGS=$(cat /proc/cpuinfo | grep ^flags | head -1)

if [ -z $PATH_LENGTH ]; then
        PATH_LENGTH=${#PATH}
        export PATH_LENGTH
fi

PATH=${PATH:0:PATH_LENGTH}

if [ -z "$GMX_DOUBLE" ]; then
	GMX_DOUBLE=OFF
fi

if [ -z "$GMX_RDTSCP" ]; then
	GMX_RDTSCP=OFF
	echo $FLAGS | grep " rdtscp " >/dev/null && GMX_RDTSCP=ON
fi

if [ $GMX_DOUBLE = "ON" ]; then
        double="_d"
fi

if [ $GMX_RDTSCP = "ON" ]; then
        rdtscp="_ts"
fi

if [ ! -z $GMX_ARCH ]; then
        PATH=/gromacs/${GMX_ARCH}${double}${rdtscp}/bin:$PATH
        export PATH
        return 0
fi

if echo $FLAGS | grep " avx512f " > /dev/null && test -d /gromacs/bin.AVX_512 && echo $(/gromacs/AVX_512${double}${rdtscp}/bin/identifyavx512fmaunits) | grep "2" > /dev/null; then
        PATH=/gromacs/AVX_512${double}${rdtscp}/bin:$PATH
elif echo $FLAGS | grep " avx2 " > /dev/null; then
        PATH=/gromacs/AVX2_256${double}${rdtscp}/bin:$PATH
else
        PATH=/gromacs/SSE2${double}${rdtscp}/bin:$PATH
fi

export PATH

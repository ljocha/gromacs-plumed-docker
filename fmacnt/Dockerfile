FROM ubuntu:18.04 as builder

MAINTAINER Ales Krenek <ljocha@ics.muni.cz>

USER root

# install required packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends g++

copy gromacs-src /gromacs-src

WORKDIR /tmp

RUN g++ -O3 -mavx512f -std=c++11 \
    -DGMX_IDENTIFY_AVX512_FMA_UNITS_STANDALONE=1 \
    -DGMX_X86_GCC_INLINE_ASM=1 \
    -DSIMD_AVX_512_CXX_SUPPORTED=1 \
    -o /usr/local/bin/identifyavx512fmaunits \
    /gromacs-src/src/gromacs/hardware/identifyavx512fmaunits.cpp

FROM ubuntu:18.04

COPY --from=builder /usr/local/bin/identifyavx512fmaunits /usr/local/bin

ENTRYPOINT [ "/usr/local/bin/identifyavx512fmaunits" ]

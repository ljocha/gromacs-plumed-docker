#FROM nvidia/cuda:11.0.3-devel-ubuntu20.04 as builder
# FROM nvidia/cuda:12.6.2-devel-ubuntu24.04 as builder

#ARG RAY=rayproject/ray:2.42.1-py39-cu124
ARG RAY=rayproject/ray:2.54.0-py313-cu129

FROM ${RAY} AS builder
MAINTAINER Ales Krenek <ljocha@ics.muni.cz> 

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Prague

ARG JOBS=8

USER root

#ARG FFTW_VERSION=3.3.9
#ARG FFTW_MD5=50145bb68a8510b5d77605f11cadf8dc


#enable contributed packages
#RUN sed -i 's/main/main contrib/g' /etc/apt/sources.list

RUN cat /etc/apt/sources.list
#install dependencies
RUN apt-get update 
RUN apt-get install -y g++ gcc 
RUN apt-get install -y libblas-dev xxd 
RUN apt-get install -y openmpi-bin libopenmpi-dev 
RUN apt-get install -y curl
RUN apt-get install -y unzip
# RUN apt-get install -y libfftw3-dev

RUN mkdir /build
WORKDIR /build

#RUN curl -o fftw.tar.gz http://www.fftw.org/fftw-${FFTW_VERSION}.tar.gz 
#RUN echo ${FFTW_MD5} fftw.tar.gz > fftw.tar.gz.md5 && md5sum -c fftw.tar.gz.md5
#
#RUN tar -xzvf fftw.tar.gz && cd fftw-${FFTW_VERSION} \
#  && ./configure --disable-double --enable-float --enable-sse2 --enable-avx --enable-avx2 --enable-avx512 --enable-shared --disable-static \
#  && make -j ${JOBS} \
#  && make install

RUN apt-get update
RUN apt-get install -y git

# interim, before our changes are pushed to mainstream
# ENV GIT_SSL_NO_VERIFY=true
RUN git clone https://github.com/ljocha/plumed2.git plumed2 
RUN cd plumed2 && git config user.name builder && git config user.email iam@some.where && git checkout v2.10 && git merge origin/afed && git merge origin/pytorch_model_cv

ARG TORCH_VERSION=2.10.0
RUN mamba install -y libtorch=${TORCH_VERSION}

#ENV LIBTORCH=/build/libtorch
ENV LIBTORCH=/home/ray/anaconda3
ENV CPATH=${LIBTORCH}/include/torch/csrc/api/include/:${LIBTORCH}/include/:${LIBTORCH}/include/torch:$CPATH
ENV INCLUDE=${LIBTORCH}/include/torch/csrc/api/include/:${LIBTORCH}/include/:${LIBTORCH}/include/torch:$INCLUDE
ENV LIBRARY_PATH=${LIBTORCH}/lib:$LIBRARY_PATH
ENV LD_LIBRARY_PATH=${LIBTORCH}/lib:$LD_LIBRARY_PATH

# XXX: python broken with ray
RUN cd plumed2 && ./configure --disable-python --enable-libtorch --enable-modules=all && make -j ${JOBS} && make install 
RUN ldconfig

RUN apt update
RUN apt install -y python3

ARG GROMACS_VERSION=2026.1
#ARG GROMACS_MD5=2eb4cd478cc5178fc9f67d66fcf48ed6
ARG GROMACS_PATCH_VERSION=${GROMACS_VERSION}

RUN curl -o gromacs.tar.gz https://ftp.gromacs.org/gromacs/gromacs-${GROMACS_VERSION}.tar.gz
#RUN echo ${GROMACS_MD5} gromacs.tar.gz > gromacs.tar.gz.md5 && md5sum -c gromacs.tar.gz.md5

RUN tar -xzvf gromacs.tar.gz
# using native plumed instead
# RUN cd gromacs-${GROMACS_VERSION} && plumed patch -e gromacs-${GROMACS_PATCH_VERSION} -p

# newer version needed
RUN mamba install -y cmake

COPY build-gmx.sh /build
RUN ./build-gmx.sh -s gromacs-${GROMACS_VERSION} -j ${JOBS} -a SSE2
#RUN ./build-gmx.sh -s gromacs-${GROMACS_VERSION} -j ${JOBS} -a SSE2 -d

RUN ./build-gmx.sh -s gromacs-${GROMACS_VERSION} -j ${JOBS} -a AVX2_256 -r
#RUN ./build-gmx.sh -s gromacs-${GROMACS_VERSION} -j ${JOBS} -a AVX2_256 -r -d

RUN ./build-gmx.sh -s gromacs-${GROMACS_VERSION} -j ${JOBS} -a AVX_512 -r
#RUN ./build-gmx.sh -s gromacs-${GROMACS_VERSION} -j ${JOBS} -a AVX_512 -r -d


RUN apt update


#FROM nvidia/cuda:12.6.2-runtime-ubuntu24.04 
FROM ${RAY} AS runtime

USER root

RUN apt-get update
RUN apt install -y openmpi-bin
# XXX: RUN apt install -y libcufft-12-6 libmpich12 libblas3 libgomp1 
RUN apt install -y rsync libblas3

#COPY --from=builder /build/libtorch /build/libtorch
#ENV LD_LIBRARY_PATH=/build/libtorch/lib:$LD_LIBRARY_PATH
#ENV CPLUS_INCLUDE_PATH=/build/libtorch/include:$CPLUS_INCLUDE_PATH
RUN mamba install -y libtorch=${TORCH_VERSION}

# COPY --from=builder /build/libtorch/lib/* /usr/local/lib/
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib/libplumed* /usr/local/lib/
COPY --from=builder /usr/local/lib/plumed/ /usr/local/lib/plumed/

ENV PLUMED_KERNEL=/usr/local/lib/libplumedKernel.so

COPY --from=builder /gromacs /gromacs

COPY gmx-chooser.sh /gromacs
COPY gmx /usr/local/bin
RUN ln -s gmx /usr/local/bin/gmx_d
RUN ln -s gmx /usr/local/bin/mdrun
RUN ln -s gmx /usr/local/bin/mdrun_d
RUN echo /home/ray/anaconda3/lib >/etc/ld.so.conf.d/conda.conf

RUN apt clean
# The NVIDIA container runtime injects /etc/ld.so.conf.d/00-nvcr-*.conf on GPU nodes at startup,
# which adds /usr/lib/x86_64-linux-gnu before conda and re-runs ldconfig — making the system's
# older libstdc++ win over conda's. Renaming to 0-conda.conf sorts before 00-nvcr-*.
RUN mv /etc/ld.so.conf.d/conda.conf /etc/ld.so.conf.d/0-conda.conf && ldconfig

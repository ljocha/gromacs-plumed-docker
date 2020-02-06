# based on https://github.com/ur-whitelab/docker-images/blob/master/plumed/gromacs/Dockerfile

# Copyright (c) University of Rochester
# Distributed under GPL License 3.0
# ------------------------------------------------
# Dockerfile to run gromacs on an ubuntu base install with plumed

FROM nvidia/cuda:10.1-devel-ubuntu18.04 
MAINTAINER Ales Krenek <ljocha@ics.muni.cz> 

ARG FFTW_VERSION
ARG PLUMED_VERSION
ARG JOBS=4

#enable contributed packages
#RUN sed -i 's/main/main contrib/g' /etc/apt/sources.list

RUN cat /etc/apt/sources.list
#install dependencies
#RUN apt-get update && apt-get install -y libfftw3-dev git cmake g++ gcc libblas-dev xxd openmpi-bin libopenmpi-dev && apt-get clean
RUN apt-get update && apt-get install -y cmake g++ gcc libblas-dev xxd mpich libmpich-dev && apt-get clean

RUN mkdir /build
WORKDIR /build
COPY fftw.tar.gz /tmp
RUN tar -xzvf /tmp/fftw.tar.gz && cd fftw-${FFTW_VERSION} \
  && ./configure --disable-double --enable-float --enable-sse2 --enable-avx --enable-avx2 --enable-avx512 --enable-shared --disable-static \
  && make -j ${JOBS} \
  && make install

COPY plumed2 /build/plumed2

RUN ls /build
RUN cd plumed2 && ./configure --enable-modules=all --enable-modules=annfunc && make -j ${JOBS} && make install && make clean
RUN ldconfig
# 
# 
# ENV SHELL /bin/bash
# ENV USER gromacs
# ENV UID 2000
# ENV HOME /home/$USER
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US.UTF-8
# 
# RUN useradd -m -s /bin/bash -N -u $UID $USER
# RUN ldconfig
# 
# USER $USER
# WORKDIR /home/$USER

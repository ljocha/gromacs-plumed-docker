# based on https://github.com/ur-whitelab/docker-images/blob/master/plumed/gromacs/Dockerfile

# Copyright (c) University of Rochester
# Distributed under GPL License 3.0
# ------------------------------------------------
# Dockerfile to run gromacs on an ubuntu base install with plumed

FROM nvidia/cuda:10.1-devel-ubuntu18.04 
MAINTAINER Ales Krenek <ljocha@ics.muni.cz> 

#enable contributed packages
#RUN sed -i 's/main/main contrib/g' /etc/apt/sources.list

RUN cat /etc/apt/sources.list
#install dependencies
RUN apt-get update && apt-get install -y libfftw3-dev git cmake g++ gcc libblas-dev xxd openmpi-bin libopenmpi-dev && apt-get clean

#get plumed
ENV PLUMED_VERSION=v2.5.1
RUN git clone https://github.com/plumed/plumed2 --branch $PLUMED_VERSION --single-branch /srv/plumed
WORKDIR /srv/plumed
RUN ./configure --enable-modules=all && make -j4 && make install && make clean


ENV SHELL /bin/bash
ENV USER ljocha
ENV UID 1000
ENV HOME /home/$USER
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN useradd -m -s /bin/bash -N -u $UID $USER
RUN ldconfig

USER $USER
WORKDIR /home/$USER

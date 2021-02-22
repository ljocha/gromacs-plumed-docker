FROM nvidia/cuda:10.1-devel-ubuntu18.04 
MAINTAINER Ales Krenek <ljocha@ics.muni.cz> 

ARG JOBS=8

ARG FFTW_VERSION=3.3.9
ARG FFTW_MD5=50145bb68a8510b5d77605f11cadf8dc


#enable contributed packages
#RUN sed -i 's/main/main contrib/g' /etc/apt/sources.list

RUN cat /etc/apt/sources.list
#install dependencies
RUN apt-get update 
RUN apt-get install -y cmake g++ gcc 
RUN apt-get install -y libblas-dev xxd 
RUN apt-get install -y mpich libmpich-dev 
RUN apt-get install -y curl

RUN mkdir /build
WORKDIR /build

RUN curl -o fftw.tar.gz http://www.fftw.org/fftw-${FFTW_VERSION}.tar.gz 
RUN echo ${FFTW_MD5} fftw.tar.gz > fftw.tar.gz.md5 && md5sum -c fftw.tar.gz.md5

RUN tar -xzvf fftw.tar.gz && cd fftw-${FFTW_VERSION} \
  && ./configure --disable-double --enable-float --enable-sse2 --enable-avx --enable-avx2 --enable-avx512 --enable-shared --disable-static \
  && make -j ${JOBS} \
  && make install

ARG PLUMED_VERSION=v2.7.0

RUN apt-get install -y git

RUN git clone https://github.com/plumed/plumed2 --branch ${PLUMED_VERSION} --single-branch
RUN cd plumed2 && ./configure --enable-modules=all && make -j ${JOBS} && make install 
RUN ldconfig

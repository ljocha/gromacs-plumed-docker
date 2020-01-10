
ARG PLUMED_IMAGE
FROM $PLUMED_IMAGE as builder

MAINTAINER Ales Krenek <ljocha@ics.muni.cz>

ARG ARCH=SSE2
ARG RDTSCP=OFF
ARG DOUBLE=OFF


# number of make jobs during compile
ARG JOBS=4

USER root

RUN apt-get update && apt-get install -y libhwloc-dev

RUN mkdir -p /gromacs-build/src /gromacs-build/build
COPY gromacs-src /gromacs-build/src
WORKDIR /gromacs-build/build

RUN CC=gcc CXX=g++ cmake ../src \
    -DGMX_OPENMP=ON \
    -DGMX_GPU=$(if [ ${DOUBLE} = ON ]; then echo OFF; else echo ON; fi) \
    -DGMX_MPI=ON \
    -DGMX_DOUBLE=${DOUBLE} \
    -DGMX_BUILD_OWN_FFTW=${DOUBLE} \
    -DGMX_DEFAULT_SUFFIX=OFF \
    -DCMAKE_INSTALL_PREFIX=/gromacs \
#    -DREGRESSIONTEST_DOWNLOAD=ON \
    -DGMX_USE_NVML=OFF \
    -DGMX_USE_RDTSCP=${RDTSCP} \
    -DGMX_SIMD=${ARCH} \
  && make -j ${JOBS} \
  && make install; done


###############################################################################
# Final stage
###############################################################################
# we have plumed inside

# XXX: must be consistent with FROM above
FROM nvidia/cuda:10.1-runtime-ubuntu18.04

# install required packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libgomp1 \
    mpich \
    python 

# additional plumed deps
RUN apt-get install -y libblas3 xxd  && apt-get clean

# copy fftw libraries & plumed
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/bin /usr/local/bin

# copy gromacs install
COPY --from=builder /gromacs /gromacs

ENV PATH=$PATH:/gromacs/bin

RUN ldconfig

WORKDIR /tmp

# Enable the entrypoint to use the dockerfile as a GROMACS binary
ENTRYPOINT [ "/gromacs/bin/gmx" ]

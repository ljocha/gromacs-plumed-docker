
ARG PLUMED_IMAGE
ARG BASE_ARCH_IMAGE

FROM $PLUMED_IMAGE as builder

# number of make jobs during compile
ARG JOBS=4

USER root

RUN mkdir -p /gromacs-build/src /gromacs-build/build
COPY gromacs-src /gromacs-build/src
WORKDIR /gromacs-build/build

###############################################################################
# Build possible mdruns
###############################################################################
RUN CC=gcc CXX=g++ cmake ../src \
    -DGMX_OPENMP=ON \
	-DGMX_GPU=OFF \
    -DGMX_MPI=ON \
	-DGMX_DOUBLE=ON \
	-DGMX_BUILD_OWN_FFTW=ON \
	-DGMX_BUILD_MDRUN_ONLY=ON \
    -DGMX_DEFAULT_SUFFIX=OFF \
    -DCMAKE_INSTALL_PREFIX=/gromacs/AVX_512 \
    -DGMX_USE_RDTSCP=OFF \
    -DGMX_SIMD=AVX_512 \
  && make -j ${JOBS} \
  && make install; done

RUN CC=gcc CXX=g++ cmake ../src \
    -DGMX_OPENMP=ON \
	-DGMX_GPU=OFF \
    -DGMX_MPI=ON \
	-DGMX_DOUBLE=ON \
	-DGMX_BUILD_OWN_FFTW=ON \
	-DGMX_BUILD_MDRUN_ONLY=ON \
    -DGMX_DEFAULT_SUFFIX=OFF \
    -DCMAKE_INSTALL_PREFIX=/gromacs/AVX2_256 \
    -DGMX_USE_RDTSCP=OFF \
    -DGMX_SIMD=AVX2_256 \
  && make -j ${JOBS} \
  && make install; done

RUN CC=gcc CXX=g++ cmake ../src \
    -DGMX_OPENMP=ON \
	-DGMX_GPU=OFF \
    -DGMX_MPI=ON \
	-DGMX_DOUBLE=ON \
	-DGMX_BUILD_OWN_FFTW=ON \
	-DGMX_BUILD_MDRUN_ONLY=ON \	
    -DGMX_DEFAULT_SUFFIX=OFF \
    -DCMAKE_INSTALL_PREFIX=/gromacs/SSE2 \
    -DGMX_USE_RDTSCP=OFF \
    -DGMX_SIMD=SSE2 \
  && make -j ${JOBS} \
  && make install; done

###############################################################################
# Copy on top of base architecture all mdruns
###############################################################################
FROM $BASE_ARCH_IMAGE

COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/bin /usr/local/bin

# copy gromacs install
COPY --from=builder /gromacs /gromacs
COPY universal/gmx-chooser.sh /opt

ENV PATH=$PATH:/gromacs/bin
 
RUN ldconfig

WORKDIR /tmp


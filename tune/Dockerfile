FROM ljocha/gromacs:2023-2 as gmx

FROM rayproject/ray:2.5.0-gpu

USER root
COPY --from=gmx /gromacs /gromacs

COPY --from=gmx /usr/local/bin/gmx /usr/local/bin

# COPY --from=gmx /usr/local/bin /usr/local/bin
COPY --from=gmx /usr/local/lib/libplumed* /usr/local/lib/
COPY --from=gmx /usr/local/lib/plumed/ /usr/local/lib/plumed/

COPY --from=gmx /build/libtorch /build/libtorch
ENV LD_LIBRARY_PATH=/build/libtorch/lib:$LD_LIBRARY_PATH

RUN ln -s gmx /usr/local/bin/gmx_d
RUN ln -s gmx /usr/local/bin/mdrun
RUN ln -s gmx /usr/local/bin/mdrun_d

RUN apt update && apt install -y mpich libblas3 xxd && apt clean && rm -rf /var/lib/apt/lists/*
RUN ldconfig

USER 1000


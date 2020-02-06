#!/bin/bash

CI_REGISTRY_IMAGE?=ljocha
IMAGE=${CI_REGISTRY_IMAGE}
VERSION=:2020.02.06-1
PLUMED_IMAGE_VERSION=:2020.02.06-1


GROMACS_VERSION=2019.4
GROMACS_PATCH_VERSION=${GROMACS_VERSION}
GROMACS_MD5=b424b9099f8bb00e1cd716a1295d797e

FFTW_VERSION=3.3.8
FFTW_MD5=8aac833c943d8e90d51b697b27d4384d

PLUMED_VERSION=v2.6.0

JOBS?=16

id=$(shell id -u)


all: gromacs/gmx-docker build-plumed build-gromacs build-fmacnt

build-plumed:
	git clone https://github.com/plumed/plumed2 --branch ${PLUMED_VERSION} --single-branch plumed/plumed2
	curl -o fftw.tar.gz http://www.fftw.org/fftw-${FFTW_VERSION}.tar.gz  
	echo "${FFTW_MD5}  fftw.tar.gz" > fftw.tar.gz.md5 && md5sum -c fftw.tar.gz.md5 
	mv fftw.tar.gz plumed
	cd plumed && docker build --pull -t "${IMAGE}/plumed${PLUMED_IMAGE_VERSION}" --build-arg PLUMED_VERSION=${PLUMED_VERSION} --build-arg FFTW_VERSION=${FFTW_VERSION} --build-arg JOBS=${JOBS} .
	docker push "${IMAGE}/plumed${PLUMED_IMAGE_VERSION}"

gromacs-src:
	curl -o gromacs.tar.gz http://ftp.gromacs.org/pub/gromacs/gromacs-${GROMACS_VERSION}.tar.gz
	echo "${GROMACS_MD5}  gromacs.tar.gz" > gromacs.tar.gz.md5
	md5sum -c gromacs.tar.gz.md5
	tar xzf gromacs.tar.gz
	mv gromacs-${GROMACS_VERSION} gromacs-src
	docker run -v ${PWD}/gromacs-src:/gromacs-src -w /gromacs-src -u ${id} "${IMAGE}/plumed${VERSION}" plumed patch -e gromacs-${GROMACS_PATCH_VERSION} -p

build-fmacnt: gromacs-src
	tar cf - gromacs-src | (cd fmacnt && tar xf -)
	docker build --pull -t "${IMAGE}/gromacs-fmacnt${VERSION}" fmacnt
	docker push "${IMAGE}/gromacs-fmacnt${VERSION}"


build-gromacs: gromacs-src
	tar cf - gromacs-src | (cd gromacs && tar xf -)
	while read flavor arch rdtscp double; do\
		echo build args: ARCH=$$arch RDTSCP=$$rdtscp DOUBLE=$$double ; \
		docker build --pull -t "${IMAGE}/gromacs_$$flavor${VERSION}" --build-arg PLUMED_IMAGE=${IMAGE}/plumed${PLUMED_IMAGE_VERSION} --build-arg ARCH=$$arch --build-arg RDTSCP=$$rdtscp --build-arg DOUBLE=$$double gromacs --build-arg JOBS=${JOBS} && \
		docker push "${IMAGE}/gromacs_$$flavor${VERSION}" || break ; \
	done <gromacs/flavors.txt
		
gromacs/gmx-docker: gromacs/gmx-docker.in Makefile
	sed "s/%VERSION%/${VERSION}/g; s?%IMAGE%?${IMAGE}?g" gromacs/gmx-docker.in >$@
	chmod +x $@

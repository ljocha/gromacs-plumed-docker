#!/bin/bash

CI_REGISTRY_IMAGE?=ljocha
IMAGE=${CI_REGISTRY_IMAGE}
VERSION=:2019.11.26-1

GROMACS_VERSION=2018.8
GROMACS_MD5=12fe6c41c1ed76ed8227c6d37c465ff4

FFTW_VERSION=3.3.8
FFTW_MD5=8aac833c943d8e90d51b697b27d4384d

PLUMED_VERSION=v2.6b

id=$(shell id -u)


all: build-plumed build-gromacs build-fmacnt gromacs/gmx-docker

build-plumed:
	git clone https://github.com/plumed/plumed2 --branch ${PLUMED_VERSION} --single-branch plumed/plumed2
	curl -o fftw.tar.gz http://www.fftw.org/fftw-${FFTW_VERSION}.tar.gz  
	echo "${FFTW_MD5}  fftw.tar.gz" > fftw.tar.gz.md5 && md5sum -c fftw.tar.gz.md5 
	mv fftw.tar.gz plumed
	cd plumed && docker build --pull -t "${IMAGE}/plumed${VERSION}" --build-arg PLUMED_VERSION=${PLUMED_VERSION} --build-arg FFTW_VERSION=${FFTW_VERSION} .
	docker push "${IMAGE}/plumed${VERSION}"

gromacs-src:
	curl -o gromacs.tar.gz http://ftp.gromacs.org/pub/gromacs/gromacs-${GROMACS_VERSION}.tar.gz
	echo "${GROMACS_MD5}  gromacs.tar.gz" > gromacs.tar.gz.md5
	md5sum -c gromacs.tar.gz.md5
	tar xzf gromacs.tar.gz
	mv gromacs-${GROMACS_VERSION} gromacs-src
	docker run -v ${PWD}/gromacs-src:/gromacs-src -w /gromacs-src -u ${id} "${IMAGE}/plumed${VERSION}" plumed patch -e gromacs-${GROMACS_VERSION} -p

build-fmacnt: gromacs-src
	tar cf - gromacs-src | (cd fmacnt && tar xf -)
	docker build --pull -t "${IMAGE}/gromacs-fmacnt${VERSION}" fmacnt
	docker push "${IMAGE}/gromacs-fmacnt${VERSION}"


build-gromacs: gromacs-src
	tar cf - gromacs-src | (cd gromacs && tar xf -)
	while read flavor arch rdtscp double; do\
		echo build args: ARCH=$$arch RDTSCP=$$rdtscp DOUBLE=$$double ; \
		docker build --pull -t "${IMAGE}/gromacs_$$flavor${VERSION}" --build-arg PLUMED_IMAGE=${IMAGE}/plumed${VERSION} --build-arg ARCH=$$arch --build-arg RDTSCP=$$rdtscp --build-arg DOUBLE=$$double gromacs && \
		docker push "${IMAGE}/gromacs_$$flavor${VERSION}" || break ; \
	done <gromacs/flavors.txt.test
		
gromacs/gmx-docker: gromacs/gmx-docker.in Makefile
	sed "s/%VERSION%/${VERSION}/g; s/%IMAGE%/${IMAGE}/g" gromacs/gmx-docker.in >$@
	chmod +x $@



#	docker build --pull -t "${IMAGE}/gromacs${VERSION}" gromacs
#	docker push "${IMAGE}/gromacs${VERSION}"





#cd ../gromacs &&
#docker build --pull -t "$IMAGE/gromacs$VERSION" --build-arg PLUMED_IMAGE="$IMAGE/plumed$VERSION" . &&
#docker push "$IMAGE/gromacs$VERSION"


BASE?=cerit.io/ljocha/gromacs
VERSION=2024-3-plumed-2-10-afed-pytorch-model-cv-2
IMAGE=${BASE}:${VERSION}

DIR?=${PWD}

all: build #wrapper push

build:
	docker build -t ${IMAGE} .

wrapper:
	sed 's?%IMAGE%?${IMAGE}?' gmx-docker.in >gmx-docker
	chmod +x gmx-docker

push:
	docker push ${IMAGE}

run:
#	docker run -ti --rm -v ${DIR}:/work -w /work ${IMAGE} gmx ${ARGS}
	echo -- ${ARGS}


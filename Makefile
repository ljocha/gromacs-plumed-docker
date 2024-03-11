
BASE?=cerit.io/ljocha/gromacs
VERSION=2023-2-plumed-2-9-afed-pytorch-model-cv-2
IMAGE=${BASE}:${VERSION}

all: build #wrapper push

build:
	docker build --no-cache -t ${IMAGE} .

wrapper:
	sed 's?%IMAGE%?${IMAGE}?' gmx-docker.in >gmx-docker
	chmod +x gmx-docker

push:
	docker push ${IMAGE}

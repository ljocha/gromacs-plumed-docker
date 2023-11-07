
BASE?=cerit.io/ljocha/gromacs
VERSION=2023-afed-1
IMAGE=${BASE}:${VERSION}

all: build #wrapper push

build:
	docker build -t ${IMAGE} .

wrapper:
	sed 's?%IMAGE%?${IMAGE}?' gmx-docker.in >gmx-docker
	chmod +x gmx-docker

push:
	docker push ${IMAGE}

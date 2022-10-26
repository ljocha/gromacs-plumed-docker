
VERSION=2022-libtorch-1.12.1
BASE=kurecka/gromacs
IMAGE=${BASE}:${VERSION}

all: build #wrapper push

build:
	docker build -t ${IMAGE} .

wrapper:
	sed 's?%IMAGE%?${IMAGE}?' gmx-docker.in >gmx-docker
	chmod +x gmx-docker

push:
	dpcker push ${IMAGE}

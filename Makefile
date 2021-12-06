
VERSION=2021-3.3
BASE=ljocha/gromacs
IMAGE=${BASE}:${VERSION}

all: build wrapper push

build:
	docker build -t ${IMAGE} .

wrapper:
	sed 's?%IMAGE%?${IMAGE}?' gmx-docker.in >gmx-docker
	chmod +x gmx-docker

push:
	docker push ${IMAGE}

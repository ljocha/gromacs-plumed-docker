#!/bin/bash

IMAGE=${CI_REGISTRY_IMAGE:-ljocha}
VERSION=:2019.11.15-1

cd plumed &&
docker build --pull -t "$IMAGE/plumed$VERSION" . &&
docker push "$IMAGE/plumed$VERSION" &&
cd ../gromacs &&
docker build --pull -t "$IMAGE/gromacs$VERSION" --build-arg PLUMED_IMAGE="$IMAGE/plumed$VERSION" . &&
docker push "$IMAGE/gromacs$VERSION"

#!/bin/bash

IMAGE=${CI_REGISTRY_IMAGE:-ljocha}

cd plumed &&
docker build --pull -t "$IMAGE/plumed" . &&
docker push "$IMAGE/plumed" &&
cd ../gromacs &&
docker build --pull -t "$IMAGE/gromacs" --build-arg PLUMED_IMAGE="$IMAGE/plumed" . &&
docker push "$IMAGE/gromacs"

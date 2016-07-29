#!/bin/sh
#
# Script to build images
#

# break on error
set -e
set -x
set -a
: ${DOCKER_USE_HUB:="0"}

DATE=`date +%Y.%m.%d`


ci_docker_login() {
    if [ -z ${DOCKER_EMAIL+x} ]; then
        DOCKER_EMAIL=${bamboo_DOCKER_EMAIL}
    fi
    if [ -z ${DOCKER_USERNAME+x} ]; then
        DOCKER_USERNAME=${bamboo_DOCKER_USERNAME}
    fi
    if [ -z ${DOCKER_PASSWORD+x} ]; then
        DOCKER_PASSWORD=${bamboo_DOCKER_PASSWORD}
    fi

    docker login -e "${DOCKER_EMAIL}" -u ${DOCKER_USERNAME} --password="${DOCKER_PASSWORD}"
}


image="muccg/squid-deb-proxy:latest"
echo "################################################################### ${image}"

## warm up cache for CI
docker pull ${image} || true

## build
docker build --pull=true -t ${image}-${DATE} .
docker build -t ${image} .

## for logging in CI
docker inspect ${image}-${DATE}

# push
if [ ${DOCKER_USE_HUB} = "1" ]; then
    ci_docker_login
    docker push ${image}-${DATE}
    docker push ${image}
fi


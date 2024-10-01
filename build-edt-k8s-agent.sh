#!/bin/bash
set -e

if [ $DOCKER_LOGIN != '' ] ; then
    docker login -u $DOCKER_LOGIN -p $DOCKER_PASSWORD $DOCKER_REGISTRY_URL
fi

if [ $DOCKER_SYSTEM_PRUNE = 'true' ] ; then
    docker system prune -af
fi

last_arg='.'
if [ $NO_CACHE = 'true' ] ; then
	last_arg='--no-cache .'
fi

edt_version=$EDT_VERSION
edt_escaped="${edt_version// /_}"

docker build \
	--pull \
    $no_cache_arg \
	--build-arg DOCKER_REGISTRY_URL=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t $DOCKER_REGISTRY_URL/oscript-downloader:latest \
	-f oscript/Dockerfile \
    $last_arg

docker build \
    --build-arg ONEC_USERNAME=$ONEC_USERNAME \
    --build-arg ONEC_PASSWORD=$ONEC_PASSWORD \
    --build-arg EDT_VERSION="$EDT_VERSION" \
    --build-arg DOWNLOADER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg DOWNLOADER_IMAGE=oscript-downloader \
    --build-arg DOWNLOADER_TAG=latest \
    -t $DOCKER_REGISTRY_URL/edt:$edt_escaped \
    -f edt/Dockerfile \
    $last_arg

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=edt \
    --build-arg BASE_TAG=$edt_escaped \
    -t $DOCKER_REGISTRY_URL/edt-agent:$edt_escaped \
	-f k8s-jenkins-agent/Dockerfile \
    $last_arg

docker push $DOCKER_REGISTRY_URL/edt-agent:$edt_escaped

#!/bin/bash
set -e

docker login -u $DOCKER_LOGIN -p $DOCKER_PASSWORD $DOCKER_REGISTRY_URL

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
    --build-arg ONEC_USERNAME=$ONEC_USERNAME \
    --build-arg ONEC_PASSWORD=$ONEC_PASSWORD \
    --build-arg EDT_VERSION="$EDT_VERSION" \
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

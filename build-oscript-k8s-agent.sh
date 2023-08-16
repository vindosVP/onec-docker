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

docker build \
	--pull \
    $no_cache_arg \
	--build-arg DOCKER_REGISTRY_URL=library \
    --build-arg BASE_IMAGE=adoptopenjdk \
    --build-arg BASE_TAG=14-hotspot \
    -t $DOCKER_REGISTRY_URL/oscript-jdk:latest \
	-f oscript/Dockerfile \
    $last_arg

docker build \
    $no_cache_arg \
	--build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=oscript-jdk \
    --build-arg BASE_TAG=latest \
    -t $DOCKER_REGISTRY_URL/oscript-agent:latest \
	-f k8s-jenkins-agent/Dockerfile \
    $last_arg

docker push $DOCKER_REGISTRY_URL/oscript-agent:latest

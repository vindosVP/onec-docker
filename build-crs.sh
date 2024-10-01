#!/usr/bin/env bash
set -euo pipefail

if [ -n "${DOCKER_LOGIN}" ] && [ -n "${DOCKER_PASSWORD}" ] && [ -n "${DOCKER_REGISTRY_URL}" ]; then
    if ! docker login -u "${DOCKER_LOGIN}" -p "${DOCKER_PASSWORD}" "${DOCKER_REGISTRY_URL}"; then
        echo "Docker login failed"
        exit 1
    fi
else
    echo "Skipping Docker login due to missing credentials"
fi

if [ "${DOCKER_SYSTEM_PRUNE}" = 'true' ] ; then
    docker system prune -af
fi

last_arg='.'
if [ "${NO_CACHE}" = 'true' ] ; then
    last_arg='--no-cache .'
fi

docker build \
    --pull \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg ONEC_USERNAME=$ONEC_USERNAME \
    --build-arg ONEC_PASSWORD=$ONEC_PASSWORD \
    --build-arg ONEC_VERSION=$ONEC_VERSION \
    -t $DOCKER_REGISTRY_URL/crs:$ONEC_VERSION \
    -f crs/Dockerfile \
    $last_arg

docker push $DOCKER_REGISTRY_URL/crs:$ONEC_VERSION

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg ONEC_VERSION=$ONEC_VERSION \
    -t $DOCKER_REGISTRY_URL/crs-apache:$ONEC_VERSION \
    -f crs-apache/Dockerfile \
    $last_arg

docker push $DOCKER_REGISTRY_URL/crs-apache:$ONEC_VERSION

#!/bin/bash
# set -exu

export REGISTRY_URL="docker.io"   # docker.io or other registry URL, DOCKER_REGISTRY_USER/DOCKER_REGISTRY_PASSWORD to be set in CI env.
export BUILDKIT_PROGRESS="plain"  # Full logs for CI build.
# DOCKER_REGISTRY_USER and DOCKER_REGISTRY_PASSWORD is required for docker image push, they should be set in CI secrets.

CI_PROJECT_NAME=${GITHUB_REPOSITORY:-"QPod/docker-images"}
CI_PROJECT_BRANCH=${GITHUB_HEAD_REF:-"master"}

if [ "${CI_PROJECT_BRANCH}" = "master" ] ; then
    export CI_PROJECT_NAMESPACE=$(echo "$(dirname ${CI_PROJECT_NAME})") ;
else
    export CI_PROJECT_NAMESPACE=$(echo "$(dirname ${CI_PROJECT_NAME})")0${CI_PROJECT_BRANCH} ;
fi

export NAMESPACE=$(echo "${REGISTRY_URL:-"docker.io"}/${CI_PROJECT_NAMESPACE}" | awk '{print tolower($0)}')
echo "--------> CI_PROJECT_NAMESPACE=${CI_PROJECT_NAMESPACE}"
echo "--------> Docker Repo=${NAMESPACE}"

echo '{"experimental":true}' | sudo tee /etc/docker/daemon.json
sudo service docker restart

build_image() {
    echo $@ ;
    IMG=$1; TAG=$2; FILE=$3; shift 3; VER=`date +%Y.%m%d`;
    docker build --squash --compress --force-rm=true -t "${NAMESPACE}/${IMG}:${TAG}" -f "$FILE" --build-arg "BASE_NAMESPACE=${NAMESPACE}" "$@" "$(dirname $FILE)" ;
    docker tag "${NAMESPACE}/${IMG}:${TAG}" "${NAMESPACE}/${IMG}:${VER}" ;
}

build_image_common() {
    echo $@ ;
    IMG=$1; TAG=$2; FILE=$3; shift 3; VER=`date +%Y.%m%d`;
    docker build --compress --force-rm=true -t "${NAMESPACE}/${IMG}:${TAG}" -f "$FILE" --build-arg "BASE_NAMESPACE=${NAMESPACE}" "$@" "$(dirname $FILE)" ;
    docker tag "${NAMESPACE}/${IMG}:${TAG}" "${NAMESPACE}/${IMG}:${VER}" ;
}

alias_image() {
    IMG_1=$1; TAG_1=$2; IMG_2=$3; TAG_2=$4; shift 4; VER=`date +%Y.%m%d`;
    docker tag "${NAMESPACE}/${IMG_1}:${TAG_1}" "${NAMESPACE}/${IMG_2}:${TAG_2}" ;
    docker tag "${NAMESPACE}/${IMG_2}:${TAG_2}" "${NAMESPACE}/${IMG_2}:${VER}" ;
}

push_image() {
    docker image prune --force && docker images ;
    IMGS=$(docker images | grep "second" | awk '{print $1 ":" $2}') ;
    echo "$DOCKER_REGISTRY_PASSWORD" | docker login "${REGISTRY_URL}" -u "$DOCKER_REGISTRY_USER" --password-stdin ;
    for IMG in $(echo $IMGS | tr " " "\n") ;
    do
      docker push "${IMG}";
      status=$?;
      echo "[${status}] Image pushed > ${IMG}";
    done
}

remove_folder() {
    sudo du -h -d1 $1 || true ;
    sudo rm -rf $1 || true ;
}

free_diskspace() {
    remove_folder /usr/share/dotnet
    remove_folder /usr/local/lib/android
    # remove_folder /var/lib/docker
    df -h
}

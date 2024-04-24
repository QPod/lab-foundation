source /opt/utils/script-utils.sh


setup_docker_compose() {
     ARCH="x86_64" \
  && COMPOSE_VERSION=$(curl -sL https://github.com/docker/compose/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[.\d]+') \
  && COMPOSE_URL="https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-${ARCH}" \
  && echo "Downloading Compose from: ${COMPOSE_URL}" \
  && sudo curl -o /usr/bin/docker-compose -sL ${COMPOSE_URL} \
  && sudo chmod +x /usr/bin/docker-compose \
  && echo "@ Version of docker-compose: $(docker-compose --version)"
}

setup_docker_syncer() {
     ARCH="amd64" \
  && SYNCER_VERSION="$(curl -sL https://github.com/AliyunContainerService/image-syncer/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[.\d]+')" \
  && SYNCER_URL="https://github.com/AliyunContainerService/image-syncer/releases/download/v${SYNCER_VERSION}/image-syncer-v${SYNCER_VERSION}-linux-${ARCH}.tar.gz" \
  && echo "Downloading image-syncer from: ${SYNCER_URL}" \
  && curl -o /tmp/image_syncer.tgz -sL ${SYNCER_URL} \
  && mkdir -pv /tmp/image_syncer && tar -zxvf /tmp/image_syncer.tgz -C /tmp/image_syncer \
  && sudo chmod +x /tmp/image_syncer/image-syncer \
  && sudo mv /tmp/image_syncer/image-syncer /usr/bin/ \
  && rm -rf /tmp/image_syncer* \
  && echo "@ image-syncer installed to: $(which image-syncer)"
}

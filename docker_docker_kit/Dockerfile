# Distributed under the terms of the Modified BSD License.

ARG BASE_NAMESPACE
ARG BASE_IMG="atom"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"
ENV XDG_RUNTIME_DIR="/tmp"

COPY work /opt/utils/

RUN set -eux \
 && source /opt/utils/script-setup-docker.sh \
 && setup_docker_compose && setup_docker_syncer \
 && apt-get -qq update --fix-missing && apt-get -qq install -y --no-install-recommends python-minimal python-pip \
 && pip install -U PyYaml \
 && ln -sf /usr/bin/image-syncer /opt/utils/image-syncer/ \
 # Clean up and display components version information...
 && source /opt/utils/script-utils.sh && install__clean && list_installed_packages

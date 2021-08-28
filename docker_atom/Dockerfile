# Distributed under the terms of the Modified BSD License.

# default value: Latest LTS version of Ubuntu (https://hub.docker.com/_/ubuntu)

ARG BASE_IMG="ubuntu:latest"
FROM ${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"

USER root

COPY work /opt/utils/

ENV SHELL=/bin/bash \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL="" \
    LC_CTYPE="C.UTF-8" \
    LC_TYPE="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    HOME_DIR=/root

SHELL ["/bin/bash", "-c"]

# --> Install OS libraries and setup some configurations
RUN cd /tmp \
 && apt-get -qq update --fix-missing && apt-get -y -qq upgrade \
 && apt-get -qq install -y --no-install-recommends \
     apt-utils apt-transport-https ca-certificates gnupg2 dirmngr locales sudo lsb-release curl \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
 && echo "en_US.UTF-8 UTF-8"             >  /etc/locale.gen && locale-gen \
 && echo "ALL ALL=(ALL) NOPASSWD:ALL"    >> /etc/sudoers \
 && mv /root/.bashrc /etc/bash_profile \
 && echo '[ $BASH ] && [ -f /etc/bash_profile ] && . /etc/bash_profile'	>> /etc/bash.bashrc \
 && echo '[ $BASH ] && [ -f /root/.bashrc ]     && . /root/.bashrc'		>> /etc/bash.bashrc \
 # Clean up and display components version information...
 && source /opt/utils/script-utils.sh && install__clean

WORKDIR $HOME_DIR

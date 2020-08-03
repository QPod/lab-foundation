# Distributed under the terms of the Modified BSD License.

# default value: Latest LTS version of Ubuntu (https://hub.docker.com/_/ubuntu)
ARG base=ubuntu:latest
FROM ${base:-base}

LABEL maintainer="haobibo@gmail.com"

USER root

ENV SHELL=/bin/bash \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL="" \
    LC_CTYPE=C.UTF-8 \
    LC_TYPE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HOME_DIR=/root

# SHELL ["/bin/bash", "-c"]

COPY work /opt/utils/

# --> Install OS libraries and setup some configurations
RUN cd /tmp \
 && apt-get  -y update --fix-missing > /dev/null && apt-get -y -qq upgrade \
 && apt-get -qq install -y --no-install-recommends \
    apt-utils apt-transport-https ca-certificates gnupg2 dirmngr locales sudo \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
 && echo "en_US.UTF-8 UTF-8"             >  /etc/locale.gen && locale-gen \
 && echo "ALL ALL=(ALL) NOPASSWD: ALL"   >> /etc/sudoers \
 && mv /root/.bashrc /etc/bash_profile \
 && echo '[ $BASH ] && [ -f /etc/bash_profile ] && . /etc/bash_profile'	>> /etc/bash.bashrc \
 && echo '[ $BASH ] && [ -f /root/.bashrc ]     && . /root/.bashrc'		  >> /etc/bash.bashrc \
 && cat /opt/utils/script-utils.sh       >> /etc/bash.bashrc \
 # Install libraries libs, utilities
 && source /opt/utils/script-utils.sh \
 && install_apt /opt/utils/install_list_base.apt \
 # Clean up and display components version information...
 && install__clean && cd \
 && echo "@ Version of image: building finished at:" `date` `uname -a` \
 && echo "@ System environment variables:" `printenv`

WORKDIR $HOME_DIR

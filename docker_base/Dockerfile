# Distributed under the terms of the Modified BSD License.

# default value: Latest LTS version of Ubuntu (https://hub.docker.com/_/ubuntu)
ARG base=ubuntu:latest
FROM ${base:-base}

LABEL maintainer="haobibo@gmail.com"

USER root

ENV SHELL=/bin/bash \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=en_US.UTF-8 \
    LC_TYPE=en_US.UTF-8 \
    LC_CTYPE=C.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    PATH=/opt/conda/bin:$PATH \
    HOME_DIR=/root

SHELL ["/bin/bash", "-c"]

COPY work /opt/utils/

# --> Install OS libraries and setup some configurations
RUN cd /tmp \
 && apt-get -y update --fix-missing > /dev/null && apt-get -y -qq upgrade \
 && apt-get -qq install -y --no-install-recommends \
    apt-utils apt-transport-https ca-certificates lsb-release gnupg2 dirmngr wget jq locales sudo \
    build-essential cmake unzip \
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
 && chmod 777 /tmp

# --> Install Python3 (Miniconda3), replace conda packages with pip source.
RUN cd /tmp/ \
 && wget -qO- "https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-$(arch).sh" -O conda.sh && bash /tmp/conda.sh -f -b -p /opt/conda \
 && conda config --system --prepend channels conda-forge \
 && conda config --system --set auto_update_conda false  \
 && conda config --system --set show_channel_urls true   \
 && conda update --all --quiet --yes \
 # These conda pkgs shouldn't be removed (otherwise will cause RemoveError) since they are directly reqiuired by conda: pip setuptools pycosat pyopenssl requests ruamel_yaml
 && CONDA_PY_PKGS=`conda list | grep "py3" | cut -d " " -f 1 | sed "/#/d;/conda/d;/pip/d;/setuptools/d;/pycosat/d;/pyopenssl/d;/requests/d;/ruamel_yaml/d;"` \
 && conda remove --force -yq $CONDA_PY_PKGS \
 && pip install -UIq pip setuptools $CONDA_PY_PKGS \
 # Replace system Python3 with Conda's Python, and take care of `lsb_releaes`
 && rm /usr/bin/python3 && ln -s /opt/conda/bin/python /usr/bin/python3 \
 && mv /usr/share/pyshared/lsb_release.py /usr/bin/ \
 # Print Conda and Python packages information in the docker build log
 && echo "@ Version of Conda & Python:" && conda info && conda list | grep -v "<pip>"

# --> Clean up and display components version information...
RUN  source /opt/utils/script-utils.sh \
  && install__clean && cd \
  && echo "@ Version of image: building finished at:" `date` `uname -a` \
  && echo "@ System environment variables:" `printenv`

WORKDIR $HOME_DIR

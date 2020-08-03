# Distributed under the terms of the Modified BSD License.

ARG repository
FROM ${repository}:base

LABEL maintainer="haobibo@gmail.com"


RUN source /opt/utils/script-utils.sh \
 && install_apt /opt/utils/install_list_core.apt

# Build and install tini, which will be entry point later...
RUN cd /tmp \
 && TINI_VERSION=$(wget --no-check-certificate -qO- https://github.com/krallin/tini/releases.atom | grep 'releases/tag' | head -1 ) \
 && TINI_VERSION=$(echo $TINI_VERSION | cut -d '"' -f6 | cut -d \/ -f8 ) \
 && wget -qO- "https://github.com/krallin/tini/archive/${TINI_VERSION}.zip" -O tini.zip && unzip -q /tmp/tini.zip \
 && cmake /tmp/tini-* && make install && mv /tmp/tini /usr/local/bin/tini && chmod +x /usr/local/bin/tini

ENV PATH=/opt/conda/bin:$PATH

## --> Install Python3 (Miniconda3), replace conda packages with pip source.
RUN source /opt/utils/script-setup.sh && setup_conda && install__clean

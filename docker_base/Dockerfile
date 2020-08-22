# Distributed under the terms of the Modified BSD License.

ARG BASE_REPO
ARG BASE_TAG
FROM ${BASE_REPO}:${BASE_TAG:-atom}

LABEL maintainer="haobibo@gmail.com"

COPY work /opt/utils/

RUN source      /opt/utils/script-utils.sh \
 && install_apt /opt/utils/install_list_core.apt

# Build and install tini, which will be entry point later...
RUN cd /tmp \
 && TINI_VERSION=$(wget --no-check-certificate -qO- https://github.com/krallin/tini/releases.atom | grep 'releases/tag' | head -1 ) \
 && TINI_VERSION=$(echo $TINI_VERSION | cut -d '"' -f6 | cut -d \/ -f8 ) \
 && wget -qO- "https://github.com/krallin/tini/archive/${TINI_VERSION}.zip" -O tini.zip && unzip -q /tmp/tini.zip \
 && cmake /tmp/tini-* && make install && mv /tmp/tini /usr/local/bin/tini && chmod +x /usr/local/bin/tini

ENV PATH=/opt/conda/bin:$PATH

## --> Install Python3 (Miniconda3), replace conda packages with pip source.
RUN source /opt/utils/script-setup.sh && setup_conda \
 # Replace system Python3 with Conda's Python
 && TO_DEL_1=$(/bin/python3.8 -c 'import sys; print(" ".join(sys.path))') \
 && TO_DEL_2=$(/usr/bin/python3.8 -c 'import sys; print(" ".join(sys.path))') \
 && rm -rf $(echo $TO_DEL_1 $TO_DEL_2) \
 && TO_REPLACE="/bin/python3;/bin/python3.8;/usr/bin/python3;/usr/bin/python3.8" \
 && for F in $(echo ${TO_REPLACE} | tr ";" "\n") ; do ( rm -f ${F} && ln -s /opt/conda/bin/python ${F} ) ; done \
 && install__clean

# Distributed under the terms of the Modified BSD License.

ARG BASE_NAMESPACE
ARG BASE_IMG="atom"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"

COPY work /opt/utils/

RUN source      /opt/utils/script-utils.sh \
 && install_apt /opt/utils/install_list_base.apt

# Build and install tini, which will be entry point later...
RUN cd /tmp \
 && TINI_VERSION=$(wget --no-check-certificate -qO- https://github.com/krallin/tini/releases.atom | grep 'releases/tag' | head -1 ) \
 && TINI_VERSION=$(echo $TINI_VERSION | cut -d '"' -f6 | cut -d \/ -f8 ) \
 && wget -qO- "https://github.com/krallin/tini/archive/${TINI_VERSION}.zip" -O tini.zip && unzip -q /tmp/tini.zip \
 && cmake /tmp/tini-* && make install && mv /tmp/tini /usr/bin/tini && chmod +x /usr/bin/tini

ENV PATH=/opt/conda/bin:$PATH

## --> Install Python3 (Miniconda3), replace conda packages with pip source.
RUN source /opt/utils/script-setup.sh && setup_conda \
 # Replace system Python3 with Conda's Python - note that /bin and /sbin are symlinks of /usr/bin in docker image ubuntu
 # && cp --verbose -rn /usr/lib/python3.8/* /opt/conda/lib/python3.8/ \
 # && mv /usr/share/pyshared/lsb_release.py /usr/bin/ \
 # && rm --verbose -rf $(/usr/bin/python3.8 -c 'import sys; print(" ".join(sys.path))') /usr/lib/python3* /usr/share/pyshared/ \
 # && ln -s /opt/conda/lib/python3.8 /usr/lib/ \
 # && TO_REPLACE="/usr/bin/python3;/usr/bin/python3.8" \
 # && for F in $(echo ${TO_REPLACE} | tr ";" "\n") ; do ( rm -f ${F} && ln -s /opt/conda/bin/python ${F} ) ; done \
 && install__clean

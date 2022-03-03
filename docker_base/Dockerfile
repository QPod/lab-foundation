# Distributed under the terms of the Modified BSD License.

ARG BASE_NAMESPACE
ARG BASE_IMG="atom"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"

ENV CONDA_PREFIX=/opt/conda/ \
    PATH=/opt/conda/bin:$PATH

RUN source /opt/utils/script-utils.sh \
 && source /opt/utils/script-setup.sh \
 && install_apt /opt/utils/install_list_base.apt \
 && echo "Install tini" \
 && setup_tini \
 && echo "Install Mamba, Python, and Conda:" \
 && mkdir -pv ${CONDA_PREFIX} \
 && setup_mamba && setup_conda_with_mamba && install__clean \
 && ln -sf /opt/conda/bin/python3 /usr/bin/python
#&& echo "Replace system Python3 with Conda's Python - note that /bin and /sbin are symlinks of /usr/bin in docker image ubuntu" \
#&& ln -sf /opt/conda/lib/python3.10 /opt/conda/lib/python3 \
#&& cp --verbose -rn /usr/lib/python3.*/* /opt/conda/lib/python3/ \
#&& mv /usr/share/pyshared/lsb_release.py /usr/bin/ \
#&& rm --verbose -rf $(/usr/bin/python3 -c 'import sys; print(" ".join(sys.path))') /usr/lib/python3* /usr/share/pyshared/ \
#&& ln -sf /opt/conda/lib/python3 /usr/lib/ \
#&& TO_REPLACE="/usr/bin/python3;/usr/bin/python3.10" \
#&& for F in $(echo ${TO_REPLACE} | tr ";" "\n") ; do ( rm -f ${F} && ln -s /opt/conda/bin/python ${F} ) ; done

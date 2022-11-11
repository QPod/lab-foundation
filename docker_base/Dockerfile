# Distributed under the terms of the Modified BSD License.

ARG BASE_NAMESPACE
ARG BASE_IMG="atom"
ARG PYTHON_VERSION="3.10"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"

ENV CONDA_PREFIX=/opt/conda
ENV PATH=$PATH:${CONDA_PREFIX}/bin

RUN source /opt/utils/script-setup.sh \
 && install_apt /opt/utils/install_list_base.apt \
 && echo "Install tini:" && setup_tini \
 && echo "Install Mamba:" && setup_mamba \
 && echo "Install Python, and Conda:" && setup_conda_with_mamba ${PYTHON_VERSION} \
 && echo "Replace system Python3 with conda Python - note that /bin and /sbin are symlinks of /usr/bin in docker image ubuntu" \
 && PYTHON_PTH_FILE=$("${CONDA_PREFIX}"/bin/python3 -c 'import sys;print(sys.path[-1]+"/usr_share.pth")') \
 && echo "/usr/share/pyshared/" >>  "${PYTHON_PTH_FILE}" \
 && echo "/usr/share/python3/"  >>  "${PYTHON_PTH_FILE}" \
 && rm -rf $(/usr/bin/python3 -c 'import sys; print(" ".join(i for i in sys.path if "python" in i))') /usr/bin/python3* \
 && ln -sf "${CONDA_PREFIX}"/bin/python /usr/bin/python \
 && ln -sf "${CONDA_PREFIX}"/bin/python3.* /usr/bin/ \
 && install__clean

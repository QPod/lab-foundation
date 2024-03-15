# Distributed under the terms of the Modified BSD License.

ARG BASE_NAMESPACE
ARG BASE_IMG="atom"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}
LABEL maintainer="haobibo@gmail.com"

ARG PYTHON_VERSION="3.11"

ENV CONDA_PREFIX=/opt/conda

RUN set -x && source /opt/utils/script-setup.sh \
 && export PATH=$PATH:${CONDA_PREFIX}/bin \
 && install_apt /opt/utils/install_list_base.apt \
 && echo "Install tini:" && setup_tini \
 && export HAS_SYS_PY3=$( [ -x "$(command -v python3)" ] && echo 'true' || echo 'false' ) && echo "@ Detect OS Py3 installed: $HAS_SYS_PY3" \
 && echo "Install Mamba:" && setup_mamba \
 && echo "Install Python ${PYTHON_VERSION} and conda:" && setup_conda_with_mamba ${PYTHON_VERSION} \
 && $($HAS_SYS_PY3) && ( \
       echo "Replace system Python3 with conda Python - note that /bin and /sbin are symlinks of /usr/bin in docker image ubuntu" \
    && PYTHON_VERSION_DEFAULT=$(py3versions -v -i) \
    && sed -i "s/${PYTHON_VERSION_DEFAULT}/${PYTHON_VERSION}/g" /usr/share/python3/debian_defaults \
    && PYTHON_PTH_FILE=$("${CONDA_PREFIX}"/bin/python3 -c 'import sys;print(sys.path[-1]+"/usr_share.pth")') \
    && echo "/usr/share/pyshared/" >>  "${PYTHON_PTH_FILE}" \
    && echo "/usr/share/python3/"  >>  "${PYTHON_PTH_FILE}" \
    && rm -rf $(/usr/bin/python3 -c 'import sys; print(" ".join(i for i in sys.path if "python" in i))') /usr/bin/python3* /usr/lib/python${PYTHON_VERSION} \
 ) || true \
 && ln -sf "${CONDA_PREFIX}"/lib/python${PYTHON_VERSION} /usr/lib/ \
 && ln -sf "${CONDA_PREFIX}"/bin/python3.* /usr/bin/ \
 && ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python \
 && ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 \
 && py3versions -d && lsb_release -a \
 && install__clean && fix_permission 0 /opt

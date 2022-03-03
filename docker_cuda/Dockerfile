# Distributed under the terms of the Modified BSD License.

ARG BASE_NAMESPACE
ARG BASE_IMG="cuda:latest"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"

# For cuda version 10.0, the image is solely serverd for legacy tensorflow 1.15, which requires python 3.7
# For tensorflow 2.x or torch, python>=3.9 is supported.
RUN echo ${CUDA_VERSION} && nvcc --version \
 && source /opt/utils/script-setup.sh && setup_nvtop \
 && [[ ${CUDA_VERSION} == *"10.0"* ]] && mamba install -yq python=3.7 || true \
 && install__clean

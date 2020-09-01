# Distributed under the terms of the Modified BSD License.

# CUDA  base:    https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/base/Dockerfile
# CUDA  runtime: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/runtime/Dockerfile
# CUDNN runtime: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/runtime/cudnn8/Dockerfile
# CUDA  devel:   https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/devel/Dockerfile
# CUDNN devel    https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/devel/cudnn8/Dockerfile

ARG BASE_NAMESPACE
ARG BASE_IMG="base"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"

ARG ARG_CUDA_RUNTIME=true
ARG ARG_CUDNN_RUNTIME=true
ARG ARG_CUDA_DEVEL=true
ARG ARG_CUDNN_DEVEL=true

ENV CUDA_VER 11.0
ENV CUDA_VERSION ${CUDA_VER}.221
ENV CUDA_PKG_VERSION 11-0=$CUDA_VERSION-1
ENV NCCL_VERSION 2.7.8
ENV CUDNN_VERSION 8.0.2.39
ENV CUBLAS_VERSION 11.2.0.252-1

ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    NVIDIA_REQUIRE_CUDA="cuda>=${CUDA_VER} brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441" \
    PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH} \
    LIBRARY_PATH=/usr/local/cuda/lib64/stubs \
    LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

# Installing CUDA base
RUN  curl -sL "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub"  | apt-key add - \
  && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /"             > /etc/apt/sources.list.d/cuda.list \
  && echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION cuda-compat-11-0 \
  && ln -s cuda-$CUDA_VER /usr/local/cuda \
  && echo "/usr/local/nvidia/lib"   >> /etc/ld.so.conf.d/nvidia.conf \
  && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# If installing CUDA runtime
RUN  ${ARG_CUDA_RUNTIME:-false} \
  && apt-get install -y --no-install-recommends \
        cuda-libraries-11-0=11.0.3-1  libnpp-11-0=11.1.0.245-1  cuda-nvtx-11-0=11.0.167-1 \
        libcublas-11-0=11.2.0.252-1   libnccl2=$NCCL_VERSION-1+cuda11.0 \
  || true

# If installing CUDNN runtime
RUN  ${ARG_CUDNN_RUNTIME:false} \
  && apt-get install -y --no-install-recommends libcudnn8=$CUDNN_VERSION-1+cuda11.0 \
  || true

# If installing CUDA devel
RUN  ${ARG_CUDA_DEVEL:false} \
  && apt-get install -y --no-install-recommends \
        cuda-minimal-build-11-0=11.0.3-1 cuda-libraries-dev-11-0=11.0.3-1  cuda-command-line-tools-11-0=11.0.3-1 \
        cuda-nvml-dev-11-0=11.0.167-1    libcublas-dev-11-0=${CUBLAS_VERSION} \
        libnccl-dev=2.7.8-1+cuda11.0     cuda-nvprof-11-0=11.0.221-1 \
        libnpp-dev-11-0=11.1.0.245-1     libcusparse-11-0=11.1.1.245-1     libcusparse-dev-11-0=11.1.1.245-1 \
  || true

# If installing CUDNN devel
RUN  ${ARG_CUDNN_DEVEL:false} \
  && apt-get install -y --no-install-recommends \
        libcudnn8=$CUDNN_VERSION-1+cuda11.0  libcudnn8-dev=$CUDNN_VERSION-1+cuda11.0 \
  || true

# Install Utilities `nvtop`
RUN  cd /tmp \
  && apt-get -y update --fix-missing && apt-get -qq install -y --no-install-recommends libncurses5-dev \
  && git clone https://github.com/Syllo/nvtop.git \
  && mkdir -p nvtop/build && cd nvtop/build \
  && LIB_PATH=`find / -name "libnvidia-ml*" 2>/dev/null` \
  && cmake .. -DCMAKE_LIBRARY_PATH="`dirname $LIB_PATH`" .. \
  && make && make install \
  && apt-get -qq remove -y libncurses5-dev

RUN nvcc --version \
 && source /opt/utils/script-utils.sh && install__clean

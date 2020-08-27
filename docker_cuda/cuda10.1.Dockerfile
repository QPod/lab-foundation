# Distributed under the terms of the Modified BSD License.

# CUDA  base:    https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist/ubuntu18.04/10.1/base/Dockerfile
# CUDA  runtime: https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist/ubuntu18.04/10.1/runtime/Dockerfile
# CUDNN runtime: https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist/ubuntu18.04/10.1/runtime/cudnn7/Dockerfile
# CUDA  devel:   https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist/ubuntu18.04/10.1/devel/Dockerfile
# CUDNN devel    https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist/ubuntu18.04/10.1/devel/cudnn7/Dockerfile

ARG BASE_NAMESPACE
ARG BASE_IMG="base"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"

ARG ARG_CUDA_RUNTIME=true
ARG ARG_CUDNN_RUNTIME=true
ARG ARG_CUDA_DEVEL=true
ARG ARG_CUDNN_DEVEL=true

ENV CUDA_VER 10.1
ENV CUDA_VERSION ${CUDA_VER}.243
ENV CUDA_PKG_VERSION 10-1=$CUDA_VERSION-1
ENV NCCL_VERSION 2.4.8
ENV CUDNN_VERSION 7.6.5.32
ENV CUBLAS_VERSION 10.2.1.243-1

ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    NVIDIA_REQUIRE_CUDA="cuda>=${CUDA_VER} brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411" \
    PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH} \
    LIBRARY_PATH=/usr/local/cuda/lib64/stubs \
    LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

# Installing CUDA base
RUN  wget -qO- "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub"    | apt-key add - \
  && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /"             > /etc/apt/sources.list.d/cuda.list \
  && echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION cuda-compat-10-1 \
  && ln -s cuda-$CUDA_VER /usr/local/cuda \
  && echo "/usr/local/nvidia/lib"   >> /etc/ld.so.conf.d/nvidia.conf \
  && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# If installing CUDA runtime
RUN  ${ARG_CUDA_RUNTIME:-false} \
  && apt-get install -y --no-install-recommends \
        cuda-libraries-$CUDA_PKG_VERSION           cuda-nvtx-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-1+cuda$CUDA_VER     libcublas10=$CUBLAS_VERSION \
  && apt-mark hold libnccl2 \
  || true

# If installing CUDNN runtime
RUN  ${ARG_CUDNN_RUNTIME:false} \
  && apt-get install -y --no-install-recommends \
        libcudnn7=$CUDNN_VERSION-1+cuda$CUDA_VER \
  && apt-mark hold libcudnn7 \
  || true

# If installing CUDA devel
RUN  ${ARG_CUDA_DEVEL:false} \
  && apt-get install -y --no-install-recommends \
        cuda-libraries-dev-$CUDA_PKG_VERSION  cuda-nvml-dev-$CUDA_PKG_VERSION \
        cuda-minimal-build-$CUDA_PKG_VERSION  cuda-command-line-tools-$CUDA_PKG_VERSION \
        libnccl-dev=$NCCL_VERSION-1+cuda$CUDA_VER  libcublas-dev=$CUBLAS_VERSION \
  || true

# If installing CUDNN devel
RUN  ${ARG_CUDNN_DEVEL:false} \
  && apt-get install -y --no-install-recommends \
        libcudnn7=$CUDNN_VERSION-1+cuda$CUDA_VER libcudnn7-dev=$CUDNN_VERSION-1+cuda$CUDA_VER \
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

RUN type nvidia-smi \
 && source /opt/utils/script-utils.sh && install__clean

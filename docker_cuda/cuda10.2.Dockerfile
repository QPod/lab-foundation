# Distributed under the terms of the Modified BSD License.

# CUDA  base:    https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/10.2/ubuntu18.04-x86_64/base/Dockerfile
# CUDA  runtime: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/10.2/ubuntu18.04-x86_64/runtime/Dockerfile
# CUDNN runtime: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/10.2/ubuntu18.04-x86_64/runtime/cudnn8/Dockerfile
# CUDA  devel:   https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/10.2/ubuntu18.04-x86_64/devel/Dockerfile
# CUDNN devel    https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/10.2/ubuntu18.04-x86_64/devel/cudnn8/Dockerfile

ARG BASE_NAMESPACE
ARG BASE_IMG="base"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"

ARG ARG_CUDA_RUNTIME=true
ARG ARG_CUDNN_RUNTIME=true
ARG ARG_CUDA_DEVEL=true
ARG ARG_CUDNN_DEVEL=true

ENV CUDA_VER 10.2
ENV CUDA_VERSION ${CUDA_VER}.89
ENV CUDA_PKG_VERSION 10-2=$CUDA_VERSION-1
ENV NCCL_VERSION 2.7.8
ENV CUDNN_VERSION 8.0.2.39
ENV CUBLAS_VERSION 10.2.2.89-1

ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    NVIDIA_REQUIRE_CUDA="cuda>=${CUDA_VER} brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441" \
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
        cuda-cudart-$CUDA_PKG_VERSION cuda-compat-10-2 \
  && ln -s cuda-$CUDA_VER /usr/local/cuda \
  && echo "/usr/local/nvidia/lib"   >> /etc/ld.so.conf.d/nvidia.conf \
  && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# If installing CUDA runtime
RUN  ${ARG_CUDA_RUNTIME:-false} \
  && apt-get install -y --no-install-recommends \
        cuda-libraries-$CUDA_PKG_VERSION cuda-nvtx-$CUDA_PKG_VERSION cuda-npp-$CUDA_PKG_VERSION \
        libcublas10=$CUBLAS_VERSION libnccl2=$NCCL_VERSION-1+cuda$CUDA_VER \
  || true

# If installing CUDNN runtime
RUN  ${ARG_CUDNN_RUNTIME:false} \
  && apt-get install -y --no-install-recommends libcudnn8=$CUDNN_VERSION-1+cuda$CUDA_VER \
  || true

# If installing CUDA devel
RUN  ${ARG_CUDA_DEVEL:false} \
  && apt-get install -y --no-install-recommends \
        cuda-nvml-dev-$CUDA_PKG_VERSION       cuda-command-line-tools-$CUDA_PKG_VERSION \
        cuda-nvprof-$CUDA_PKG_VERSION         cuda-npp-dev-$CUDA_PKG_VERSION \
        cuda-libraries-dev-$CUDA_PKG_VERSION  cuda-minimal-build-$CUDA_PKG_VERSION   \
        libcublas-dev=$CUBLAS_VERSION         libnccl-dev=$NCCL_VERSION-1+cuda$CUDA_VER \
  || true

# If installing CUDNN devel
RUN  ${ARG_CUDNN_DEVEL:false} \
  &&  apt-get install -y --no-install-recommends \
        libcudnn8=$CUDNN_VERSION-1+cuda$CUDA_VER libcudnn8-dev=$CUDNN_VERSION-1+cuda$CUDA_VER \
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

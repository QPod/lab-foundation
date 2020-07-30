# Distributed under the terms of the Modified BSD License.

# CUDA  base:    https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/base/Dockerfile
# CUDA  runtime: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/runtime/Dockerfile
# CUDNN runtime: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/runtime/cudnn8/Dockerfile
# CUDA  devel:   https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/devel/Dockerfile
# CUDNN devel    https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu18.04-x86_64/devel/cudnn8/Dockerfile

ARG repository
FROM ${repository}:base

LABEL maintainer="haobibo@gmail.com"

ARG ARG_CUDA_RUNTIME=true
ARG ARG_CUDNN_RUNTIME=true
ARG ARG_CUDA_DEVEL=true
ARG ARG_CUDNN_DEVEL=true

ENV CUDA_VER 11.0
ENV CUDA_VERSION ${CUDA_VER}.194
ENV CUDA_PKG_VERSION 11-0=$CUDA_VERSION-1
ENV NCCL_VERSION 2.7.3
ENV CUDNN_VERSION 8.0.0.180
ENV CUBLAS_VERSION 11.1.0.229-1

ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    NVIDIA_REQUIRE_CUDA="cuda>=${CUDA_VER} brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441" \
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
        cuda-cudart-$CUDA_PKG_VERSION cuda-compat-11-0 \
  && ln -s cuda-$CUDA_VER /usr/local/cuda \
  && echo "/usr/local/nvidia/lib"   >> /etc/ld.so.conf.d/nvidia.conf \
  && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# If installing CUDA runtime
RUN  ${ARG_CUDA_RUNTIME:-false} \
  && apt-get install -y --no-install-recommends \
        cuda-libraries-11-0=11.0.2-1  libnpp-11-0=11.0.0.218-1  cuda-nvtx-11-0=11.0.167-1 \
  && wget -nv https://developer.download.nvidia.com/compute/redist/nccl/v2.7/nccl_${NCCL_VERSION}-1+cuda11.0_x86_64.txz -O /tmp/nccl1.txz \
  && tar --no-same-owner --keep-old-files --lzma -xvf /tmp/nccl1.txz -C /usr/local/cuda/lib64/ --strip-components=2 --wildcards '*/lib/libnccl.so.*' \
  && tar --no-same-owner --keep-old-files --lzma -xvf /tmp/nccl1.txz -C /usr/lib/pkgconfig/    --strip-components=3 --wildcards '*/lib/pkgconfig/*'  \
  && ldconfig \
  || true

# If installing CUDNN runtime
RUN  ${ARG_CUDNN_RUNTIME:false} \
  && wget -nv "https://developer.download.nvidia.com/compute/redist/cudnn/v8.0.0/Ubuntu18_04-x64/libcudnn8_${CUDNN_VERSION}-1+cuda11.0_amd64.deb" -O /tmp/cudnn1.deb \
  && dpkg -i /tmp/cudnn1.deb \
  || true

# If installing CUDA devel
RUN  ${ARG_CUDA_DEVEL:false} \
  && apt-get install -y --no-install-recommends \
        cuda-minimal-build-11-0=11.0.2-1 cuda-libraries-dev-11-0=11.0.2-1  cuda-command-line-tools-11-0=11.0.2-1 \
        cuda-nvml-dev-11-0=11.0.167-1    libcublas-dev-11-0=${CUBLAS_VERSION} \
        cuda-nvcc-11-0=11.0.194-1        cuda-nvprof-11-0=11.0.194-1 \
        libnpp-dev-11-0=11.1.0.218-1     libcusparse-11-0=11.1.0.218-1     libcusparse-dev-11-0=11.1.0.218-1 \
  && wget -nv https://developer.download.nvidia.com/compute/redist/nccl/v2.7/nccl_${NCCL_VERSION}-1+cuda11.0_x86_64.txz -O /tmp/nccl2.txz \
  && tar --no-same-owner --keep-old-files --lzma -xvf /tmp/nccl2.txz -C /usr/local/cuda/include/ --strip-components=2 --wildcards '*/include/*'      \
  && tar --no-same-owner --keep-old-files --lzma -xvf /tmp/nccl2.txz -C /usr/local/cuda/lib64/   --strip-components=2 --wildcards '*/lib/libnccl.so' \
  || true

# If installing CUDNN devel
RUN  ${ARG_CUDNN_DEVEL:false} \
  && wget -nv "https://developer.download.nvidia.com/compute/redist/cudnn/v8.0.0/Ubuntu18_04-x64/libcudnn8_${CUDNN_VERSION}-1+cuda11.0_amd64.deb" -O  /tmp/cudnn2.deb \
  && wget -nv "https://developer.download.nvidia.com/compute/redist/cudnn/v8.0.0/Ubuntu18_04-x64/libcudnn8-dev_${CUDNN_VERSION}-1+cuda11.0_amd64.deb" -O /tmp/cudnn-dev.deb \
  && dpkg -i /tmp/cudnn2.deb && dpkg -i /tmp/cudnn-dev.deb \
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

# Clean up and display components version information...
RUN  source /opt/utils/script-utils.sh \
  && install__clean && cd \
  && echo "@ Version of image: building finished at:" `date` `uname -a` \
  && echo "@ System environment variables:" `printenv`

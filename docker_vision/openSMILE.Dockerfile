# Distributed under the terms of the Modified BSD License.

ARG repository
ARG base
FROM ${repository}:${base:-base}

LABEL maintainer="haobibo@gmail.com"

COPY work /opt/utils/

RUN cd /tmp      && source /opt/utils/script-utils.sh \
    && install_apt /opt/utils/install_list_openSMILE.apt \
    ## Download
    && install_tar_gz https://github.com/opencv/opencv/archive/4.1.0.tar.gz \
    && mv /opt/opencv-* /tmp/opencv \
    && install_tar_gz http://www.audeering.com/download/opensmile-2-3-0-tar-gz/?wpdmdl=4782 \
    && mv /opt/opensmile-* /tmp/openSMILE \
    ## Build OpenCV
    && cd /tmp/opencv && mkdir -p build && cd build \
    && cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_TBB=ON \
    -D WITH_EIGEN=ON \
    -D WITH_CUDA=OFF \
    -D PYTHON_DEFAULT_EXECUTABLE=`which python` \
    -D BUILD_SHARED_LIBS=ON  .. \
    && make -j8 && make install \
    ## Build OpenSMILE
    && cd /tmp/openSMILE \
    && sed -i '117s/(char)/(unsigned char)/g' src/include/core/vectorTransform.hpp \
    && ./buildWithPortAudio.sh -p /opt/openSMILE \
	&& ./buildStandalone.sh -p /opt/openSMILE \
    && mv config script /opt/openSMILE \
    ## Clean Up
    && cd /opt/openSMILE && install__clean

WORKDIR /opt/openSMILE

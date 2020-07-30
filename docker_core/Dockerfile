# Distributed under the terms of the Modified BSD License.

ARG repository
FROM ${repository}:base

LABEL maintainer="haobibo@gmail.com"

ENV PATH=/opt/conda/bin:$PATH

RUN  source /opt/utils/script-*.sh \
  # --> Install Python3 (Miniconda3), replace conda packages with pip source.
  && setup_conda \
  # --> Clean up and display components version information...
  && install__clean && cd \
  && echo "@ Version of image: building finished at:" `date` `uname -a` \
  && echo "@ System environment variables:" `printenv`

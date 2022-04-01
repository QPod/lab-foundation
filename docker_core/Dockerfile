# Distributed under the terms of the Modified BSD License.

ARG BASE_NAMESPACE
ARG BASE_IMG="base"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}


LABEL maintainer="haobibo@gmail.com"

ARG ARG_PROFILE_NODEJS

ARG ARG_PROFILE_JAVA

# base,datascience,rstudio,rshiny
ARG ARG_PROFILE_R

# base,database,datascience,nlp,cv,bioinfo
ARG ARG_PROFILE_PYTHON

ARG ARG_PROFILE_GO

ARG ARG_PROFILE_JULIA

ARG ARG_PROFILE_OCTAVE

# base,cjk
ARG ARG_PROFILE_LATEX

COPY work /opt/utils/

# NodeJS is required to build JupyterLab Extensions later
RUN [[ ${ARG_PROFILE_NODEJS} == *"base"* ]] && source /opt/utils/script-setup.sh && setup_node   || true

# If installing Java environment - notice that Java can be dependency for some other packages like rJava
RUN source /opt/utils/script-setup.sh \
 && for profile in $(echo $ARG_PROFILE_JAVA | tr "," "\n") ; do ( setup_java_${profile} || true ) ; done

# If installing LaTex and LaTex CJK packages.
RUN source /opt/utils/script-utils.sh \
 && for profile in $(echo $ARG_PROFILE_LATEX | tr "," "\n") ; do ( install_apt "/opt/utils/install_list_latex_${profile}.apt" || true ) ; done

# If installing R environment - put this after Java ready to configure rJava
RUN source /opt/utils/script-setup.sh \
 && for profile in $(echo $ARG_PROFILE_R | tr "," "\n") ; do ( setup_R_${profile} || true ) ; done

# If on a x86_64 architecture and install data science pkgs, install MKL for acceleration; Installing conda packages if provided.
RUN ( [[ `arch` == "x86_64" && ${ARG_PROFILE_PYTHON} == *"datascience"* ]] && ( echo "mkl" >> /opt/utils/install_list.conda ) || true ) \
 && source /opt/utils/script-utils.sh && ( install_conda /opt/utils/install_list_core.conda || true )

# If installing Python packages
RUN source /opt/utils/script-utils.sh \
 && ( [[ ${ARG_PROFILE_PYTHON} == *"datascience"* ]] \
      && ( which R          && echo "rpy2  % Install rpy2 if R exists"    >> /opt/utils/install_list_PY_datascience.pip || true ) \
      && ( which java       && echo "py4j  % Install py4j if Java exists" >> /opt/utils/install_list_PY_datascience.pip || true ) \
      || true ) \
 && for profile in $(echo $ARG_PROFILE_PYTHON | tr "," "\n") ; do ( install_pip "/opt/utils/install_list_PY_${profile}.pip" || true ) ; done \
 # Handle tensorflow installation 1.x/2.x, cpu/gpu: https://www.tensorflow.org/install/source#gpu
 && ( [[ ${ARG_PROFILE_PYTHON} == *"tf"* ]] \
      && TF=$( [ -x "$(command -v nvcc)" ] && echo "tensorflow-gpu" || echo "tensorflow") \
      && V=$([[ ${ARG_PROFILE_PYTHON} == *"tf1"* ]] && echo "1" || echo "2" ) \
      && pip install --pre -U "${TF}==${V}.*" \
      || true ) \
 # Handle pytorch installation 1.x only, cpu/gpu: https://pytorch.org/get-started/locally/
 && ( [[ ${ARG_PROFILE_PYTHON} == *"torch"* ]] \
      && CUDA_VER=$(echo "${CUDA_VERSION:0:4}" | sed 's/\.//' ) \
      && IDX=$( [ -x "$(command -v nvcc)" ] && echo "cu${CUDA_VER:-113}" || echo "cpu" ) \
      && pip install --pre -U torch -f "https://download.pytorch.org/whl/${IDX}/torch_stable.html" \
      || true )

RUN [[ ${ARG_PROFILE_GO}     == *"base"* ]] && source /opt/utils/script-setup.sh && setup_GO     || true

RUN [[ ${ARG_PROFILE_JULIA}  == *"base"* ]] && source /opt/utils/script-setup.sh && setup_julia  || true

RUN [[ ${ARG_PROFILE_OCTAVE} == *"base"* ]] && source /opt/utils/script-setup.sh && setup_octave || true

# Clean up and display components version information...
RUN source /opt/utils/script-utils.sh && install__clean && list_installed_packages

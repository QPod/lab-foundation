# Distributed under the terms of the Modified BSD License.

ARG BASE_NAMESPACE
ARG BASE_IMG="base"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"

ARG ARG_PROFILE_NODEJS

# base,datascience,rstudio,rshiny
ARG ARG_PROFILE_R

# base,database,datascience,nlp,cv,bioinfo
ARG ARG_PROFILE_PYTHON
ARG ARG_PROFILE_GO
ARG ARG_PROFILE_JULIA
ARG ARG_PROFILE_RUST
ARG ARG_PROFILE_OCTAVE

# base,cjk
ARG ARG_PROFILE_LATEX

ARG ARG_PROFILE_JAVA
ARG VERSION_JDK

SHELL ["/bin/bash", "--login", "-o", "pipefail", "-c"]

COPY work /opt/utils/

RUN set -eux \
 && source /opt/utils/script-setup.sh \
 # -----------------------------
 && echo "NodeJS is required to build some components like JupyterLab Extensions later" \
 && if echo "${ARG_PROFILE_NODEJS}" | grep -q "base" ; then \
      setup_node ; \
    else \
      echo "Skip NodeJS install" ; \
    fi \
 # -----------------------------
 && echo "If installing Java environment - notice that Java can be dependency for some other packages like rJava" \
 && export VERSION_JDK=${VERSION_JDK:-11} \
 && for profile in $(echo $ARG_PROFILE_JAVA | tr "," "\n") ; do ( setup_java_${profile} ) ; done \
 # -----------------------------
 && echo "If installing LaTex and LaTex CJK packages." \
 && for profile in $(echo $ARG_PROFILE_LATEX | tr "," "\n") ; do ( install_apt "/opt/utils/install_list_latex_${profile}.apt" ) ; done \
 # -----------------------------
 && echo "If installing R environment - put this after Java ready to configure rJava" \
 && source /opt/utils/script-setup-R.sh \
 && for profile in $(echo $ARG_PROFILE_R | tr "," "\n") ; do ( setup_R_${profile} ) ; done \
 # -----------------------------
 && echo "If on a x86_64 architecture: 1) if mkl specified, install nomkl; 2) install conda packages as specified." \
 && if echo $(arch) | grep -q "x86_64" ; then \
    echo "mkl"   >> /opt/utils/install_list_core.conda && echo "Install mkl." ; \
  else \
    echo "nomkl" >> /opt/utils/install_list_core.conda && echo "Install nomkl." ; \
  fi \
  && ln -sf /opt/utils/install_list_core.conda /opt/utils/install_list_PY_mkl.pip \
  && install_conda /opt/utils/install_list_core.conda \
 # -----------------------------
 && echo "If installing Python packages" \
 && ( $(grep -q "datascience" <<< "${ARG_PROFILE_PYTHON}") && ( \
         ( which R     && echo "rpy2  % Install rpy2 if R exists"    >> /opt/utils/install_list_PY_datascience.pip || echo "Skip rpy2 install" ) \
      && ( which java  && echo "py4j  % Install py4j if Java exists" >> /opt/utils/install_list_PY_datascience.pip || echo "Skip py4j install" ) \
    ) || echo "Skip Python datascience packages install" ) \
 # -----------------------------
 && echo "Handle tensorflow installation 1.x/2.x, cpu/gpu: https://www.tensorflow.org/install/source#gpu" \
 && ( $(grep -q "tf" <<< "${ARG_PROFILE_PYTHON}") && ( \
         V=$($(grep -q "tf1" <<< "${ARG_PROFILE_PYTHON}") && echo "1" || echo "2" ) \
         TF=$( [ "$V" == "1" ] && echo "tensorflow-gpu" || echo "tensorflow") \
      && echo "${TF}==${V}.*" > "/opt/utils/install_list_PY_tf${V}.pip" \
    ) || echo "Skipping tf install" ) \
 # -----------------------------
 && echo "Handle pytorch installation 1.x only, cpu/gpu: https://pytorch.org/get-started/locally/" \
 && ( $(grep -q "torch" <<< "${ARG_PROFILE_PYTHON}") && ( \
         CUDA_VER=$(echo "${CUDA_VERSION:0:4}" | sed 's/\.//' ) \
      && echo "If CUDA version < 11.7, install pytorch 1.x, else install pytorch 2.x; if cuda doesn't exist, install pytorch 2.x" \
      && export CUDA_VER_TORCH="117" && V=$([[ "${CUDA_VER:-999}" -lt "${CUDA_VER_TORCH}" ]] && echo "torch<2" || echo "torch") \
      && IDX=$( [ -x "$(command -v nvcc)" ] && echo "cu${CUDA_VER:-117}" || echo "cpu" ) \
      && export PIP_FIND_LINKS="https://download.pytorch.org/whl/${IDX}/torch_stable.html ${PIP_FIND_LINKS:-}" \
      && echo "${V}" > /opt/utils/install_list_PY_torch.pip \
    ) || echo "Skipping pytorch install" ) \
 # -----------------------------
 && echo "Handle paddle installation, cpu/gpu: https://www.paddlepaddle.org.cn/" \
 && if $(grep -q "paddle" <<< "${ARG_PROFILE_PYTHON}") ; then \
         URL_PYPI_PADDLE="https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html" \
      && export PIP_FIND_LINKS="${URL_PYPI_PADDLE} ${PIP_FIND_LINKS:-}" \
      && CUDA_VER=$(echo "${CUDA_VERSION:0:4}" | sed 's/\.//' ) \
      && PADDLE=$( [ -x "$(command -v nvcc)" ] && echo "paddlepaddle-gpu" || echo "paddlepaddle") \
      && PADDLE_VER=$(pip index versions ${PADDLE} -f ${URL_PYPI_PADDLE} | grep 'Available' | cut -d ":" -f 2 | tr ', ' '\n' | grep ${CUDA_VER:-'.'} | head -n 1) \
      && V=$(echo ${PADDLE}==${PADDLE_VER}) && echo "to install paddle: ${V}" \
      && echo "${V}" > /opt/utils/install_list_PY_paddle.pip ; \
    else \
         echo "Skip paddle install" ; \
    fi \
 # -----------------------------
 && echo "PIP_FIND_LINKS=${PIP_FIND_LINKS:-default}" \
 && for profile in $(echo $ARG_PROFILE_PYTHON | tr "," "\n") ; do ( echo "Pip install for ${profile}" ; install_pip "/opt/utils/install_list_PY_${profile}.pip" ; ) ; done \
 # -----------------------------
 && if echo "${ARG_PROFILE_GO}" | grep -q "base" ; then \
       echo "Installing GO: ${ARG_PROFILE_GO}" && setup_GO ; \
    else \
       echo "Skip installing GO" ; \
    fi \
 # -----------------------------
 && if echo "${ARG_PROFILE_RUST}" | grep -q "base" ; then \
       echo "Installing rust: ${ARG_PROFILE_RUST}" && setup_rust ; \
    else \
       echo "Skip installing rust" ; \
    fi \
 # -----------------------------
 && if echo "${ARG_PROFILE_JULIA}" | grep -q "base" ; then \
       echo "Installing julia: ${ARG_PROFILE_JULIA}" && setup_julia ; \
    else \
       echo "Skip installing julia" ; \
    fi \
 # -----------------------------
 && if echo "${ARG_PROFILE_OCTAVE}" | grep -q "base" ; then \
       echo "Installing Octave: ${ARG_PROFILE_OCTAVE}" && setup_octave ; \
    else \
       echo "Skip installing octave" ; \
    fi \
 # -----------------------------
 && echo "Clean up and display components version information..." \
 && list_installed_packages && install__clean

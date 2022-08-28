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
RUN $(grep -q "base" <<< "${ARG_PROFILE_NODEJS}") && ( \
      source /opt/utils/script-setup.sh && setup_node \
    ) || echo "Skip NodeJS install"

# If installing Java environment - notice that Java can be dependency for some other packages like rJava
RUN source /opt/utils/script-setup.sh \
 && for profile in $(echo $ARG_PROFILE_JAVA | tr "," "\n") ; do ( setup_java_${profile} ) ; done

# If installing LaTex and LaTex CJK packages.
RUN source /opt/utils/script-utils.sh \
 && for profile in $(echo $ARG_PROFILE_LATEX | tr "," "\n") ; do ( install_apt "/opt/utils/install_list_latex_${profile}.apt" ) ; done

# If installing R environment - put this after Java ready to configure rJava
RUN source /opt/utils/script-setup.sh \
 && for profile in $(echo $ARG_PROFILE_R | tr "," "\n") ; do ( setup_R_${profile} ) ; done

# If on a x86_64 architecture and install data science pkgs, install MKL for acceleration; Installing conda packages if provided.
RUN $(grep -q "x86_64" <<< `arch`) && $(grep -q "datascience" <<< "${ARG_PROFILE_PYTHON}") && ( echo "mkl" >> /opt/utils/install_list.conda ) || echo "Skip MLK install." \
 && source /opt/utils/script-utils.sh && install_conda /opt/utils/install_list_core.conda

# If installing Python packages
RUN source /opt/utils/script-utils.sh \
 && ( $(grep -q "datascience" <<< "${ARG_PROFILE_PYTHON}") && ( \
         ( which R     && echo "rpy2  % Install rpy2 if R exists"    >> /opt/utils/install_list_PY_datascience.pip || echo "Skip rpy2 install" ) \
      && ( which java  && echo "py4j  % Install py4j if Java exists" >> /opt/utils/install_list_PY_datascience.pip || echo "Skip py4j install" ) \
    ) || echo "Skip Python datascience packages install" ) \
 && for profile in $(echo $ARG_PROFILE_PYTHON | tr "," "\n") ; do ( echo "Pip install for ${profile}" ; install_pip "/opt/utils/install_list_PY_${profile}.pip" ; ) ; done \
 #  Handle tensorflow installation 1.x/2.x, cpu/gpu: https://www.tensorflow.org/install/source#gpu
 && ( $(grep -q "tf" <<< "${ARG_PROFILE_PYTHON}") && ( \
         TF=$( [ -x "$(command -v nvcc)" ] && echo "tensorflow-gpu" || echo "tensorflow") \
      && V=$($(grep -q "tf1" <<< "${ARG_PROFILE_PYTHON}") && echo "1" || echo "2" ) \
      && pip install --pre -U "${TF}==${V}.*" \
    ) || echo "Skip tf install" ) \
 #  Handle pytorch installation 1.x only, cpu/gpu: https://pytorch.org/get-started/locally/
 && ( $(grep -q "torch" <<< "${ARG_PROFILE_PYTHON}") && ( \
         CUDA_VER=$(echo "${CUDA_VERSION:0:4}" | sed 's/\.//' ) \
      && IDX=$( [ -x "$(command -v nvcc)" ] && echo "cu${CUDA_VER:-113}" || echo "cpu" ) \
      && pip install --pre -U torch -f "https://download.pytorch.org/whl/${IDX}/torch_stable.html" \
    ) || echo "Skip pytorch install" ) \
 #  Handle paddle installation, cpu/gpu: https://www.paddlepaddle.org.cn/
 #  URL_PADDLE=$(curl -sL "https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html" |tr "<>" "\n" | grep "${PADDLE_VER}" | grep href | cut -d '=' -f 2)
 && ( $(grep -q "paddle" <<< "${ARG_PROFILE_PYTHON}") && ( \
         PADDLE=$( [ -x "$(command -v nvcc)" ] && echo "paddlepaddle-gpu" || echo "paddlepaddle") \
      && PADDLE_VER=$(pip index versions ${PADDLE} | grep '(' | cut -d "(" -f 2  | tr -d ')[:space:]') \
      && CUDA_VER=$(echo "${CUDA_VERSION:0:4}" | sed 's/\.//' ) \
      && V=$($(grep -q "11" <<< "${CUDA_VER}") && echo ".post${CUDA_VER}" || echo "" ) \
      && V=$(echo ${PADDLE}==${PADDLE_VER}${V}) && echo "to install paddle: ${V}" \
      && pip install pip==21.3.1 && pip --version \
      && pip install ${V} -f "https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html" \
      && pip install -U pip \
    ) || echo "Skip paddle install" )


RUN $(grep -q "base" <<< "${ARG_PROFILE_GO}")     && ( source /opt/utils/script-setup.sh && setup_GO     ) || echo "Skip go install"

RUN $(grep -q "base" <<< "${ARG_PROFILE_JULIA}")  && ( source /opt/utils/script-setup.sh && setup_julia  ) || echo "Skip julia install"

RUN $(grep -q "base" <<< "${ARG_PROFILE_OCTAVE}") && ( source /opt/utils/script-setup.sh && setup_octave ) || echo "Skip octave install"

# Clean up and display components version information...
RUN source /opt/utils/script-utils.sh && install__clean && list_installed_packages

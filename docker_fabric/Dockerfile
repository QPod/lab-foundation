# Distributed under the terms of the Modified BSD License.

ARG BASE_REPO
ARG BASE_TAG
FROM ${BASE_REPO}:${BASE_TAG:-core}

LABEL maintainer="haobibo@gmail.com"

ARG ARG_PROFILE_NODEJS=base

ARG ARG_PROFILE_JDK

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

RUN [[ ${ARG_PROFILE_JDK}    == *"base"* ]] && source /opt/utils/script-setup.sh && setup_jdk    || true

RUN [[ ${ARG_PROFILE_GO}     == *"base"* ]] && source /opt/utils/script-setup.sh && setup_GO     || true

RUN [[ ${ARG_PROFILE_JULIA}  == *"base"* ]] && source /opt/utils/script-setup.sh && setup_julia  || true

RUN [[ ${ARG_PROFILE_OCTAVE} == *"base"* ]] && source /opt/utils/script-setup.sh && setup_octave || true

# If installing LaTex and LaTex CJK packages.
RUN source /opt/utils/script-*.sh \
 && for profile in $(echo $ARG_PROFILE_LATEX | tr "," "\n") ; do ( install_pip "/opt/utils/install_list_latex_${profile}.pip" || true ) ; done

# If installing R environment
RUN source /opt/utils/script-*.sh \
 && for profile in $(echo $ARG_PROFILE_R | tr "," "\n") ; do ( setup_${profile} || true ) ; done \
 && ( [[ ${ARG_PROFILE_R}  == *"datascience"* ]] \
 &&   R -e "devtools::install_git('git://github.com/sorhawell/rgl.git',quiet=T,clean=T) # work around rgl, which has too many deps." \
 &&   install_apt   /opt/utils/install_list_R_datascience.apt \
 &&   install_R     /opt/utils/install_list_R_datascience.R   \
 ||   true )

# If on a x86_64 architecture, install MKL for acceleration; Installing conda packages if provided.
RUN ( [[ `arch` == "x86_64" ]] &&        ( echo "mkl" >> /opt/utils/install_list.conda ) || true ) \
 && source /opt/utils/script-utils.sh && ( install_conda /opt/utils/install_list.conda   || true )

# If installing Python packages
RUN source /opt/utils/script-utils.sh \
 && ( [[ ${ARG_PROFILE_PYTHON} == *"datascience"* ]] \
      && ( which nvidia-smi && echo "tensorflow % tf-gpu "                >> /opt/utils/install_list_PY_datascience.pip || true ) \
      && ( which R          && echo "rpy2  % Install rpy2 if R exists"    >> /opt/utils/install_list_PY_datascience.pip || true ) \
      && ( which java       && echo "py4j  % Install py4j if Java exists" >> /opt/utils/install_list_PY_datascience.pip || true ) \
      || true ) \
 && for profile in $(echo $ARG_PROFILE_PYTHON | tr "," "\n") ; do ( install_pip "/opt/utils/install_list_PY_${profile}.pip" || true ) ; done \
 ## TODO: TEMP Fix - https://github.com/pytoolz/cytoolz/issues/144
 && rm -f $(python -c 'import sys; print("/opt/conda/lib/python3.%s/site-packages/cytoolz/__init__.py" % sys.version_info.minor)')

# Clean up and display components version information...
RUN source /opt/utils/script-utils.sh  && install__clean

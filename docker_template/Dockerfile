# Distributed under the terms of the Modified BSD License.

ARG BASE_REPO
ARG BASE_TAG
FROM ${BASE_REPO}:${BASE_TAG}

LABEL maintainer="haobibo@gmail.com"

ARG ARG_JDK=false

ARG ARG_MKL=true
ARG ARG_PY_DATABASE=false
ARG ARG_PY_DATASCIENCE=false
ARG ARG_PY_NLP=false
ARG ARG_PY_CV=false
ARG ARG_PY_BIOINFO=false

ARG ARG_R=false
ARG ARG_R_DATASCIENCE=false
ARG ARG_R_STUDIO=false

ARG ARG_GO=false

ARG ARG_JULIA=false

ARG ARG_OCTAVE=false

COPY work /opt/utils/

WORKDIR /opt/utils


# If installing Java environment
RUN ${ARG_JDK:-false} && source /opt/utils/script-setup.sh && setup_jdk || true

# If installing R environment
RUN ${ARG_R:-false}   && source /opt/utils/script-*.sh && setup_R \
    && ( ${ARG_R_DATASCIENCE:-false}  \
         && R -e "devtools::install_git('git://github.com/sorhawell/rgl.git',quiet=T,clean=T) # work around rgl, which has too many deps." \
         && install_apt   ./install_list_R_datascience.apt \
         && install_R     ./install_list_R_datascience.R   \
         || true \
    ) \
    && ( ${ARG_R_STUDIO:-false} && setup_R_studio || true ) \
    && ( ${ARG_R_STUDIO:-false} && setup_R_shiny  || true ) \
    && echo "@ Version of installed R libraries:" && R -e "R.Version()\$version.string;installed.packages()[,c(3,10)]" \
    || true


# If on a x86_64 architecture and MKL selected, install MKL for acceleration
RUN ${ARG_MKL:-false} && (echo "mkl" >> ./install_list.conda ) || true


# Installing conda packages if provided.
RUN source /opt/utils/script-utils.sh \
    && echo "@ Conda Info:"  && conda info \
    && ( install_conda ./install_list.conda || true ) \
    && echo "@ Version of installed Conda packages:"  && conda list | grep -v "pypi"


# If installing Python and related packages
RUN source /opt/utils/script-utils.sh \
    && ( ${ARG_PY_DATASCIENCE:-false} \
         && ( which nvidia-smi && echo "tensorflow % tf-gpu "                >> ./install_list_PY_datascience.pip || true ) \
         && ( which R          && echo "rpy2  % Install rpy2 if R exists"    >> ./install_list_PY_datascience.pip || true ) \
         && ( which java       && echo "py4j  % Install py4j if Java exists" >> ./install_list_PY_datascience.pip || true ) \
         && install_pip   ./install_list_PY_datascience.pip \
         || true ) \
    && ( ${ARG_PY_DATABASE:-false}      && install_pip   ./install_list_PY_database.pip    || true ) \
    && ( ${ARG_PY_NLP:-false}           && install_pip   ./install_list_PY_nlp.pip         || true ) \
    && ( ${ARG_PY_CV:-false}            && install_pip   ./install_list_PY_cv.pip          || true ) \
    && ( ${ARG_PY_BIOINFO:-false}       && install_pip   ./install_list_PY_bioinfo.pip     || true ) \
    && echo "@ Version of installed Python packages:" && pip list \
    # TODO: TEMP Fix - https://github.com/pytoolz/cytoolz/issues/144
    && rm -f $(python -c 'import sys; print("/opt/conda/lib/python3.%s/site-packages/cytoolz/__init__.py" % sys.version_info.minor)')

# Install golang and gophernotes (Jupyter kernel for golang)
RUN ${ARG_GO:-false}  && source /opt/utils/script-setup.sh && setup_GO || true

# Install Julia and IJulia
RUN ${ARG_JULIA:-false}     && source /opt/utils/script-setup.sh && setup_julia || true

# Install Octave and Octave kernal for Jupyter
RUN ${ARG_OCTAVE:-false}    && source /opt/utils/script-setup.sh \
    && setup_octave \
    && julia -e 'using Pkg; pkg"update"; pkg"add IJulia"; pkg"precompile"' \ 
    && mv ~/.local/share/jupyter/kernels/julia* /opt/conda/share/jupyter/kernels/ \
    && echo "@ Version of julia:" && julia -e 'using Pkg; for(k,v) in Pkg.dependencies(); println(v.name,"==",v.version); end' \
    || true

# Clean up and display components version information...
RUN source /opt/utils/script-extend.sh && setup_jupyter_kennels \
  & source /opt/utils/script-utils.sh  && install__clean

WORKDIR /root

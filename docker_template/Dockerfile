# Distributed under the terms of the Modified BSD License.

ARG repository
ARG base
FROM ${repository}:${base}

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
RUN ${ARG_JDK:-false}           && source /opt/utils/script-utils.sh \
    && install_apt   ./install_list_jdk.apt \
    && echo "@ Version of Java (java/javac):" && java -version && javac -version \
    && pip install -Uq beakerx pandas py4j  \
    && beakerx install \
    && jupyter labextension install --dev-build beakerx-jupyterlab \
    && jupyter labextension list  \
    || true

# If installing R environment
RUN ${ARG_R:-false}             && source /opt/utils/script-utils.sh \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" > /etc/apt/sources.list.d/cran.list \
    && install_apt  ./install_list_R.apt \
    && echo "@ Version of R:" && R -e "R.version.string;"  \
    && ( type java && type R && R CMD javareconf || true ) \
    && echo "options(repos=structure(c(CRAN='https://cloud.r-project.org')))" >> /etc/R/Rprofile.site \
    && R -e "install.packages(c('devtools','IRkernel'),quiet=T,clean=T); IRkernel::installspec(user=F)" \
    && ( ${ARG_R_DATASCIENCE:-false}  \
         && R -e "devtools::install_git('git://github.com/sorhawell/rgl.git',quiet=T,clean=T) # work around rgl, which has too many deps." \
         && install_apt   ./install_list_R_datascience.apt \
         && install_R     ./install_list_R_datascience.R   \
         || true \
    ) \
    && ( ${ARG_R_STUDIO:-false} \
         && RSTUDIO_VERSION=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
         && RSTUDIO_VERSION=$(echo $RSTUDIO_VERSION | cut -d- -f1) \
         && wget -qO- "https://download2.rstudio.org/server/trusty/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" -O /tmp/rstudio.deb \
         && dpkg -x /tmp/rstudio.deb /tmp && mv /tmp/usr/lib/rstudio-server/ /opt/ \
         && ln -s /opt/rstudio-server/bin/rs* /usr/bin/ \
         # Allow RStudio server run as root user
         && mkdir -p /etc/rstudio \
         && echo "auth-minimum-user-id=0" >> /etc/rstudio/rserver.conf \
         # Configuration to make RStudio server disable authentication and do not run as daemon
         && echo "auth-none=1"            >> /etc/rstudio/rserver.conf \
         && echo "server-daemonize=0"     >> /etc/rstudio/rserver.conf \
         && printf '#!/bin/bash\nexport USER=root\nrserver --www-port=8888' > /usr/local/bin/start-rstudio.sh \
         && chmod u+x /usr/local/bin/start-rstudio.sh \
         # Remove RStudio's pandoc and pandoc-proc to reduce size if they are already installed in the jpy-latex step.
         && ( which pandoc          && rm /opt/rstudio-server/bin/pandoc/pandoc          || true ) \
         && ( which pandoc-citeproc && rm /opt/rstudio-server/bin/pandoc/pandoc-citeproc || true ) \
         && echo "@ Version of rstudio-server:" && rstudio-server version \
         || true \
    ) \
    && ( ${ARG_R_STUDIO:-false} \
         && RSHINY_VERSION=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION) \
         && wget -qO- "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${RSHINY_VERSION}-amd64.deb" -O /tmp/rshiny.deb \
         && dpkg -i /tmp/rshiny.deb \
         && sed  -i 's/run_as shiny;/run_as root;/g'  /etc/shiny-server/shiny-server.conf \
         && sed  -i 's/3838/8888/g'                   /etc/shiny-server/shiny-server.conf \
         && printf '#!/bin/bash\nexport USER=root\nshiny-server' > /usr/local/bin/start-shiny-server.sh \
         && chmod u+x /usr/local/bin/start-shiny-server.sh \
         # Remove shiny's pandoc and pandoc-proc to reduce size if they are already installed in the jpy-latex step.
         && ( which pandoc          && rm /opt/shiny-server/ext/pandoc/pandoc          || true ) \
         && ( which pandoc-citeproc && rm /opt/shiny-server/ext/pandoc/pandoc-citeproc || true ) \
         && rm    /opt/shiny-server/ext/node/bin/shiny-server \
         && ln -s /opt/shiny-server/ext/node/bin/node /opt/shiny-server/ext/node/bin/shiny-server \
         # hack shiny-server to allow run in root user: https://github.com/rstudio/shiny-server/pull/391
         && sed  -i 's/throw new Error/logger.warn/g'  /opt/shiny-server/lib/worker/app-worker.js \
         && echo "@ Version of shiny-server:" && shiny-server --version \
         || true \
    ) \
    && echo "@ Version of installed R libraries:" && R -e "R.Version()\$version.string;installed.packages()[,c(3,10)]" \
    || true

# If on a x86_64 architecture and MKL selected, install MKL for acceleration
RUN ${ARG_MKL:-false}           && [ `arch` = "x86_64" ] && pip install -Uq --pre mkl \
    || true

# If installing Python and related packages
RUN source /opt/utils/script-utils.sh \
    && ( ${ARG_PY_DATASCIENCE:-false} \
         && ( [[ -z "${CUDA_VERSION}" ]] && TF='tensorflow' || TF="tensorflow-gpu" \
              && echo "${TF}==1.*   % decide version based on CUDA_VERSION" >> ./install_list_PY_datascience.pip \
         ) \
         && ( which R    && echo "rpy2  % Install rpy2 if R exists"         >> ./install_list_PY_datascience.pip || true ) \
         && ( which java && echo "py4j  % Install py4j if Java exists"      >> ./install_list_PY_datascience.pip || true ) \
         && install_pip   ./install_list_PY_datascience.pip \
         || true \
    ) \
    && ( ${ARG_PY_DATABASE:-false}      && install_pip   ./install_list_PY_database.pip    || true ) \
    && ( ${ARG_PY_NLP:-false}           && install_pip   ./install_list_PY_nlp.pip         || true ) \
    && ( ${ARG_PY_CV:-false}            && install_pip   ./install_list_PY_cv.pip          || true ) \
    && ( ${ARG_PY_BIOINFO:-false}       && install_pip   ./install_list_PY_bioinfo.pip     || true ) \
    && echo "@ Version of installed Python packages:" && pip list

# Installing conda packages if provided.
RUN source /opt/utils/script-utils.sh \
    && ( install_conda ./install_list.conda || true ) \
    && echo "@ Version of installed Conda packages:"  && conda info && conda list | grep -v "<pip>"

# Install golang and gophernotes (Jupyter kernel for golang)
RUN ${ARG_GO:-false}        && source /opt/utils/script-utils.sh \
    && GO_VERSION="1.12.2" \
    && GO_URL="https://dl.google.com/go/go$GO_VERSION.linux-$(dpkg --print-architecture).tar.gz" \
    && install_tar_gz $GO_URL go \
    && ln -s /opt/go/bin/go /usr/bin/ \
    && echo  "GOPATH=/opt/go/path"     >> /etc/bash.bashrc \
    && export GOPATH=/opt/go/path \
    && go get -u github.com/gopherdata/gophernotes \
    && mkdir -p /opt/conda/share/jupyter/kernels/gophernotes \
    && cp $GOPATH/src/github.com/gopherdata/gophernotes/kernel/* /opt/conda/share/jupyter/kernels/gophernotes \
    && ln -s $GOPATH/bin/gophernotes /usr/local/bin \
    && echo "@ Version of golang:" && go version && go list ... \
    || true

# Install Julia and IJulia
RUN ${ARG_JULIA:-false}     && source /opt/utils/script-utils.sh \
    && JULIA_URL="https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz" \
    && install_tar_gz $JULIA_URL \
    && mv /opt/julia-* /opt/julia \
    && ln -fs /opt/julia/bin/julia /usr/local/bin/julia \
    && mkdir -p /opt/julia/pkg \
    && echo 'import Libdl; push!(Libdl.DL_LOAD_PATH, "/opt/conda/lib")' >> /opt/julia/etc/julia/startup.jl \
    && echo 'DEPOT_PATH[1]="/opt/julia/pkg"'                            >> /opt/julia/etc/julia/startup.jl \
    && julia -e 'using Pkg; pkg"update"; pkg"add IJulia"; pkg"precompile"' \ 
    && mv ~/.local/share/jupyter/kernels/julia* /opt/conda/share/jupyter/kernels/ \
    && echo "@ Version of julia:" && julia --version && julia -e 'using Pkg; for(k,v) in sort(collect(Pkg.installed())); println(k,"==",v); end' \
    || true

# Install Octave and Octave kernal for Jupyter
RUN ${ARG_OCTAVE:-false}    && source /opt/utils/script-utils.sh \
    && install_apt   /opt/utils/install_list_octave.apt \
    && OCTAVE_VERSION="5.1.0" \
    && install_tar_xz "https://ftp.gnu.org/gnu/octave/octave-${OCTAVE_VERSION}.tar.xz" \
    && cd /opt/octave-* \
    && ./configure --prefix=/opt/octave --disable-docs --without-opengl \
    && make -j8 && make install -j8 \
    && cd /opt/utils && rm -rf /opt/octave-* \
    && echo "PATH=/opt/octave/bin:$PATH"     >> /etc/bash.bashrc \
    && export PATH=/opt/octave/bin:$PATH \
    && pip install -Uq octave_kernel \
    && install_octave    /opt/utils/install_list_octave.pkg \
    && echo "@ Version of Octave and installed packages:" \
    && /opt/octave/bin/octave --version  \
    && /opt/octave/bin/octave --eval "pkg list"  \
    || true

# Clean up and display components version information...
RUN  source /opt/utils/script-utils.sh \
  && install__clean && cd \
  && echo "@ Version of image: building finished at:" `date` `uname -a` \
  && echo "@ System environment variables:" `printenv`

WORKDIR /root

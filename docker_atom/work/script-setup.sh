source /opt/utils/script-utils.sh


setup_mamba() {
  # Notice: mamba use $CONDA_PREFIX to locate base env
    ARCH="linux-64" && MICROMAMBA_VERSION="latest" \
  && MAMBA_URL="https://micromamba.snakepit.net/api/micromamba/${ARCH}/${MICROMAMBA_VERSION}" \
  && mkdir -pv /opt/mamba /etc/conda \
  && install_tar_bz $MAMBA_URL bin/micromamba && mv /opt/bin/micromamba /opt/mamba/mamba \
  && ln -sf /opt/mamba/mamba /usr/bin/ \
  && touch /etc/conda/.condarc \
  && printf "channels:\n"       >> /etc/conda/.condarc \
  && printf "  - conda-forge\n" >> /etc/conda/.condarc \
  && echo "@ Version of mamba:" && mamba info
}


setup_conda_postprocess() {
  ln -sf ${CONDA_PREFIX}/bin/python3 /usr/bin/python

  # If python exists, set pypi source
  if [ -f "$(which python)" ]; then
    cat >/etc/pip.conf <<EOF
[global]
progress_bar=off
root-user-action=ignore
# retries=5
# timeout=10
trusted-host=pypi.python.org pypi.org files.pythonhosted.org
# index-url=https://pypi.python.org/simple
EOF
  fi

  echo 'export PATH=$PATH:${CONDA_PREFIX}/bin'		>> /etc/profile
  ln -sf ${CONDA_PREFIX}/bin/conda /usr/bin/

     conda config --system --prepend channels conda-forge \
  && conda config --system --set auto_update_conda false  \
  && conda config --system --set show_channel_urls true   \
  && conda config --system --set report_errors false \
  && conda config --system --set channel_priority strict \
  && conda update --all --quiet --yes

  # These conda pkgs shouldn't be removed (otherwise will cause RemoveError) since they are directly required by conda: pip setuptools pycosat pyopenssl requests ruamel_yaml
     CONDA_PY_PKGS=$(conda list | grep "py3" | cut -d " " -f 1 | sed "/#/d;/conda/d;/pip/d;/setuptools/d;/pycosat/d;/pyopenssl/d;/requests/d;/ruamel_yaml/d;") \
  && conda remove --force -yq "${CONDA_PY_PKGS}" \
  && pip install -UIq pip setuptools "${CONDA_PY_PKGS}"

  # Print Conda and Python packages information in the docker build log
  echo "@ Version of Conda & Python:" && conda info && conda list | grep -v "<pip>"
}

setup_conda_with_mamba() {
  mkdir -pv ${CONDA_PREFIX}
  VERSION_PYTHON=$1; shift 1;
  mamba install -y --root-prefix="${CONDA_PREFIX}" --prefix="${CONDA_PREFIX}" -c "conda-forge" conda pip python="${VERSION_PYTHON:-3.10}"
  rm -rf ${CONDA_PREFIX}/pkgs/*
  setup_conda_postprocess
}

setup_conda_download() {
  mkdir -pv ${CONDA_PREFIX}
  wget -qO- "https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-$(arch).sh" -O /tmp/conda.sh
  bash /tmp/conda.sh -f -b -p ${CONDA_PREFIX}/
  rm -rf /tmp/conda.sh
  setup_conda_postprocess
}


setup_tini() {
     cd /tmp \
  && TINI_VERSION=$(curl -sL https://github.com/krallin/tini/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[\d.]+' ) \
  && curl -o tini.zip -sL "https://github.com/krallin/tini/archive/v${TINI_VERSION}.zip" && unzip -q /tmp/tini.zip \
  && cmake /tmp/tini-* && make install && mv /tmp/tini /usr/bin/tini && chmod +x /usr/bin/tini && rm -rf /tmp/tini-*
}


setup_nvtop() {
  # Install Utilities `nvtop`
  sudo apt-get -qq update --fix-missing && sudo apt-get -qq install -y --no-install-recommends libncurses5-dev

  DIRECTORY=$(pwd)

     cd /tmp \
  && git clone https://github.com/Syllo/nvtop.git \
  && mkdir -pv nvtop/build && cd nvtop/build \
  && LIB_PATH=$(find / -name "libnvidia-ml*" 2>/dev/null) \
  && cmake .. -DCMAKE_LIBRARY_PATH="$(dirname ${LIB_PATH})" .. \
  && make && sudo make install \
  && nvtop --version

  cd "${DIRECTORY}" && rm -rf /tmp/nvtop

  sudo apt-get -qq remove -y libncurses5-dev
}


setup_java_base() {
  local VER_JDK=${VERSION_JDK:-"11"}
  ARCH="x64"
  echo "Use env var VERSION_JDK to specify JDK major version. If not specified, will install version 11 by default."
  echo "Will install JDK version ${VER_JDK}"

  JDK_PAGE_DOWNLOAD="https://www.oracle.com/java/technologies/downloads/" \
  && JDK_URL_ORCA=$(curl -sL ${JDK_PAGE_DOWNLOAD} | grep "tar.gz" | grep "http" | grep -v sha256 | grep ${ARCH} | grep -i $(uname) | sed "s/'/\"/g" | sed -n 's/.*="\([^"]*\).*/\1/p' | grep "jdk-${VER_JDK}" | head -n 1)

  JDK_PAGE_RELEASE="https://www.oracle.com/java/technologies/javase/${VER_JDK}u-relnotes.html" \
  && JDK_VER_MINOR=$(curl -sL ${JDK_PAGE_RELEASE} | grep -P 'JDK \d..\d+' | grep -Po '[\d\.]{3,}' | head -n1) \
  && JDK_URL_MSFT="https://aka.ms/download-jdk/microsoft-jdk-${JDK_VER_MINOR}-linux-${ARCH}.tar.gz"

  if [ "$VER_JDK" -gt 11 ] ; then
    URL_OPENJDK=${JDK_URL_ORCA}
  elif [ "$VER_JDK" -gt 8 ] ; then
    URL_OPENJDK=${JDK_URL_MSFT}
  else
    echo "ORCA download URL ref: ${JDK_URL_ORCA}"
    URL_OPENJDK="https://javadl.oracle.com/webapps/download/GetFile/1.8.0_341-b10/424b9da4b48848379167015dcc250d8d/linux-i586/jdk-8u341-linux-${ARCH}.tar.gz"
  fi

     echo "Installing JDK version ${VER_JDK} from: ${URL_OPENJDK}" \
  && install_tar_gz "${URL_OPENJDK}" && mv /opt/jdk* /opt/jdk \
  && ln -sf /opt/jdk/bin/* /usr/bin/ \
  && echo "@ Version of Java (java/javac):" && java -version && javac -version
}

setup_java_maven() {
     VERSION_MAVEN=$1; shift 1; VERSION_MAVEN=${VERSION_MAVEN:-"3.8.6"} \
  && install_zip "http://archive.apache.org/dist/maven/maven-3/${VERSION_MAVEN}/binaries/apache-maven-${VERSION_MAVEN}-bin.zip" \
  && mv /opt/apache-maven-${VERSION_MAVEN} /opt/maven \
  && ln -sf /opt/maven/bin/mvn* /usr/bin/ \
  && echo "@ Version of Maven:" && mvn --version
}


setup_node() {
  # NODEJS_VERSION_MAJOR="v14" && grep "v${NODEJS_VERSION_MAJOR}."
     ARCH="x64" \
  && NODEJS_VERSION=$(curl -sL https://github.com/nodejs/node/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[.\d]+') \
  && NODEJS_VERSION_MAJOR=$(echo ${NODEJS_VERSION} | cut -d '.' -f1 ) \
  && install_tar_gz "https://nodejs.org/download/release/latest-v${NODEJS_VERSION_MAJOR}.x/node-v${NODEJS_VERSION}-linux-${ARCH}.tar.gz" \
  && mv /opt/node* /opt/node \
  && echo  "PATH=/opt/node/bin:$PATH" >> /etc/bash.bashrc \
  && export PATH=/opt/node/bin:$PATH \
  && npm install -g npm yarn \
  && ln -sf /opt/node/bin/* /usr/bin/ \
  && echo "@ Version of Node, npm, and yarn: $(node -v) $(npm -v)" \
  && echo "@ Version of Yarn: $(yarn -v)"
}


setup_R_base() {
     apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
  && echo "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" > /etc/apt/sources.list.d/cran.list \
  && install_apt  /opt/utils/install_list_R_base.apt \
  && echo "options(repos=structure(c(CRAN=\"https://cloud.r-project.org\")))" >> /etc/R/Rprofile.site \
  && R -e "install.packages(c('devtools'),clean=T,quiet=T);" \
  && ( type java && type R && R CMD javareconf || true ) \
  && echo "@ Version of R: $(R --version)"
}


setup_R_rstudio() {
     $(curl -sL https://www.rstudio.com/products/rstudio/download-server/debian-ubuntu/  | grep '.deb' | grep 'bionic') -O /tmp/rstudio.deb \
  && dpkg -x /tmp/rstudio.deb /tmp && mv /tmp/usr/lib/rstudio-server/ /opt/ \
  && ln -sf /opt/rstudio-server         /usr/lib/ \
  && ln -sf /opt/rstudio-server/bin/rs* /usr/bin/

  # Allow RStudio server run as root user
  # Configuration to make RStudio server disable authentication and do not run as daemon
     mkdir -p /etc/rstudio \
  && echo "server-daemonize=0"     >> /etc/rstudio/rserver.conf \
  && echo "server-user=root"       >> /etc/rstudio/rserver.conf \
  && echo "auth-none=1"            >> /etc/rstudio/rserver.conf \
  && echo "auth-minimum-user-id=0" >> /etc/rstudio/rserver.conf \
  && echo "auth-validate-users=0"  >> /etc/rstudio/rserver.conf \
  && echo "www-allow-origin=*"     >> /etc/rstudio/rserver.conf \
  && echo "www-same-site=none"     >> /etc/rstudio/rserver.conf \
  && echo "www-frame-origin=same"  >> /etc/rstudio/rserver.conf \
  && echo "www-verify-user-agent=0">> /etc/rstudio/rserver.conf \
  && echo "database-config-file=/etc/rstudio/db.conf"  >> /etc/rstudio/rserver.conf \
  && echo "provider=sqlite"                            >> /etc/rstudio/db.conf \
  && echo "directory=/etc/rstudio/"                    >> /etc/rstudio/db.conf \
  && printf "USER=root rserver --www-port=8888" > /usr/local/bin/start-rstudio.sh \
  && chmod u+x /usr/local/bin/start-rstudio.sh

  # Remove RStudio's pandoc and pandoc-proc to reduce size if they are already installed in the jpy-latex step.
     ( which pandoc          && rm /opt/rstudio-server/bin/pandoc/pandoc          || true ) \
  && ( which pandoc-citeproc && rm /opt/rstudio-server/bin/pandoc/pandoc-citeproc || true ) \
  && echo "@ Version of rstudio-server: $(rstudio-server version)"
}


setup_R_rshiny() {
     RSHINY_VERSION=$(curl -sL https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-14.04/x86_64/VERSION) \
  && wget -qO- "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${RSHINY_VERSION}-amd64.deb" -O /tmp/rshiny.deb \
  && dpkg -i /tmp/rshiny.deb \
  && sed  -i "s/run_as shiny;/run_as root;/g"  /etc/shiny-server/shiny-server.conf \
  && sed  -i "s/3838/8888/g"                   /etc/shiny-server/shiny-server.conf \
  && printf "USER=root shiny-server" > /usr/local/bin/start-shiny-server.sh \
  && chmod u+x /usr/local/bin/start-shiny-server.sh

  # Remove shiny's pandoc and pandoc-proc to reduce size if they are already installed in the jpy-latex step.
     ( which pandoc          && rm /opt/shiny-server/ext/pandoc/pandoc          || true ) \
  && ( which pandoc-citeproc && rm /opt/shiny-server/ext/pandoc/pandoc-citeproc || true ) \
  && rm -rf /opt/shiny-server/ext/node/bin/shiny-server \
  && ln -sf /opt/shiny-server/ext/node/bin/node /opt/shiny-server/ext/node/bin/shiny-server

  # hack shiny-server to allow run in root user: https://github.com/rstudio/shiny-server/pull/391
     sed  -i "s/throw new Error/logger.warn/g"  /opt/shiny-server/lib/worker/app-worker.js \
  && echo "@ Version of shiny-server: $(shiny-server --version)"
}


setup_R_datascience() {
  # firstly install rgl stub to work around, which has too many deps, but required by some libs
  R -e "devtools::install_git(\"git://github.com/sorhawell/rgl.git\",quiet=T,clean=T)"

     install_apt  /opt/utils/install_list_R_datascience.apt \
  && install_R    /opt/utils/install_list_R_datascience.R
}


setup_GO() {
     GO_VERSION=$(curl -sL https://github.com/golang/go/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[\d.]+') \
  && GO_URL="https://dl.google.com/go/go$GO_VERSION.linux-$(dpkg --print-architecture).tar.gz" \
  && install_tar_gz "${GO_URL}" go \
  && ln -sf /opt/go/bin/go /usr/bin/ \
  && echo "@ Version of golang: $(go version)"
}


setup_julia() {
     JULIA_URL="https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz" \
  && install_tar_gz $JULIA_URL \
  && mv /opt/julia-* /opt/julia \
  && ln -fs /opt/julia/bin/julia /usr/bin/julia \
  && mkdir -p /opt/julia/pkg \
  && echo "import Libdl; push!(Libdl.DL_LOAD_PATH, \"/opt/conda/lib\")" >> /opt/julia/etc/julia/startup.jl \
  && echo "DEPOT_PATH[1]=\"/opt/julia/pkg\""                            >> /opt/julia/etc/julia/startup.jl \
  && echo "@ Version of Julia: $(julia --version)"
}


setup_octave() {
  # TEMPFIX: javac version
  # && OCTAVE_VERSION="6.3.0" \
  # && install_tar_xz "https://ftp.gnu.org/gnu/octave/octave-${OCTAVE_VERSION}.tar.xz" \
  # && cd /opt/octave-* \
  # && sed  -i "s/1.6/11/g" ./Makefile.in \
  # && sed  -i "s/1.6/11/g" ./scripts/java/module.mk \
  # && ./configure --prefix=/opt/octave --disable-docs --without-opengl \
  # && make -j8 && make install -j8 \
  # && cd /opt/utils && rm -rf /opt/octave-*

     install_apt       /opt/utils/install_list_octave.apt \
  && install_octave    /opt/utils/install_list_octave.pkg \
  && echo "@ Version of Octave and installed packages: $(/opt/octave/bin/octave --version)"
}


setup_traefik() {
     TRAEFIK_VERSION=$(curl -sL https://github.com/traefik/traefik/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[\d.]+') \
  && TRAEFIK_URL="https://github.com/traefik/traefik/releases/download/v${TRAEFIK_VERSION}/traefik_v${TRAEFIK_VERSION}_linux_$(dpkg --print-architecture).tar.gz" \
  && install_tar_gz "${TRAEFIK_URL}" traefik \
  && ln -sf /opt/traefik /usr/bin/ \
  && echo "@ Version of traefik: $(traefik version)"
}

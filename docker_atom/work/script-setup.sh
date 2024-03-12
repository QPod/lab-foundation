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

  echo 'export PATH=${PATH}:${CONDA_PREFIX:-"/opt/conda"}/bin'		>> /etc/profile.d/path-conda.sh
  ln -sf "${CONDA_PREFIX}/bin/conda" /usr/bin/

     conda config --system --prepend channels conda-forge \
  && conda config --system --set auto_update_conda false  \
  && conda config --system --set show_channel_urls true   \
  && conda config --system --set report_errors false \
  && conda config --system --set channel_priority strict \
  && conda update --all --quiet --yes

  # remove non-necessary folder/symlink "python3.1" exists
  rm -rf "${CONDA_PREFIX}"/bin/python3.1

  # These conda pkgs shouldn't be removed (otherwise will cause RemoveError) since they are directly required by conda: pip setuptools pycosat pyopenssl requests ruamel_yaml
  #    CONDA_PY_PKGS=$(conda list | grep "py3" | cut -d " " -f 1 | sed "/#/d;/conda/d;/pip/d;/setuptools/d;/pycosat/d;/pyopenssl/d;/requests/d;/ruamel_yaml/d;") \
  # && conda remove --force -yq "${CONDA_PY_PKGS}" \
  # && pip install -UIq pip setuptools "${CONDA_PY_PKGS}" \
  # && rm -rf "${CONDA_PREFIX}"/pkgs/*

  # Print Conda and Python packages information in the docker build log
  echo "@ Version of Conda & Python:" && conda info && conda list | grep -v "<pip>"
}

setup_conda_with_mamba() {
  local PREFIX="${CONDA_PREFIX:-/opt/conda}"
  mkdir -pv "${PREFIX}"
  VERSION_PYTHON=${1:-"3.11"}; shift 1;
  mamba install -y --root-prefix="${PREFIX}" --prefix="${PREFIX}" -c "conda-forge" conda pip python="${VERSION_PYTHON}"
  setup_conda_postprocess
}

setup_conda_download() {
  # https://docs.conda.io/projects/miniconda/en/latest/index.html
  mkdir -pv "${CONDA_PREFIX}"
  wget -qO- "https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-$(arch).sh" -O /tmp/conda.sh
  bash /tmp/conda.sh -f -b -p "${CONDA_PREFIX}/"
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
  # Install Utilities "nvtop" from source: libdrm-dev libsystemd-dev used by AMD/Intel GPU support, libudev-dev used by ubuntu18.04
  LIB_PATH=$(find / -name "libnvidia-ml*" 2>/dev/null) \
  && DIRECTORY=$(pwd) && cd /tmp \
  && sudo apt-get -qq update --fix-missing \
  && sudo apt-get -qq install -y --no-install-recommends libncurses5-dev libdrm-dev libsystemd-dev libudev-dev \
  && git clone https://github.com/Syllo/nvtop.git \
  && mkdir -pv nvtop/build && cd nvtop/build \
  && cmake .. -DCMAKE_LIBRARY_PATH="$(dirname ${LIB_PATH})" -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON -DINTEL_SUPPORT=ON \
  && make && sudo make install \
  && cd "${DIRECTORY}" && rm -rf /tmp/nvtop \
  && sudo apt-get -qq remove -y libncurses5-dev libdrm-dev libsystemd-dev libudev-dev \
  && nvtop --version
}


setup_java_base() {
  local VER_JDK=${VERSION_JDK:-"11"}
  ARCH="x64"
  echo "Use env var VERSION_JDK to specify JDK major version. If not specified, will install version 11 by default."
  echo "Will install JDK version ${VER_JDK}"

  JDK_PAGE_DOWNLOAD="https://www.oracle.com/java/technologies/downloads/" \
  && JDK_URL_ORCA=$(curl -sL ${JDK_PAGE_DOWNLOAD} | grep "tar.gz" | grep "http" | grep -v sha256 | grep ${ARCH} | grep -i $(uname) | sed "s/'/\"/g" | sed -n 's/.*="\([^"]*\).*/\1/p' | grep "jdk-${VER_JDK}" | head -n 1)

  JDK_PAGE_RELEASE="https://www.oracle.com/java/technologies/javase/${VER_JDK}u-relnotes.html" \
  && JDK_VER_MINOR=$(curl -sL "${JDK_PAGE_RELEASE}" | grep -P 'JDK \d..\d+' | grep -Po '[\d\.]{3,}' | head -n1) \
  && JDK_URL_MSFT="https://aka.ms/download-jdk/microsoft-jdk-${JDK_VER_MINOR}-linux-${ARCH}.tar.gz"

  if [ "$VER_JDK" -gt 11 ] ; then
    URL_OPENJDK=${JDK_URL_ORCA}
  elif [ "$VER_JDK" -gt 8 ] ; then
    URL_OPENJDK=${JDK_URL_MSFT}
  else
    echo "ORCA download URL ref: ${JDK_URL_ORCA}"
    URL_OPENJDK="https://javadl.oracle.com/webapps/download/GetFile/1.8.0_361-b09/0ae14417abb444ebb02b9815e2103550/linux-i586/jdk-8u361-linux-${ARCH}.tar.gz"
  fi

     echo "Installing JDK version ${VER_JDK} from: ${URL_OPENJDK}" \
  && install_tar_gz "${URL_OPENJDK}" && mv /opt/jdk* /opt/jdk \
  && ln -sf /opt/jdk/bin/* /usr/bin/ \
  && echo "@ Version of Java (java/javac):" && java -version && javac -version
}


setup_java_maven() {
     VERSION_MAVEN=$(curl -sL https://maven.apache.org/download.cgi | grep 'latest' | head -1 | grep -Po '\d[\d.]+') \
  && install_zip "http://archive.apache.org/dist/maven/maven-3/${VERSION_MAVEN}/binaries/apache-maven-${VERSION_MAVEN}-bin.zip" \
  && mv "/opt/apache-maven-${VERSION_MAVEN}" /opt/maven \
  && ln -sf /opt/maven/bin/mvn* /usr/bin/ \
  && echo "@ Version of Maven: $(mvn --version)"
}


setup_node() {
     ARCH="x64" \
  && NODEJS_VERSION=$(curl -sL https://github.com/nodejs/node/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[.\d]+') \
  && NODEJS_VERSION_MAJOR=$(echo "${NODEJS_VERSION}" | cut -d '.' -f1 ) \
  && NODEJS_URL="https://nodejs.org/download/release/latest-v${NODEJS_VERSION_MAJOR}.x/node-v${NODEJS_VERSION}-linux-${ARCH}.tar.gz" \
  && echo "Downloading NodeJS from: ${NODEJS_URL}" \
  && install_tar_gz ${NODEJS_URL} \
  && mv /opt/node* /opt/node \
  && ln -sf /opt/node/bin/n* /usr/bin/ \
  && echo 'export PATH=${PATH}:/opt/node/bin' >> /etc/profile.d/path-node.sh \
  && npm install -g npm \
  && echo "@ Version of Node and npm: $(node -v) $(npm -v)" \
  && corepack enable && yarn set version stable \
  && echo "@ Version of Yarn: $(yarn -v)"
}


setup_docker_compose() {
     ARCH="x86_64" \
  && COMPOSE_VERSION=$(curl -sL https://github.com/docker/compose/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[.\d]+') \
  && COMPOSE_URL="https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-${ARCH}" \
  && echo "Downloading Compose from: ${COMPOSE_URL}" \
  && sudo curl -o /usr/bin/docker-compose -sL ${COMPOSE_URL} \
  && sudo chmod +x /usr/bin/docker-compose \
  && echo "@ Version of docker-compose: $(docker-compose --version)"
}

setup_docker_syncer() {
     ARCH="amd64" \
  && SYNCER_VERSION="$(curl -sL https://github.com/AliyunContainerService/image-syncer/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[.\d]+')" \
  && SYNCER_URL="https://github.com/AliyunContainerService/image-syncer/releases/download/v${SYNCER_VERSION}/image-syncer-v${SYNCER_VERSION}-linux-${ARCH}.tar.gz" \
  && echo "Downloading image-syncer from: ${SYNCER_URL}" \
  && curl -o /tmp/image_syncer.tgz -sL ${SYNCER_URL} \
  && mkdir -pv /tmp/image_syncer && tar -zxvf /tmp/image_syncer.tgz -C /tmp/image_syncer \
  && sudo chmod +x /tmp/image_syncer/image-syncer \
  && sudo mv /tmp/image_syncer/image-syncer /usr/bin/ \
  && rm -rf /tmp/image_syncer* \
  && echo "@ image-syncer installed to: $(which image-syncer)"
}


setup_GO() {
     GO_VERSION=$(curl -sL https://github.com/golang/go/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[\d.]+') \
  && GO_URL="https://dl.google.com/go/go${GO_VERSION}.linux-$(dpkg --print-architecture).tar.gz" \
  && install_tar_gz "${GO_URL}" go \
  && ln -sf /opt/go/bin/go* /usr/bin/ \
  && echo 'export GOROOT="/opt/go"'		      >> /etc/profile.d/path-go.sh \
  && echo 'export  GOBIN="$GOROOT/bin"'		  >> /etc/profile.d/path-go.sh \
  && echo 'export GOPATH="$GOROOT/path"'		>> /etc/profile.d/path-go.sh \
  && echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin'	  >> /etc/profile.d/path-go.sh \
  && echo "@ Version of golang: $(go version)"
}


setup_rust() {
     export CARGO_HOME=/opt/cargo \
  && export RUSTUP_HOME=/opt/rust \
  && export PATH=$PATH:${CARGO_HOME}/bin \
  && curl -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain stable \
  && echo 'export CARGO_HOME="/opt/cargo"'		>> /etc/profile.d/path-rust.sh \
  && echo 'export RUSTUP_HOME="/opt/rust"'		>> /etc/profile.d/path-rust.sh \
  && echo 'export PATH=$PATH:/opt/cargo/bin'	>> /etc/profile.d/path-rust.sh \
  && echo "@ Version of rustup: $(rustup --version)" \
  && echo "@ Version of rustc:  $(rustc --version)"
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


setup_traefik() {
     TRAEFIK_VERSION=$(curl -sL https://github.com/traefik/traefik/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[\d.]+') \
  && TRAEFIK_URL="https://github.com/traefik/traefik/releases/download/v${TRAEFIK_VERSION}/traefik_v${TRAEFIK_VERSION}_linux_$(dpkg --print-architecture).tar.gz" \
  && install_tar_gz "${TRAEFIK_URL}" traefik \
  && ln -sf /opt/traefik /usr/bin/ \
  && echo "@ Version of traefik: $(traefik version)"
}


setup_bazel() {
     BAZEL_VERSION=$(curl -sL https://github.com/bazelbuild/bazel/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[\d.]+' ) \
  && BAZEL_URL="https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" \
  && curl -o /tmp/bazel.sh -sL "${BAZEL_URL}" && chmod +x /tmp/bazel.sh \
  && /tmp/bazel.sh && rm /tmp/bazel.sh \
  && echo "@ Version of bazel: $(bazel --version)"
}


setup_gradle() {
     GRADLE_VERSION=$(curl -sL https://github.com/gradle/gradle/releases.atom | grep 'releases/tag' | grep -v 'M' | head -1 | grep -Po '\d[\d.]+' ) \
  && install_zip "https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
  && mv /opt/gradle* /opt/gradle \
  && ln -sf /opt/gradle/bin/gradle /usr/bin \
  && echo "@ Version of gradle: $(gradle --version)"
}

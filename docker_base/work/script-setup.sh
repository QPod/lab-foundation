source /opt/utils/script-utils.sh


setup_conda() {
       wget -qO- "https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-$(arch).sh" -O /tmp/conda.sh \
    && bash /tmp/conda.sh -f -b -p /opt/conda \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false  \
    && conda config --system --set show_channel_urls true   \
    && conda config --set channel_priority strict \
    && conda update --all --quiet --yes

    # These conda pkgs shouldn't be removed (otherwise will cause RemoveError) since they are directly reqiuired by conda: pip setuptools pycosat pyopenssl requests ruamel_yaml
    CONDA_PY_PKGS=`conda list | grep "py3" | cut -d " " -f 1 | sed "/#/d;/conda/d;/pip/d;/setuptools/d;/pycosat/d;/pyopenssl/d;/requests/d;/ruamel_yaml/d;"` \
    && conda remove --force -yq $CONDA_PY_PKGS \
    && pip install -UIq pip setuptools $CONDA_PY_PKGS

    # Print Conda and Python packages information in the docker build log
    echo "@ Version of Conda & Python:" && conda info && conda list | grep -v "<pip>"
}


setup_java_base() {
      VERSION_OPENJDK=16 && VERSION_OPENJDK_EA=19 \
      && URL_OPENJDK="https://download.java.net/java/early_access/jdk${VERSION_OPENJDK}/${VERSION_OPENJDK_EA}/GPL/openjdk-${VERSION_OPENJDK}-ea+${VERSION_OPENJDK_EA}_linux-x64_bin.tar.gz" \
   && install_tar_gz ${URL_OPENJDK} && mv /opt/jdk-* /opt/jdk \
   && ln -s /opt/jdk/bin/* /usr/bin/ \
   && echo "@ Version of Java (java/javac):" && java -version && javac -version
}

setup_java_maven() {
      MAVEN_VERSION="3.6.3" \
   && install_zip "http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip" \
   && mv /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
   && ln -s /opt/maven/bin/mvn* /usr/bin/ \
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
    && ln -s /opt/node/bin/* /usr/bin/ \
    && echo "@ Version of Node, npm, and yarn:" `node -v` `npm -v` `yarn -v`
}


setup_R_base() {
       apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && echo "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" > /etc/apt/sources.list.d/cran.list \
    && install_apt  /opt/utils/install_list_R_base.apt \
    && echo "options(repos=structure(c(CRAN=\"https://cloud.r-project.org\")))" >> /etc/R/Rprofile.site \
    && R -e "install.packages(c('devtools'),clean=T,quiet=T);" \
    && ( type java && type R && R CMD javareconf || true ) \
    && echo "@ Version of R:" && R --version 
}


setup_R_rstudio() {
       RSTUDIO_VERSION=`curl -sL https://dailies.rstudio.com/rstudioserver/oss/ubuntu/x86_64/ | grep -Po "(?<=rstudio-server-)[0-9]\.[0-9]\.[0-9]+" | sort | tail -n 1` \
    && wget -qO- "https://s3.amazonaws.com/rstudio-ide-build/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" -O /tmp/rstudio.deb \
    && dpkg -x /tmp/rstudio.deb /tmp && mv /tmp/usr/lib/rstudio-server/ /opt/ \
    && ln -s /opt/rstudio-server         /usr/lib/ \
    && ln -s /opt/rstudio-server/bin/rs* /usr/bin/
    
    # Allow RStudio server run as root user
    # Configuration to make RStudio server disable authentication and do not run as daemon
       mkdir -p /etc/rstudio \
    && echo "server-daemonize=0"     >> /etc/rstudio/rserver.conf \
    && echo "server-user=root"       >> /etc/rstudio/rserver.conf \
    && echo "auth-none=1"            >> /etc/rstudio/rserver.conf \
    && echo "auth-minimum-user-id=0" >> /etc/rstudio/rserver.conf \
    && echo "auth-validate-users=0"  >> /etc/rstudio/rserver.conf \
    && printf "#!/bin/bash\nexport USER=root\nrserver --www-port=8888" > /usr/local/bin/start-rstudio.sh \
    && chmod u+x /usr/local/bin/start-rstudio.sh

    # Remove RStudio's pandoc and pandoc-proc to reduce size if they are already installed in the jpy-latex step.
       ( which pandoc          && rm /opt/rstudio-server/bin/pandoc/pandoc          || true ) \
    && ( which pandoc-citeproc && rm /opt/rstudio-server/bin/pandoc/pandoc-citeproc || true ) \
    && echo "@ Version of rstudio-server:" && rstudio-server version
}


setup_R_rshiny() {
       RSHINY_VERSION=$(curl -sL https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-14.04/x86_64/VERSION) \
    && wget -qO- "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${RSHINY_VERSION}-amd64.deb" -O /tmp/rshiny.deb \
    && dpkg -i /tmp/rshiny.deb \
    && sed  -i "s/run_as shiny;/run_as root;/g"  /etc/shiny-server/shiny-server.conf \
    && sed  -i "s/3838/8888/g"                   /etc/shiny-server/shiny-server.conf \
    && printf "#!/bin/bash\nexport USER=root\nshiny-server" > /usr/local/bin/start-shiny-server.sh \
    && chmod u+x /usr/local/bin/start-shiny-server.sh
    
    # Remove shiny's pandoc and pandoc-proc to reduce size if they are already installed in the jpy-latex step.
       ( which pandoc          && rm /opt/shiny-server/ext/pandoc/pandoc          || true ) \
    && ( which pandoc-citeproc && rm /opt/shiny-server/ext/pandoc/pandoc-citeproc || true ) \
    && rm    /opt/shiny-server/ext/node/bin/shiny-server \
    && ln -s /opt/shiny-server/ext/node/bin/node /opt/shiny-server/ext/node/bin/shiny-server
    
    # hack shiny-server to allow run in root user: https://github.com/rstudio/shiny-server/pull/391
       sed  -i "s/throw new Error/logger.warn/g"  /opt/shiny-server/lib/worker/app-worker.js \
    && echo "@ Version of shiny-server:" && shiny-server --version
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
    && install_tar_gz $GO_URL go \
    && ln -s /opt/go/bin/go /usr/bin/ \
    && echo "@ Version of golang and packages:" && go version 
}


setup_julia() {
       JULIA_URL="https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz" \
    && install_tar_gz $JULIA_URL \
    && mv /opt/julia-* /opt/julia \
    && ln -fs /opt/julia/bin/julia /usr/bin/julia \
    && mkdir -p /opt/julia/pkg \
    && echo "import Libdl; push!(Libdl.DL_LOAD_PATH, \"/opt/conda/lib\")" >> /opt/julia/etc/julia/startup.jl \
    && echo "DEPOT_PATH[1]=\"/opt/julia/pkg\""                            >> /opt/julia/etc/julia/startup.jl \
    && echo "@ Version of Julia" && julia --version
}


setup_octave() {
    # TEMPFIX: javac version
    # && OCTAVE_VERSION="5.2.0" \
    # && install_tar_xz "https://ftp.gnu.org/gnu/octave/octave-${OCTAVE_VERSION}.tar.xz" \
    # && cd /opt/octave-* \
    # && sed  -i "s/1.6/11/g" ./Makefile.in \
    # && sed  -i "s/1.6/11/g" ./scripts/java/module.mk \
    # && ./configure --prefix=/opt/octave --disable-docs --without-opengl \
    # && make -j8 && make install -j8 \
    # && cd /opt/utils && rm -rf /opt/octave-*

       install_apt       /opt/utils/install_list_octave.apt \
    && install_octave    /opt/utils/install_list_octave.pkg \
    && echo "@ Version of Octave and installed packages:" \
    && /opt/octave/bin/octave --version
}

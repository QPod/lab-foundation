# Distributed under the terms of the Modified BSD License.

ARG repository
ARG base
FROM ${repository}:${base:-base}

LABEL maintainer="haobibo@gmail.com"

ARG ARG_EXTEND_JUPYTER=true
ARG ARG_NODEJS=true
ARG ARG_LATEX_BASE=false
ARG ARG_LATEX_CJK=false


COPY work /opt/utils/

# Build and install tini, which will be entry point later...
RUN cd /tmp \
 && TINI_VERSION=$(wget --no-check-certificate -qO- https://github.com/krallin/tini/releases.atom | grep 'releases/tag' | head -1 ) \
 && TINI_VERSION=$(echo $TINI_VERSION | cut -d \" -f6 | cut -d \/ -f8 ) \
 && wget -qO- "https://github.com/krallin/tini/archive/${TINI_VERSION}.zip" -O tini.zip && unzip -q /tmp/tini.zip \
 && cmake /tmp/tini-* && make install && mv /tmp/tini /usr/local/bin/tini && chmod +x /usr/local/bin/tini

ENTRYPOINT ["tini", "-g", "--"]


# Install NodeJS (required to build JupyterLab Extensions later) # NODEJS_VERSION_MAJOR="$(cut -d '.' -f 1 <<< "$NODEJS_VERSION")"
RUN cd /tmp && source /opt/utils/script-utils.sh \
 && ARCH="x64" && NODEJS_VERSION_MAJOR="10" \
 && NODEJS_VERSION=$(wget --no-check-certificate -qO- https://github.com/nodejs/node/releases.atom | grep 'releases/tag' | grep "v${NODEJS_VERSION_MAJOR}." | head -1 ) \
 && NODEJS_VERSION=$(echo $NODEJS_VERSION | cut -d \" -f6 | cut -d \/ -f8 ) \
 && install_tar_gz "https://nodejs.org/download/release/latest-v${NODEJS_VERSION_MAJOR}.x/node-${NODEJS_VERSION}-linux-${ARCH}.tar.gz" \
 && mv /opt/node* /opt/node \
 && ln -s /opt/node/bin/* /usr/bin/ \
 && echo  "PATH=/opt/node/bin:$PATH" >> /etc/bash.bashrc \
 && echo "@ Version of Node/NPM:" `node -v` `npm -v`

# Setup Jupyter: Basic Configurations and Extensions...
RUN pip install -Uq jupyterhub jupyterlab notebook ipywidgets qpod_hub \
 && mkdir -p /opt/conda/etc/jupyter/ && mv /opt/utils/jupyter_notebook_config.json /opt/conda/etc/jupyter/ \     
 && jupyter nbextension     enable --py widgetsnbextension \
 && ln -s /opt/conda/bin/jlpm /usr/bin/yarn \
 && echo "@ Version of Yarn:" `yarn -v` \
 && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
 && mv /opt/utils/start-*.sh /usr/local/bin/ && chmod +x /usr/local/bin/start-*.sh \
 && echo "@ Version of Jupyter Notebook/JupyterLab:" \
      `jupyter notebook --version` `jupyter lab --version`

# Install Bash Kernel kernel.
RUN pip  install -Uq bash_kernel && python -m bash_kernel.install --sys-prefix

# If installing more extension for Jupyter.
RUN ${ARG_EXTEND_JUPYTER:-false}     && source /opt/utils/script-utils.sh \
 && install_apt /opt/utils/install_list_JPY_extend.apt \
 && install_pip /opt/utils/install_list_JPY_extend.pip \
 && ipcluster nbextension enable \
 && jupyter serverextension enable  --sys-prefix --py jupyterlab_git \
 && jupyter nbextensions_configurator enable --sys-prefix \
 && jupyter contrib nbextension install --sys-prefix \
 && jupyter labextension install --no-build \
     @jupyterlab/toc    @jupyterlab/shortcutui \
     @jupyterlab/latex  @jupyterlab/git \
     @jupyterlab/fasta-extension  @jupyterlab/geojson-extension \
     @jupyterlab/plotly-extension @jupyterlab/mathjax3-extension \
     @jupyterlab/dataregistry-extension @jupyterlab/commenting-extension \
     # @jupyterlab/metadata-extension <- remove temporarily for react version conflict
 && jupyter lab build \
 && echo "@ Jupyter Extension list:" \
 && jupyter nbextension list \
 && jupyter serverextension list \
 && jupyter labextension list \
 || true

# If keeping NodeJS, then install NodeJS Kernel, else remove it to reduce image size.
RUN ${ARG_NODEJS:-false} \
 && ( npm install -g --unsafe-perm --python=python2.7 ijavascript \
      && /opt/node/bin/ijsinstall --install=global --spec-path=full \
      && mv /usr/local/share/jupyter/kernels/javascript /opt/conda/share/jupyter/kernels/ \
    ) \
 || ( echo "Removing Node/NPM..." && rm -rf /usr/bin/node /usr/bin/npm /usr/bin/npx /opt/node )

# If installing LaTex and LaTex CJK packages.
RUN source /opt/utils/script-utils.sh \
 && ( ${ARG_LATEX_BASE:-false}       && install_apt   /opt/utils/install_list_latex_base.apt     || true ) \
 && ( ${ARG_LATEX_CJK:-false}        && install_apt   /opt/utils/install_list_latex_cjk.apt      || true )

# If installing coder-server  # https://github.com/cdr/code-server/releases
RUN ${ARG_EXTEND_JUPYTER:-false}     && source /opt/utils/script-utils.sh \
 && VERSION_CODER=$(wget --no-check-certificate -qO- https://github.com/cdr/code-server/releases.atom | grep 'releases/tag' | head -1 ) \
 && VERSION_CODER=$(echo $VERSION_CODER | cut -d \" -f6 | cut -d \/ -f8 ) \
 && install_tar_gz "https://github.com/cdr/code-server/releases/download/${VERSION_CODER}/code-server${VERSION_CODER}-linux-x86_64.tar.gz" \
 && mv /opt/code-server* /opt/code-server \
 && ln -s /opt/code-server/code-server /usr/bin/ \
 && printf '#!/bin/bash\n/opt/code-server/code-server --port=8888 ~' > /usr/local/bin/start-code-server.sh \
 && chmod u+x /usr/local/bin/start-code-server.sh \
 && echo "@ coder-server Version:" && /opt/code-server/code-server -v \
 || true

# Clean up and display components version information...
RUN source /opt/utils/script-utils.sh \
 && install__clean && cd \
 && echo "@ Version of image: building finished at:" `date` `uname -a` \
 && echo "@ System environment variables:" `printenv`

WORKDIR $HOME_DIR
EXPOSE 8888
CMD ["start-notebook.sh"]

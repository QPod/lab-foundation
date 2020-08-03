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


ENTRYPOINT ["tini", "-g", "--"]


# Install NodeJS (required to build JupyterLab Extensions later) # NODEJS_VERSION_MAJOR="$(cut -d '.' -f 1 <<< "$NODEJS_VERSION")"
RUN source /opt/utils/script-setup.sh && setup_node

# Setup Jupyter: Basic Configurations and Extensions...
RUN pip install -Uq jupyterhub jupyterlab notebook ipywidgets qpod_hub 'mistune<2,>0.8.1' \
 # TEMP fix: nbconver requires mistune<2,>0.8.1 for now
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
 # TEMP fix: jupyterlab_git is not compatible with JupyterLab 2.0
 # && jupyter serverextension enable  --sys-prefix --py jupyterlab_git \
 && jupyter nbextensions_configurator enable --sys-prefix \
 && jupyter contrib nbextension install --sys-prefix \
 && jupyter labextension install --no-build \
     @jupyterlab/toc @jupyterlab/shortcutui @jupyterlab/git \
     @jupyterlab/mathjax3-extension @jupyterlab/fasta-extension @jupyterlab/geojson-extension \
     @jupyterlab/commenting-extension \
     # TEMP fix: not compatible with JupyterLab 2.0
     # @jupyterlab/latex @jupyterlab/plotly-extension @jupyterlab/metadata-extension @jupyterlab/dataregistry-extension 
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
 && VERSION_CODER=$(echo $VERSION_CODER | cut -d '"' -f6 | cut -d \/ -f8 ) \
 && install_tar_gz "https://github.com/cdr/code-server/releases/download/${VERSION_CODER}/code-server-${VERSION_CODER}-linux-x86_64.tar.gz" \
 && mv /opt/code-server* /opt/code-server \
 && ln -s /opt/code-server/code-server /usr/bin/ \
 && printf '#!/bin/bash\n/opt/code-server/code-server --port=8888 --auth=none --disable-telemetry $HOME\n' > /usr/local/bin/start-code-server.sh \
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

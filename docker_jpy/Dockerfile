# Distributed under the terms of the Modified BSD License.

ARG repository
ARG base
FROM ${repository}:${base:-base}


ARG ARG_EXTEND_JUPYTER=true
ARG ARG_NODEJS=true
ARG ARG_LATEX_BASE=false
ARG ARG_LATEX_CJK=false


LABEL maintainer="haobibo@gmail.com"

COPY work /opt/utils/


# Install OS libraries and setup some configurations; Build and install tini, which will be entry point later...
RUN cd /tmp \
 && wget -qO- "https://github.com/krallin/tini/archive/v0.18.0.zip" -O tini.zip && unzip -q /tmp/tini.zip \
 && cmake /tmp/tini-* && make install && mv /tmp/tini /usr/local/bin/tini && chmod +x /usr/local/bin/tini

ENTRYPOINT ["tini", "-g", "--"]


# Install NodeJS (required to build JupyterLab Extensions later)
RUN DISTRO=$(lsb_release -c -s) \
 && echo "deb     https://deb.nodesource.com/node_11.x ${DISTRO} main"     > /etc/apt/sources.list.d/nodesource.list \
 && echo "deb-src https://deb.nodesource.com/node_11.x ${DISTRO} main"    >> /etc/apt/sources.list.d/nodesource.list \
 && wget -qO- "https://deb.nodesource.com/gpgkey/nodesource.gpg.key"      | apt-key add - \
 && apt-get -y update --fix-missing && apt-get -qq install -y --no-install-recommends nodejs \
 && echo "@ Version of Node/NPM:" `node -v` `npm -v`

# Some Python packages are required when building zeromq, iJavaScript, canvas, etc...
# They will be removed later in this docker image.  |--->>>
RUN apt-get -qq install -y --no-install-recommends python-pip \
 && pip2 install -UIq setuptools && pip2 install compiler


# Setup Jupyter: Basic Configurations and Extensions...
RUN pip install -UIq jupyterhub jupyterlab notebook \
      ipywidgets nbserverproxy \
 && mkdir -p /opt/conda/etc/jupyter/ && mv /opt/utils/jupyter_notebook_config.json /opt/conda/etc/jupyter/ \     
 && jupyter nbextension     enable --py widgetsnbextension \
 && ln -s /opt/conda/bin/jlpm /usr/bin/yarn \
 && npm install -g webpack webpack-command \
 && echo "@ Version of Yarn/WebPack:" `yarn -v` `npm list -g | grep webpack` \
 && jupyter serverextension enable  --sys-prefix --py nbserverproxy \
 && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
 && mv /opt/utils/start-*.sh /usr/local/bin/ && chmod +x /usr/local/bin/start-*.sh \
 && echo "@ Version of Jupyter Notebook/JupyterHub/JupyterLab:" \
      `jupyter notebook --version` `jupyterhub --version` `jupyter lab --version`

# Install Bash Kernel kernel.
RUN pip  install -UIq bash_kernel && python -m bash_kernel.install --sys-prefix

# If installing more extension for Jupyter.
RUN ${ARG_EXTEND_JUPYTER:-false}     && source /opt/utils/script-utils.sh \
 && install_apt /opt/utils/install_list_JPY_extend.apt \
 && install_pip /opt/utils/install_list_JPY_extend.pip \
 && ipcluster nbextension enable \
 && jupyter serverextension enable  --sys-prefix --py jupyterlab_git \
 && jupyter serverextension enable  --sys-prefix --py ipyparallel \
 && jupyter nbextension     install --sys-prefix --py ipyparallel \
 && jupyter nbextension     enable  --sys-prefix --py ipyparallel \
 && jupyter nbextensions_configurator enable --sys-prefix \
 && jupyter contrib nbextension install --sys-prefix \
 && jupyter labextension install --no-build \
     @jupyterlab/toc  @jupyterlab/latex  @jupyterlab/git \
     @jupyterlab/fasta-extension  @jupyterlab/geojson-extension \
     @jupyterlab/plotly-extension @jupyterlab/mathjax3-extension \
     @jupyterlab/hub-extension \
     # @jupyterlab/shortcutui  @jupyterlab/statusbar   \ # temporarily remove conflict packages with version conflict
 && export NODE_OPTIONS=--max-old-space-size=4096 \
 # && git clone https://github.com/jupyterlab/jupyterlab-monaco.git /tmp/jupyterlab-monaco && cd /tmp/jupyterlab-monaco \
 # && yarn install && yarn run build && jupyter labextension install . \
 && jupyter lab build \
 && echo "@ Jupyter Extension list:" \
 && jupyter nbextension list \
 && jupyter serverextension list \
 && jupyter labextension list \
 || true

# If keeping NodeJS, then install NodeJS Kernel, else remove it to reduce image size (keep the apt source for future installation).
RUN ${ARG_NODEJS:false} \
 && ( npm install -g --unsafe-perm --python=python2 ijavascript && ijsinstall --install=global --spec-path=full ) \
 || ( echo "Removing Node/NPM removed..." && apt-get remove -y nodejs )

# Remove unused packages <<<---|
RUN pip2 uninstall -y compiler setuptools && apt-get remove -y python-pip python-pip-whl

# If installing LaTex and LaTex CJK packages.
RUN  source /opt/utils/script-utils.sh \
    && ( ${ARG_LATEX_BASE:-false}       && install_apt   /opt/utils/install_list_latex_base.apt     || true ) \
    && ( ${ARG_LATEX_CJK:-false}        && install_apt   /opt/utils/install_list_latex_cjk.apt      || true )


# Clean up and display components version information...
RUN  source /opt/utils/script-utils.sh \
  && install__clean && cd \
  && echo "@ Version of image: building finished at:" `date` `uname -a` \
  && echo "@ System environment variables:" `printenv`


WORKDIR $HOME_DIR
EXPOSE 8888
CMD ["start-notebook.sh"]

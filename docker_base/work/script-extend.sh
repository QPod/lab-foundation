source /opt/utils/script-utils.sh

setup_jupyter() {
    # TEMP fix: nbconver requires mistune<2,>0.8.1 for now
       pip install -Uq jupyterhub jupyterlab notebook ipywidgets qpod_hub "mistune<2,>0.8.1" \
    && mkdir -p /opt/conda/etc/jupyter/ \
    && mv /opt/utils/jupyter_notebook_config.json /opt/conda/etc/jupyter/ \
    && jupyter nbextension     enable --py widgetsnbextension \
    && ln -s /opt/conda/bin/jlpm /usr/bin/yarn \
    && echo "@ Version of Yarn:" `yarn -v` \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
    && mv /opt/utils/start-*.sh /usr/local/bin/ && chmod +x /usr/local/bin/start-*.sh \
    && echo "@ Version of Jupyter Notebook/JupyterLab:" \
        `jupyter notebook --version` `jupyter lab --version`
}


setup_jupyter_kennels() {
    # Install Bash Kernel
    pip install -Uq bash_kernel && python -m bash_kernel.install --sys-prefix

    # Install NodeJS Kernel
    which npm \
    && npm install -g --unsafe-perm --python=python2.7 ijavascript \
    && /opt/node/bin/ijsinstall --install=global --spec-path=full \
    && mv /usr/local/share/jupyter/kernels/javascript /opt/conda/share/jupyter/kernels/ \
    || true

    which java \
    && pip install -Uq beakerx pandas py4j  \
    && beakerx install \
    && jupyter labextension list \
    || true
    # TEMP fix: not compatible with JupyterLab 2.0
    # && jupyter labextension install beakerx-jupyterlab \

    which julia \
    && julia -e "using Pkg; Pkg.add(\"IJulia\"); Pkg.precompile();" \
    && mv ~/.local/share/jupyter/kernels/julia* /opt/conda/share/jupyter/kernels/ \
    && echo "@ Version of julia:" && julia -e "using Pkg; for(k,v) in Pkg.dependencies(); println(v.name,\"==\",v.version); end" \
    || true

    which go \
    && export GOPATH=/opt/go/path \
    && go get -u github.com/gopherdata/gophernotes \
    && mkdir -p /opt/conda/share/jupyter/kernels/gophernotes \
    && cp $GOPATH/src/github.com/gopherdata/gophernotes/kernel/* /opt/conda/share/jupyter/kernels/gophernotes \
    && ln -s $GOPATH/bin/gophernotes /usr/local/bin \
    || true
    
    which octave \
    && export PATH=/opt/octave/bin:$PATH \
    && pip install -Uq octave_kernel \
    || true
}


setup_jupyter_extend() {
       install_apt /opt/utils/install_list_JPY_extend.apt \
    && install_pip /opt/utils/install_list_JPY_extend.pip \
    && ipcluster nbextension enable
    
    # TEMP fix: jupyterlab_git is not compatible with JupyterLab 2.0
    # && jupyter serverextension enable  --sys-prefix --py jupyterlab_git \
       jupyter nbextensions_configurator enable --sys-prefix \
    && jupyter contrib nbextension install --sys-prefix \
    && jupyter labextension install --no-build \
        @jupyterlab/toc @jupyterlab/shortcutui @jupyterlab/git \
        @jupyterlab/mathjax3-extension @jupyterlab/fasta-extension @jupyterlab/geojson-extension \
        @jupyterlab/commenting-extension
        # TEMP fix: not compatible with JupyterLab 2.0
        # @jupyterlab/latex @jupyterlab/plotly-extension @jupyterlab/metadata-extension @jupyterlab/dataregistry-extension

       jupyter lab build \
    && echo "@ Jupyter Extension list:" \
    && jupyter nbextension list \
    && jupyter serverextension list \
    && jupyter labextension list
}


setup_vscode() {
       VERSION_CODER=$(wget --no-check-certificate -qO- https://github.com/cdr/code-server/releases.atom | grep "releases/tag" | head -1 ) \
    && VERSION_CODER=$(echo $VERSION_CODER | cut -d "\"" -f6 | cut -d \/ -f8 ) \
    && install_tar_gz "https://github.com/cdr/code-server/releases/download/${VERSION_CODER}/code-server-${VERSION_CODER}-linux-x86_64.tar.gz" \
    && mv /opt/code-server* /opt/code-server \
    && ln -s /opt/code-server/code-server /usr/bin/ \
    && printf "#!/bin/bash\n/opt/code-server/code-server --port=8888 --auth=none --disable-telemetry $HOME\n" > /usr/local/bin/start-code-server.sh \
    && chmod u+x /usr/local/bin/start-code-server.sh \
    && echo "@ coder-server Version:" && /opt/code-server/code-server -v
}
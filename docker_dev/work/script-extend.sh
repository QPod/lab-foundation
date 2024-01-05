source /opt/utils/script-utils.sh

setup_jupyter_base() {
     pip install -Uq --pre jupyterhub jupyterlab notebook nbclassic ipywidgets \
  && echo "@ Version of Jupyter Server: $(jupyter server --version)" \
  && echo "@ Version of Jupyter Lab: $(jupyter lab --version)" \
  && echo "@ Version of Jupyter Notebook: $(jupyter notebook --version)" \
  && echo "@ Version of JupyterHub: $(jupyterhub --version)"
}


setup_jupyter_kernels() {
  # Install Bash Kernel
  pip install -Uq bash_kernel && python -m bash_kernel.install --sys-prefix

     which npm \
  && npm install -g --unsafe-perm ijavascript \
  && /opt/node/bin/ijsinstall --install=global --spec-path=full \
  && mv /usr/local/share/jupyter/kernels/javascript /opt/conda/share/jupyter/kernels/

     which R \
  && R -e "install.packages('IRkernel')" \
  && R -e "IRkernel::installspec(user=FALSE)" \
  && mv /usr/local/share/jupyter/kernels/ir /opt/conda/share/jupyter/kernels/

     which java \
  && pip install -Uq pandas py4j
  #&& pip install beakerx && beakerx install \
  #&& jupyter labextension install beakerx-jupyterlab

     which julia \
  && julia -e "using Pkg; Pkg.add(\"IJulia\"); Pkg.precompile();" \
  && mv ~/.local/share/jupyter/kernels/julia* /opt/conda/share/jupyter/kernels/

     which go \
  && export GOPATH=/opt/go/path \
  && go get -u github.com/gopherdata/gophernotes \
  && mkdir -p /opt/conda/share/jupyter/kernels/gophernotes \
  && cp $GOPATH/src/github.com/gopherdata/gophernotes/kernel/* /opt/conda/share/jupyter/kernels/gophernotes \
  && ln -s $GOPATH/bin/gophernotes /usr/bin/
  
     which octave \
  && export PATH=/opt/octave/bin:$PATH \
  && pip install -Uq octave_kernel

  echo "@ Installed Jupyter Kernels:" && jupyter kernelspec list
}


setup_jupyter_extensions() {
     install_apt /opt/utils/install_list_JPY_extend.apt \
  && install_pip /opt/utils/install_list_JPY_extend.pip

     echo "@ Jupyter Server Extension list: " && jupyter server extension list \
  && echo "@ Jupyter Lab Extension list: " && jupyter labextension list \
  && echo "@ Jupyter Notebook Extension list: " && jupyter notebook extension list
}


setup_vscode_base() {
     VERSION_CODER=$(curl -sL https://github.com/cdr/code-server/releases.atom | grep "releases/tag" | head -1 | grep -Po '(\d[\d|.]+)') \
  && install_tar_gz "https://github.com/cdr/code-server/releases/download/v${VERSION_CODER}/code-server-${VERSION_CODER}-linux-amd64.tar.gz" \
  && mv /opt/code-server* /opt/code-server \
  && ln -s /opt/code-server/bin/code-server /usr/bin/ \
  && printf "#!/bin/bash\n/opt/code-server/bin/code-server --port=8888 --auth=none --disable-telemetry ${HOME}\n" > /usr/local/bin/start-code-server.sh \
  && chmod u+x /usr/local/bin/start-code-server.sh \
  && echo "@ coder-server Version: $(code-server -v)"
}

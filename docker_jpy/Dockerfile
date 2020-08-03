# Distributed under the terms of the Modified BSD License.

ARG BASE_REPO
ARG BASE_TAG
FROM ${BASE_REPO}:${BASE_TAG:-core}

LABEL maintainer="haobibo@gmail.com"

ARG ARG_EXTEND_JUPYTER=true
ARG ARG_NODEJS=true
ARG ARG_LATEX_BASE=false
ARG ARG_LATEX_CJK=false


COPY work /opt/utils/


ENTRYPOINT ["tini", "-g", "--"]


# Install NodeJS (required to build JupyterLab Extensions later)
RUN source /opt/utils/script-setup.sh && setup_node

# Setup Jupyter: Basic Configurations and Extensions...
RUN source /opt/utils/script-extend.sh && setup_jupyter

# If installing more extension for Jupyter.
RUN ${ARG_EXTEND_JUPYTER:-false}  && source /opt/utils/script-extend.sh && setup_jupyter_extend || true

# If not keeping NodeJS, remove NoedJS to reduce image size
RUN ${ARG_NODEJS:-false} || ( echo "Removing Node/NPM..." && rm -rf /usr/bin/node /usr/bin/npm /usr/bin/npx /opt/node )

# If installing LaTex and LaTex CJK packages.
RUN source /opt/utils/script-utils.sh \
 && ( ${ARG_LATEX_BASE:-false}       && install_apt   /opt/utils/install_list_latex_base.apt     || true ) \
 && ( ${ARG_LATEX_CJK:-false}        && install_apt   /opt/utils/install_list_latex_cjk.apt      || true )

# If installing coder-server  # https://github.com/cdr/code-server/releases
RUN ${ARG_EXTEND_JUPYTER:-false}     && source /opt/utils/script-utils.sh && setup_vscode || true

# Clean up and display components version information...
RUN source /opt/utils/script-utils.sh && install__clean

WORKDIR $HOME_DIR
EXPOSE 8888
CMD ["start-notebook.sh"]

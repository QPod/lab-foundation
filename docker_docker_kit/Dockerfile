# Distributed under the terms of the Modified BSD License.

ARG BASE_NAMESPACE
ARG BASE_IMG="base"
FROM ${BASE_NAMESPACE:+$BASE_NAMESPACE/}${BASE_IMG}

LABEL maintainer="haobibo@gmail.com"
ENV XDG_RUNTIME_DIR="/tmp"

COPY work /opt/utils/

RUN source /opt/utils/script-setup-docker.sh \
 && setup_docker_compose && setup_docker_syncer \
 && pip install -U PyYaml \
 && ln -sf /usr/bin/image-syncer /opt/utils/image-syncer/ \
 # Clean up and display components version information...
 && source /opt/utils/script-utils.sh && install__clean && list_installed_packages

# '-c' option make bash commands are read from string.
#   If there are arguments after the string, they are assigned to the positional parameters, starting with $0.
# '-o pipefail'  prevents errors in a pipeline from being masked.
#   If any command in a pipeline fails, that return code will be used as the return code of the whole pipeline.
# '--login': make bash first reads and executes commands from  the file /etc/profile, if that file exists.
#   After that, it looks for ~/.bash_profile, ~/.bash_login, and ~/.profile, in that order, and reads and executes commands from the first one that exists and is readable.
SHELL ["/bin/bash", "--login", "-o", "pipefail", "-c"]

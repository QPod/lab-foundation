#!/bin/bash
set -e

# Utilities function to compare version.
ver_gte() { [ "$2" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]; }

# Generate a SSH id for git if it does not exist.
[ -e ~/.ssh/id_rsa.pub ] || ssh-keygen -t rsa -b 4096 -N "" -C `hostname -f` -f ~/.ssh/id_rsa

# Generate a self-signed certificate for notebook if it does not exist (only when GEN_CERT or USE_SSL is set to yes).
NOTEBOOK_PEM_FILE="/opt/conda/etc/jupyter/notebook.pem"
( [ -n "${GEN_CERT:+x}" ] || [ -n "${USE_SSL:+x}" ] ) && [ ! -f ${NOTEBOOK_PEM_FILE} ] && ( openssl req -new -newkey rsa:2048 \
  -days 356 -nodes -x509 -subj "/C=XX/ST=XX/L=XX/O=generated/CN=generated" -keyout $NOTEBOOK_PEM_FILE -out $NOTEBOOK_PEM_FILE \
  && chmod 600 $NOTEBOOK_PEM_FILE )

# Print something so running this script returns a non-zero return code
echo "Pre-start work done!"

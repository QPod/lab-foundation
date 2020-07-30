
setup_conda() {   
    cd /tmp/ \
    && wget -qO- "https://repo.continuum.io/miniconda/Miniconda3-py38_4.8.3-Linux-$(arch).sh" -O conda.sh && bash /tmp/conda.sh -f -b -p /opt/conda \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false  \
    && conda config --system --set show_channel_urls true   \
    && conda config --set channel_priority strict \
    && conda update --all --quiet --yes \
    # These conda pkgs shouldn't be removed (otherwise will cause RemoveError) since they are directly reqiuired by conda: pip setuptools pycosat pyopenssl requests ruamel_yaml python-libarchive-c
    && CONDA_PY_PKGS=`conda list | grep "py3" | cut -d " " -f 1 | sed "/#/d;/conda/d;/pip/d;/setuptools/d;/pycosat/d;/pyopenssl/d;/requests/d;/ruamel_yaml/d;/python-libarchive-c/d;"` \
    && conda remove --force -yq $CONDA_PY_PKGS \
    && pip install -UIq pip setuptools $CONDA_PY_PKGS \
    # Replace system Python3 with Conda's Python, and take care of `lsb_releaes`
    && rm /usr/bin/python3 && ln -s /opt/conda/bin/python /usr/bin/python3 \
    && mv /usr/share/pyshared/lsb_release.py /usr/bin/ \
    # Print Conda and Python packages information in the docker build log
    && echo "@ Version of Conda & Python:" && conda info && conda list | grep -v "<pip>"
}
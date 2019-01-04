

# function to debug, resolve package names from a text file and display.
install_echo() { cat $1 | cut -d "%" -f 1 | sed '/^$/d' | xargs -n1 echo "#" ; }

# function to install apt-get packages from a text file which lists package names (add comments with % char)
install_apt()  { apt-get -y update --fix-missing && apt-get -qq install -y --no-install-recommends `cat $1 | cut -d '%' -f 1` ; }

# function to install conda packages from a text file which lists package names (add comments with % char)
install_conda(){ cat $1 | cut -d "%" -f 1 | sed '/^$/d' | xargs -n1 conda install -yq ; }

# function to install python packages with pip from a text file which lists package names (add comments with % char)
install_pip()  { cat $1 | cut -d "%" -f 1 | sed '/^$/d' | xargs -n1 pip install -U ; }

# function to install R packages from a text file which lists package names (add comments with % char)
install_R()    { R -e "install.packages(scan('$1','c',comment.char='%'),quiet=T,clean=T)" ; }

# function to download a ZIP file with wget and unzip it to /opt/
install_zip()  { wget -nv $1 -O /tmp/TMP.zip && unzip -q /tmp/TMP.zip -d /opt/ && rm /tmp/TMP.zip ; }

# function to install java packages from a text file which lists JAR file maven full names (add comments with % char)
install_mvn()  { cat $1 | cut -d "%" -f 1 | xargs -n1 -I {} mvn dependency:copy -DlocalRepositoryDirectory="/tmp/m2repo" -Djavax.net.ssl.trustStorePassword=changeit -Dartifact="{}" -DoutputDirectory="$2" ; }

# function to clean up
install__clean(){
  which apt-get && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*
  which conda   && conda clean -ya
  which npm     && npm cache clean --force
  rm -rf /opt/conda/share/jupyter/lab/staging
  ( rm -rf /root/.* /tmp/.* /tmp/* || true )
}

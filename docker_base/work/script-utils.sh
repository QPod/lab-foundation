
# function to debug, resolve package names from a text file and display.
install_echo() { cat $1 | cut -d "%" -f 1 | sed '/^$/d' | xargs -n1 printf '%s\n' ; }

# function to install apt-get packages from a text file which lists package names (add comments with % char)
install_apt()  { apt-get -y update --fix-missing && apt-get -qq install -y --no-install-recommends `cat $1 | cut -d '%' -f 1` ; }

# function to install conda packages from a text file which lists package names (add comments with % char)
install_conda(){ cat $1 | cut -d "%" -f 1 | sed '/^$/d' | xargs -n1 conda install -yq ; }

# function to install python packages with pip from a text file which lists package names (add comments with % char)
install_pip()  { cat $1 | cut -d "%" -f 1 | sed '/^$/d' | xargs -n1 pip install -U --pre ; }

# function to install R packages from a text file which lists package names (add comments with % char, use quiet=T to be less verbose)
install_R()    { R -e "options(Ncpus=4);lapply(scan('$1','c',comment.char='%'),function(x){cat(x,system.time(install.packages(x,clean=T,quiet=T)),'\n')})"; }

# function to install go packages with go from a text file which lists package names (add comments with % char)
install_go()   { cat $1 | cut -d "%" -f 1 | sed '/^$/d' | xargs -n1 go get -u ; }

# function to install julia packages from a text file which lists package names (add comments with % char)
install_julia()  { julia -e "import Pkg; l=filter(x->length(x)>0, [split(i,r\"%| |\t\")[1] for i in readlines(\"$1\")]); Pkg.add(l)" ; }

# function to install octave packages with go from a text file which lists package names (add comments with % char)
install_octave() { cat $1 | cut -d "%" -f 1 | sed '/^$/d' | xargs -n1  -I {} sh -c 'octave --eval "pkg install -forge {}"' ; }

# function to download a ZIP file with wget and unzip it to /opt/
install_zip()  { wget -nv $1 -O /tmp/TMP.zip && unzip -q /tmp/TMP.zip -d /opt/ && rm /tmp/TMP.zip ; }

# function to download a .tar.gz file with wget and unzip it to /opt/, add a second argument to extract only those file
install_tar_gz()  { wget -nv $1 -O /tmp/TMP.tar.gz && tar -C /opt/ -xzf /tmp/TMP.tar.gz $2 && rm /tmp/TMP.tar.gz ; }

# function to download a .tar.xz file with wget and unzip it to /opt/, add a second argument to extract only those file
install_tar_xz()  { wget -nv $1 -O /tmp/TMP.tar.xz && tar -C /opt/ -xJf /tmp/TMP.tar.xz $2 && rm /tmp/TMP.tar.xz ; }

# function to install java packages from a text file which lists JAR file maven full names (add comments with % char)
install_mvn()  { cat $1 | cut -d "%" -f 1 | xargs -n1 -I {} mvn dependency:copy -DlocalRepositoryDirectory="/tmp/m2repo" -Djavax.net.ssl.trustStorePassword=changeit -Dartifact="{}" -DoutputDirectory="$2" ; }

# function to clean up
install__clean(){
  which apt-get && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*
  which conda   && conda clean -ya
  which npm     && npm cache clean --force
  rm -rf /opt/conda/share/jupyter/lab/staging
  ( rm -rf /root/.* /tmp/.* /tmp/* /var/log/* /var/cache/* || true )
}

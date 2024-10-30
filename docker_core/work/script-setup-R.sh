source /opt/utils/script-utils.sh


setup_R_datascience() {
     install_apt  /opt/utils/install_list_R_datascience.apt \
  && install_R    /opt/utils/install_list_R_datascience.R
}

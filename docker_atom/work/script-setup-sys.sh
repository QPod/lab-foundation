source /opt/utils/script-utils.sh


setup_tini() {
     cd /tmp \
  && TINI_VERSION=$(curl -sL https://github.com/krallin/tini/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[\d.]+' ) \
  && curl -o tini.zip -sL "https://github.com/krallin/tini/archive/v${TINI_VERSION}.zip" && unzip -q /tmp/tini.zip \
  && cmake /tmp/tini-* && make install && mv /tmp/tini /usr/bin/tini && chmod +x /usr/bin/tini && rm -rf /tmp/tini-*
  # ref: https://cloud-atlas.readthedocs.io/zh-cn/latest/docker/init/docker_tini.html
  # to run multi-proces with tini: use a bash script ends with the following code
  # main() { *other code* /bin/bash -c "while true; do (echo 'Hello from tini'; date; sleep 120); done" } main
}


setup_systemd() {
    apt-get -qq update -yq --fix-missing \
 && apt-get -qq install -yq --no-install-recommends systemd systemd-cron \
 && rm -f /lib/systemd/system/systemd*udev* \
 && rm -f /lib/systemd/system/getty.target
 # ref: https://cloud-atlas.readthedocs.io/zh_CN/latest/docker/init/docker_systemd.html
 # ENTRYPOINT [ "/usr/lib/systemd/systemd" ]
 # CMD [ "log-level=info", "unit=sysinit.target" ]
}

source /opt/utils/script-utils.sh

setup_systemd() {
    apt-get -qq update -yq --fix-missing \
 && apt-get -qq install -yq --no-install-recommends systemd systemd-cron \
 && rm -f /lib/systemd/system/systemd*udev* \
 && rm -f /lib/systemd/system/getty.target \
 && rm -Rf /usr/share/doc && rm -Rf /usr/share/man
 # ref: https://cloud-atlas.readthedocs.io/zh_CN/latest/docker/init/docker_systemd.html
 # ENTRYPOINT [ "/usr/lib/systemd/systemd" ]
 # CMD [ "log-level=info", "unit=sysinit.target" ]
}

source /opt/utils/script-utils.sh


setup_traefik() {
     TRAEFIK_VERSION=$(curl -sL https://github.com/traefik/traefik/releases.atom | grep 'releases/tag' | head -1 | grep -Po '\d[\d.]+') \
  && TRAEFIK_URL="https://github.com/traefik/traefik/releases/download/v${TRAEFIK_VERSION}/traefik_v${TRAEFIK_VERSION}_linux_$(dpkg --print-architecture).tar.gz" \
  && install_tar_gz "${TRAEFIK_URL}" traefik \
  && ln -sf /opt/traefik /usr/bin/ ;
  
  type traefik && echo "@ Version of traefik: $(traefik version)" || return -1 ;
}

setup_caddy() {
  OS="linux" && ARCH="amd64" \
  && VER_CADDY=$(curl -sL https://github.com/caddyserver/caddy/releases.atom | grep "releases/tag" | grep -v 'beta' | head -1 | grep -Po '(\d[\d|.]+)') \
  && URL_CADDY="https://github.com/caddyserver/caddy/releases/download/v${VER_CADDY}/caddy_${VER_CADDY}_${OS}_${ARCH}.tar.gz" \
  && echo "Downloading Caddy ${VER_CADDY} from ${URL_CADDY}" \
  && curl -o /tmp/TMP.tgz -sL $URL_CADDY && tar -C /tmp/ -xzf /tmp/TMP.tgz && rm /tmp/TMP.tgz \
  && mkdir -pv /opt/bin/ && mv /tmp/caddy /opt/bin/ && ln -sf /opt/bin/caddy /usr/local/bin/ ;

  type caddy && echo "@ Version of caddy: $(caddy version)" || return -1 ;
}

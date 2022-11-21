source /opt/utils/script-utils.sh


setup_postgresql_client() {
  local VER_PG=${VERSION_PG:-"14"}
  # from: https://www.postgresql.org/download/linux/ubuntu/
  echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
  curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo apt-get update
  # will download ~9MB files and use ~55MB disk after installation
  sudo apt-get -y install "postgresql-client-${VER_PG}"
  echo "@ Version of psql client: $(psql --version)"
}


setup_mysql_client() {
  sudo apt-get update
  # will download ~5MB files and use ~76MB disk after installation
  sudo apt-get -y install mysql-client
  echo "@ Version of mysql client: $(mysql --version)"
}


setup_mongosh_client() {
  # from: https://www.mongodb.com/docs/mongodb-shell/install/
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-6.0.list
  curl -sL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
  sudo apt-get update
  # will download ~38MB files and use ~218MB disk after installation
  sudo apt-get -y install mongodb-mongosh
  echo "@ Version of mongosh client: $(mongosh --version)"
}


setup_redis_client() {
  # from https://redis.io/docs/getting-started/installation/install-redis-on-linux/
  curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
  sudo apt-get update
  sudo apt-get -y install redis-tools
  echo "@ Version of redis-cli: $(redis-cli --version)"
}

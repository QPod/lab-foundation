#! /bin/sh
set -ex

export TZ=${TZ:="Asia/Shanghai"}
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone
echo "Setup timezone, current date: $(date)"

if [ -f /etc/apt/sources.list ]; then
  echo "Found Ubuntu/debian system, using default ubuntu/debian mirror"
fi

if command -v python &> /dev/null; then
  echo "Found python, using default pypi source in /etc/pip.conf"
  pip config list
fi

if [ -f "$(which npm)" ]; then
  echo "Found npm, using default npm mirror"
  npm config list
fi

if command -v go &> /dev/null; then
  echo "Found golang, getting GO env:"
  go env | sort
fi

if command -v R &> /dev/null; then
  echo "Found R, getting CRAN mirror"
  R -e "options('repos');"
fi

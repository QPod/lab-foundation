#! /bin/sh
set -ex

echo "Setup mirror config for Tsinghua Tuna Environment..."

export TZ=${TZ:="Asia/Shanghai"}
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone
echo "Setup timezone, current date: $(date)"

if [ -f /etc/apt/sources.list ]; then
  echo "Found Ubuntu/debian system, setting ubuntu/debian mirror"

  sed -i 's/mirrors.*.com\/ubuntu/mirrors.tuna.tsinghua.edu.cn\/ubuntu/' /etc/apt/sources.list
  sed -i 's/archive.ubuntu.com\/ubuntu/mirrors.tuna.tsinghua.edu.cn\/ubuntu/' /etc/apt/sources.list
  sed -i 's/security.ubuntu.com\/ubuntu/mirrors.tuna.tsinghua.edu.cn\/ubuntu/' /etc/apt/sources.list

  sed -i 's/deb.debian.org\/debian/mirrors.tuna.tsinghua.edu.cn\/debian/' /etc/apt/sources.list
fi

if [ -f "$(which python)" ]; then
  echo "Found python, setting pypi source in /etc/pip.conf"
  cat >/etc/pip.conf <<EOF
[global]
progress_bar=off
root-user-action=ignore
retries=5
timeout=180
trusted-host=pypi.python.org pypi.org files.pythonhosted.org mirrors.tuna.tsinghua.edu.cn
index-url=http://mirrors.tuna.tsinghua.edu.cn/pypi/simple/
EOF
  pip config list
fi

if [ -f "$(which npm)" ]; then
  echo "Found npm, setting npm mirror"
  npm config set registry https://registry.npmmirror.com
  npm config list
fi

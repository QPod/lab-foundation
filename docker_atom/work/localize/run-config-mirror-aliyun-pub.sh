#! /bin/sh
set -ex

echo "Setup mirror config for Aliyun Public Cloud..."

export TZ=${TZ:="Asia/Shanghai"}
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone
echo "Setup timezone, current date: $(date)"

eval "export $(cat /etc/os-release  | grep ID=)" && export OS_ID=${ID} && echo "Found ${ID} system, setting mirror for ${ID}"

if [ -f /etc/apt/sources.list ]; then
   [ -f /etc/apt/sources.list.d/${OS_ID}.sources ] && ln -sf /etc/apt/sources.list.d/${OS_ID}.sources /etc/apt/sources.list
  sed -i 's/mirrors.*.com\/ubuntu/mirrors.aliyun.com\/ubuntu/' /etc/apt/sources.list
  sed -i 's/archive.ubuntu.com\/ubuntu/mirrors.aliyun.com\/ubuntu/' /etc/apt/sources.list
  sed -i 's/security.ubuntu.com\/ubuntu/mirrors.aliyun.com\/ubuntu/' /etc/apt/sources.list
  sed -i 's/deb.debian.org\/debian/mirrors.aliyun.com\/debian/' /etc/apt/sources.list
  echo "Finished setting ubuntu/debian mirror"
fi

if [ -f "$(which python)" ]; then
  echo "Found python, setting pypi source in /etc/pip.conf"
  cat >/etc/pip.conf <<EOF
[global]
progress_bar=off
root-user-action=ignore
retries=5
timeout=180
trusted-host=pypi.python.org pypi.org files.pythonhosted.org mirrors.aliyun.com
index-url=http://mirrors.aliyun.com/pypi/simple/
EOF
  pip config list
fi

if [ -f "$(which npm)" ]; then
  echo "Found npm, setting npm mirror"
  npm config set registry https://registry.npmmirror.com
  npm config list
fi

if [ -f "$(which go)" ]; then
  echo "Found golang, setting GOPROXY"
  export GOPROXY=https://mirrors.aliyun.com/goproxy/
  go env | grep 'PROXY'
fi

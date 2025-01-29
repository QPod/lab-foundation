#! /bin/sh
set -ex

echo "Setup mirror config for Tsinghua Tuna Environment..."

export TZ=${TZ:="Asia/Shanghai"}
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone
echo "Setup timezone, current date: $(date)"

eval "export $(cat /etc/os-release  | grep ID=)" && export OS_ID=${ID} && echo "Found ${ID} system, setting mirror for ${ID}"

FILE_DEB=$([ -f /etc/apt/sources.list.d/${OS_ID}.sources  ] && echo /etc/apt/sources.list.d/${OS_ID}.sources || echo /etc/apt/sources.list )
if [ -f $FILE_DEB ]; then
  sed -i 's/mirrors.*.com\/ubuntu/mirrors.tuna.tsinghua.edu.cn\/ubuntu/'        $FILE_DEB
  sed -i 's/archive.ubuntu.com\/ubuntu/mirrors.tuna.tsinghua.edu.cn\/ubuntu/'   $FILE_DEB
  sed -i 's/security.ubuntu.com\/ubuntu/mirrors.tuna.tsinghua.edu.cn\/ubuntu/'  $FILE_DEB
  sed -i 's/deb.debian.org\/debian/mirrors.tuna.tsinghua.edu.cn\/debian/'       $FILE_DEB
  echo "Finished setting ubuntu/debian mirror"
fi

if command -v python &> /dev/null; then
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

for cmd in npm pnpm yarn bun; do
  if command -v "$cmd" &> /dev/null; then
    echo "Found $cmd, setting mirror"
    "$cmd" config set registry https://registry.npmmirror.com
    "$cmd" config list
    echo
  fi
done

if command -v go &> /dev/null; then
  echo "Found golang, setting GOPROXY"
  export GOPROXY=https://goproxy.cn
  go env | grep 'PROXY'
fi

if command -v R &> /dev/null; then
  echo "Found R, setting CRAN mirror"
  echo "options(repos=structure(c(CRAN=\"https://mirrors.tuna.tsinghua.edu.cn/CRAN/\")))" >> /etc/R/Rprofile.site
  R -e "options('repos');"
fi

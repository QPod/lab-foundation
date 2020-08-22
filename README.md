# QPod - Docker Image Stack

[![License](https://img.shields.io/badge/License-BSD%203--Clause-green.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![TravisCI Pipeline Status](https://img.shields.io/travis/com/QPod/docker-images.svg)](https://travis-ci.com/QPod/docker-images)
[![Join the Gitter Chat](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/QPod/)
[![Docker Pulls](https://img.shields.io/docker/pulls/qpod/qpod.svg)](https://hub.docker.com/r/qpod/qpod)
[![Docker Starts](https://img.shields.io/docker/stars/qpod/qpod.svg)](https://hub.docker.com/r/qpod/qpod)
[![Recent Code Update](https://img.shields.io/github/last-commit/QPod/docker-images.svg)](https://github.com/QPod/docker-images/stargazers)

Please generously STAR★ our project or donate to us!  [![GitHub Starts](https://img.shields.io/github/stars/QPod/docker-images.svg?label=Stars&style=social)](https://github.com/QPod/docker-images/stargazers)
[![Donate-PayPal](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://paypal.me/haobibo)
[![Donate-AliPay](https://img.shields.io/badge/Donate-Alipay-blue.svg)](https://raw.githubusercontent.com/wiki/haobibo/resources/img/Donate-AliPay.png)
[![Donate-WeChat](https://img.shields.io/badge/Donate-WeChat-green.svg)](https://raw.githubusercontent.com/wiki/haobibo/resources/img/Donate-WeChat.png)

[Wiki & FAQ](https://github.com/QPod/docker-images/wiki) | [中文使用指引(含中国地区镜像)](https://github.com/QPod/docker-images/wiki/QPod%E4%B8%AD%E6%96%87%E6%8C%87%E5%BC%95)

## Your Swiss Army Knife for AI & Data Science

In a nutshell, `QPod` ( [DockerHub](https://hub.docker.com/r/qpod/qpod/) | [GitHub](https://github.com/QPod/docker-images) ) is an **out-of-box Data Science / AI environment and platform** at your fingertip which you would love 💕.

With Docker and `QPod`, you

- 📦 can start your data science / AI projects with nearly `zero configuration` - QPod puts everything about installing (latest) packages and configuring environment into standard docker images and set you free from these tedious work.
- 🌍 will find your work more `easy-to-reproduce` - QPod standard images make scientific research or data analysis project as [reproducible pipelines](https://doi.org/10.1038/d41586-018-07196-1) and help you [share your work with others](https://doi.org/10.1038/515151a).
- 🆙 can easily `scale-up and scale-out` your algorithms and key innovations - QPod help you move forward smoothly from the development stage to deployment stage by re-using these images to either to provide RESTful APIs or orchestrate map/reduce operations on big data.

![Screenshot of QPod](https://raw.githubusercontent.com/wiki/QPod/qpod-hub/img/QPod-screenshot.webp "Screenshot of QPod")

## What's actually there

`QPod` curates and maintains a series of Docker images including interactive computing environment to run a Jupyter Notebook (or JupyterLab) with Python, R, OpenJDK, NodeJS, Go, Julia, Octave etc. Other IDE-like tools (e.g VS Code, R-Studio) are also included.

`QPod` supports use cases of both research and production:

- (Stand-alone) Use it on your laptop as default data science / develop environment.
- (Multi-tenant) Use it on a server/cluster to host multiple users to exploit hardware resources like GPU.
- (Deployment/Production) Use it as the base image to host RESTful APIs or work as executors or map/reduce operations.

![QPod-tech-arch](https://raw.githubusercontent.com/wiki/QPod/docker-images/img/QPod-arch.svg)

## How to use? `1-2-3-GO`🎉

### 0. Have docker installed on your laptop/server - Linux (e.g.: Ubuntu LTS) / Windows (>=10) / macOS

- Install **Docker >= 19.03**: `docker-ce` ( community version & free: [Linux](https://hub.docker.com/search/?offering=community&type=edition&operating_system=linux) | [macOS](https://download.docker.com/mac/stable/Docker.dmg) | [Windows](https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe)   ) or [docker-ee](https://hub.docker.com/search/?offering=enterprise&type=edition) (enterprise version & paid) on your laptop/server. **Docker installed from default Ubuntu/CentOS repository probably won't work for GPU!**
- If you want to use *NVIDIA GPUs* with `QPod`, Linux server is **required**. After installing **Docker >= 19.03**, also install both the [`NVIDIA driver`](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver) and the latest version of [`nvidia-container-toolkit`](https://github.com/NVIDIA/nvidia-docker#quickstart) to use the GPUs in containers.

### 1. Choose the features and choose a folder on your disk

- Choose an tag from the table at bottom of this page (`QPod` feature matrix), e.g `full`.
Typically, you can choose `full` for your laptop or `full-cuda` for a Linux server with NVIDIA GPU if you have enough disk size and no worry about your network speed.

- Choose a folder on your laptop/server to server as the base directory (e.g.: `/root`, `/User/me`, or `D:/work`). Use an absolute path instead of relative path - files in this folder are visible in the environment (files outside this folder are not).

### 2. Start the container

Change the value of `IMG` and `WORKDIR` to your choices in the script below, and run the script. Shutdown Jupyter or other service/program which are using port 8888 or 9999.

#### For Linux/macOS, run this in bash/terminal

```shell
IMG="qpod/qpod:full"
WORKDIR="/root"  # <- macOS change this to /Users/your_user_name

docker run -d --restart=always \
    --name=QPod \
    --hostname=QPod \
    -p 8888:8888 -p 9999:9999 \
    -v $WORKDIR:/root \
    $IMG
sleep 10s && docker logs QPod 2>&1|grep token=

```

⚠️ To use `QPod` with NVIDIA GPU machines with `nvidia-docker`, be sure to:

- 👉 Use **Docker >= 19.03** and the command `nvidia-smi` works well on host machine
- 👉 Add option (after `--restart=always`) in the `docker run` command to enable GPU access: `--gpus all` (for older version of nvidia-container, use `--runtime nvidia`)  
- 👉 Use `IMG="qpod/qpod:full-cuda"` or other images with cuda support

#### For Windows, run this in [Terminal](https://github.com/microsoft/terminal) or CMD

```cmd
SET IMG="qpod/qpod:full"
SET WORKDIR="D:/work"

docker run -d --restart=always ^
    --name=QPod ^
    --hostname=QPod ^
    -p 8888:8888 9999:9999 ^
    -v %WORKDIR%:/root ^
    %IMG%
timeout 10 && docker logs QPod 2>&1|findstr token=

```

Docker on Windows doesn't support GPU yet (cuda WSL support is coming soon).

### 3. Sit back for minutes and get the first-time login token

The commands in the last step will:

- trigger a docker image download process which may take minutes
- start a docker container named `QPod`
- print a string contains a URL, which includes a 48-digit hexadecimal number

Copy the printed hexadecimal string *after* `?token=` as the first-time login token.

### Go! 🎉

Access `http://localhost:8888` (or `http://ip-address:8888`) in your browser and paste the token you just copied to start the journey.

## Additional Information

### FAQ

For a list of FAQ or other information, please refer to the [wiki page](https://github.com/QPod/docker-images/wiki) of this repo.

### Hardware

The images are built based on `ubuntu:latest` and only tested on the `x86` platform.
Minor modifications are expected to port to `arm64`, `ppc64le` platform.

### Package Management

Although `conda` is installed, we do not recommend to use conda to install a lib/package, because:

- `conda` does not reuse the existing system library yet if a system lib is already installed, `conda` installs it again.
- `conda` does not provide a stable Linux system library repository yet, for example, some lib works well on `debian:jessie` but fail on `debian:stretch`.

### Customization

These images are highly customizable. If you find a system lib / Python module / R packages is missing,
you can easily add one in the `install_XX.list` in the `work` folder.

## `QPod` feature matrix

<details>
  <summary>Click here for the models supported!</summary>

|      Image Tag (Feature Spectrum)      | Image Information                                                                                                                                                                                                                                                  | Based On            | Description                                                                                                                                                                                                                           |
|:--------------------------:|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `base`                     | [![base](https://images.microbadger.com/badges/image/qpod/qpod:base.svg)](https://microbadger.com/images/qpod/qpod:base)                                                                                                                                               | `ubuntu:latest`     | This is a base image (not for final use). The image add some basic OS libs and Python3 (conda) environment.                                                                                                                           |
| `jupyter-mini`             | [![jupyter-mini](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-mini.svg)](https://microbadger.com/images/qpod/qpod:jupyter-mini)                                                                                                                               | `base`              | A minimal run-able Jupyter environment. (no NodeJS, no extension, no latex)                                                                                                                                                           |
| `jupyter-std`              | [![jupyter-std](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-std.svg)](https://microbadger.com/images/qpod/qpod:jupyter-std)                                                                                                                                 | `base`              | Standard basic Jupyter environment with NodeJS and Jupyter extensions.                                                                                                                                                                |
| `jupyter-full`             | [![jupyter-full](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-full.svg)](https://microbadger.com/images/qpod/qpod:jupyter-full)                                                                                                                               | `base`              | Full Jupyter environment with NodeJS, LaTex, Jupyter extensions.                                                                                                                                                                      |
| `py-std`                   | [![py-std](https://images.microbadger.com/badges/image/qpod/qpod:py-std.svg)](https://microbadger.com/images/qpod/qpod:py-std)                                                                                                                                           | `jupyter-std`       | `jupyter-std` plus python packages for data science and AI packages. (CPU version of tensorflow installed, no LaTex)                                                                                                                                                                |
| `py-jdk`                   | [![py-jdk](https://images.microbadger.com/badges/image/qpod/qpod:py-jdk.svg)](https://microbadger.com/images/qpod/qpod:py-jdk)                                                                                                                                           | `jupyter-std`       | `py-std` plus OpenJDK. (no LaTex)                                                                                                                                                                                                     |
| `r-mini`                   | [![r-mini](https://images.microbadger.com/badges/image/qpod/qpod:r-mini.svg)](https://microbadger.com/images/qpod/qpod:r-mini)                                                                                                                                           | `jupyter-mini`      | A minimal Jupyter environment for R. (no OpenJDK, no R data science packages, no LaTex, no Jupyter extensions)                                                                                                                        |
| `r-std`                    | [![r-std](https://images.microbadger.com/badges/image/qpod/qpod:r-std.svg)](https://microbadger.com/images/qpod/qpod:r-std)                                                                                                                                             | `jupyter-std`       | Standard Jupyter environment for R data science, including popular R data science packages. (OpenJDK included since many R packages need Java, no LaTex, no Jupyter extensions)                                                       |
| `r-latex`                  | [![r-latex](https://images.microbadger.com/badges/image/qpod/qpod:r-latex.svg)](https://microbadger.com/images/qpod/qpod:r-latex)                                                                                                                                         | `jupyter-full`      | `r-std` plus LaTex and Jupyter extensions. This is the full R environment if you do not need RStudio.                                                                                                                                 |
| `r-studio`                 | [![r-studio](https://images.microbadger.com/badges/image/qpod/qpod:r-studio.svg)](https://microbadger.com/images/qpod/qpod:r-studio)                                                                                                                                       | `jupyter-full`      |  This is the full R environment if you want to use RStudio. `r-latex` plus RStudio.                                                                                                                                                   |
| `go`                       | [![go](https://images.microbadger.com/badges/image/qpod/qpod:go.svg)](https://microbadger.com/images/qpod/qpod:go)                     | `jupyter-std`      | Image with Jupyter environment and golang installed.
| `julia`                    | [![julia](https://images.microbadger.com/badges/image/qpod/qpod:julia.svg)](https://microbadger.com/images/qpod/qpod:julia)                  | `jupyter-std`      | Image with Jupyter environment and julia installed.
| `octave`                   | [![octave](https://images.microbadger.com/badges/image/qpod/qpod:octave.svg)](https://microbadger.com/images/qpod/qpod:octave)                 | `jupyter-full`     | Image with Jupyter environment and Octave and LaTex installed.
| `full`, `latest`           | [![full](https://images.microbadger.com/badges/image/qpod/qpod:full.svg)](https://microbadger.com/images/qpod/qpod:full)  [![latest](https://images.microbadger.com/badges/image/qpod/qpod.svg)](https://microbadger.com/images/qpod/qpod)                                   | `jupyter-full`      | All features and packages (Pythoncuda, R, RStudio, OpenJDK, NodeJS, Go, Julia, LaTex, Jupyter extensions) for CPU included in this image. |
|             **👆The above Images do NOT have NVIDIA cuda/cudnn features installed.**   | | | **👇The Following Images have NVIDA cuda/cudnn features installed. Work for Linux only.** |
| `cuda`, `base-cuda_10.2`           | [![cuda](https://images.microbadger.com/badges/image/qpod/qpod:cuda.svg)](https://microbadger.com/images/qpod/qpod:cuda) [![base-cuda_10.1](https://images.microbadger.com/badges/image/qpod/qpod:base-cuda_10.1.svg)](https://microbadger.com/images/qpod/qpod:base-cuda_10.1)                                                                                                                             | `base`              | This image add version 10.2 of NVIDIA cuda and cudnn libs, including runtime and devel. We use this version by default because packages like pytorch hosted on `pypi` is build against `cuda 10.2`. |
| `jupyter-mini-cuda`        | [![jupyter-mini-cuda](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-mini-cuda.svg)](https://microbadger.com/images/qpod/qpod:jupyter-mini-cuda)                                                                                                                     |  `cuda`             | A minimal Jupyter environment with NVIDIA cuda installed. No popular data science or AI Python installed. This might not be very useful, unless you just want to test Jupyter and cuda.                                               |
| `jupyter-full-cuda`        | [![jupyter-full-cuda](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-full-cuda.svg)](https://microbadger.com/images/qpod/qpod:jupyter-full-cuda)                                                                                                                     | `cuda`              | `jupyter-mini-cuda` plus NodeJS, LaTex, and Jupyter extensions. Might not be very useful as above but will server as base of other images.                                                                                            |
| `py-cuda`                  | [![py-cuda](https://images.microbadger.com/badges/image/qpod/qpod:py-cuda.svg)](https://microbadger.com/images/qpod/qpod:py-cuda)                                                                                                                                         | `jupyter-full-cuda` | This is the recommended image for Python based Deep Learning environment, which includes popular Python data science and AI packages. (`tensorflow` already included, use pip to install `pytorch` easily)                                     |
| `full-cuda`, `latest-cuda` | [![full-cuda](https://images.microbadger.com/badges/image/qpod/qpod:full-cuda.svg)](https://microbadger.com/images/qpod/qpod:full-cuda)  [![latest-cuda](https://images.microbadger.com/badges/image/qpod/qpod:latest-cuda.svg)](https://microbadger.com/images/qpod/qpod:latest-cuda) | `jupyter-full-cuda` | This cuda-enabled image including full features: Python, R (and RStudio), OpenJDK, NodeJS, Go, Julia, LaTex, Jupyter extensions.

</details>

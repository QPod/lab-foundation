# QPod - Docker Image Stack

[![License](https://img.shields.io/badge/License-BSD%203--Clause-green.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Docker Pulls](https://img.shields.io/docker/pulls/qpod/qpod.svg)](https://hub.docker.com/r/qpod/qpod)
[![Docker Starts](https://img.shields.io/docker/stars/qpod/qpod.svg)](https://hub.docker.com/r/qpod/qpod)
[![GitLab Pipeline Status](https://img.shields.io/gitlab/pipeline/QPod/docker-images.svg)](https://gitlab.com/QPod/docker-images/pipelines)
[![TravisCI Pipeline Status](https://img.shields.io/travis/com/QPod/docker-images.svg)](https://travis-ci.com/QPod/docker-images)
[![Join the Gitter Chat](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/QPod/)
[![GitHub Starts](https://img.shields.io/github/stars/QPod/docker-images.svg?label=Stars&style=social)](https://github.com/QPod/docker-images/stargazers)
[![Beerpay](https://img.shields.io/beerpay/QPod/QPod.svg?style=social)](https://beerpay.io/QPod/QPod)


In a nutshell, `QPod` ( [DockerHub](https://hub.docker.com/r/qpod/qpod/) | [GitHub](https://github.com/QPod/docker-images) ) is **an out-of-box Data Science / AI environment and platform at your fingertip which you would love 🤞.**

With Docker and `QPod`, you
 - 📦📦📦 can start your data science / AI work with nearly `zero configuration` - QPod puts everything about installing (latest) packages and configuring environment into standard docker images and set you free from tedious setup and configuration work.
 - 🌍🌎🌏 will find your work more `easy-to-reproduce` - QPod standard images make scientific research or data analysis project as reproducible pipelines and help you share your work with other people easily.
 - 🆙🆙🆙 can easily `scale-up and scale-out` your algorithms and key innovations - QPod help you move forward smoothly from the development stage to deployment stage by re-using these images to either to provide RESTful APIs or orchestrate map/reduce operations on big data.

![Screenshot of QPod](https://i.imgur.com/eeMLbz3.gif "Screenshot of QPod")

## What's actually there?

`QPod` curates and maintains a series of Docker images including interactive computing environment to run a Jupyter Notebook (or JupyterLab) with Python, R, OpenJDK, NodeJS, etc. Other IDE-like tools (e.g R-Studio) are also included.

`QPod` supports many use cases:
 - (Stand-alone) Use it on your laptop as default data science / develop environment.
 - (Multi-tenant) Use it on a server/cluster to host multiple users to exploit hardware resources like GPU.
 - (Deployment/Production) Use it as the base image to host RESTful APIs or work as executors or map/reduce operations.

## How to use? `1-2-3-GO`🎉

### 0. Have docker installed on your laptop/server - Linux (Ubuntu LTS is a good choice) / Windows (>=10 recommended) / macOS
 - If you are NOT using NVIDIA GPU, install `docker-ce` ( community version & free: [macOS](https://download.docker.com/mac/stable/Docker.dmg) | [Windows](https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe)  | [Linux](https://hub.docker.com/search/?offering=community&type=edition&operating_system=linux) ) or `docker-ee` ( [enterprise version](https://hub.docker.com/search/?offering=enterprise&type=edition) & paid) on your laptop/server.
 - If you want to use NVIDIA GPU with `QPod`, Linux server is **required**. After installing `docker`, please refer to [`nvidia-docker`](https://github.com/NVIDIA/nvidia-docker#quickstart) to install the latest version of NVIDIA support for docker.

### 1. Choose the features and choose a folder on your disk
See the table at bottom of this page (`QPod` feature matrix) and choose an Image Tag, say `full`.
Typically, if you have enough disk size and no worry about your network speed, you can choose `full` for your laptop or `full-cuda` for a Linux server with NVIDIA GPU.

Choose a folder (directory) on your laptop/server to server as the base directory (e.g.: `/root` or `D:/work`, please use an absolute path instead of a relative path).
Files in this folder are visible in the environment (and files outside this folder are not visible in the environment).

### 2. Start the container

For Linux/macOS, run command below in shell (change `full` and `/root` to your choices).
```
IMG="qpod/qpod:full"
WORKDIR="/root"
docker pull $IMG && docker tag $IMG qpod && docker rmi $IMG && docker images | grep qpod
docker run -d \
    --name=QPod \
    --hostname=QPod \
    -p 8888:8888 \
    -v $WORKDIR:/root \
    qpod
sleep 5s && docker logs QPod 2>&1|grep token=

```

For Windows, run the command below in CMD (change `full` and `D:/work` to your choices):
```
SET IMG="qpod/qpod:full"
SET WORKDIR="D:/work"
docker pull %IMG% && docker tag %IMG% qpod && docker rmi %IMG% && docker images | findstr qpod
docker run -d ^
    --name=QPod ^
    --hostname=QPod ^
    -p 8888:8888 ^
    -v %WORKDIR%:/root ^
    qpod
timeout 5 && docker logs QPod 2>&1|findstr token=

```

 ⚠️ **If you are using `QPod` with NVIDIA GPU macines with `nvidia-docker`, please add option `--runtime=nvidia` in the `docker run` command to enable GPU access.**

### 3. Sit back for minutes and get the first-time login token
The commands in the last step will:
 - trigger a docker image download process which may take minutes
 - start a docker container named `QPod`
 - print a string contains a URL, which includes a 48-digit hexadecimal number

Please copy the printed hexadecimal *after* `?token=` as the first-time login token.

### Go! 🎉
Access `http://localhost:8888/` (or `http://ip-address:8888` if you use a server) in your browser and input the token you just copied to start the journey.

## Additional Information

### Hardware

The images are built based on `ubuntu:latest` and only tested on the `x86` platform.
Minor modifications are expected to port to `ppc64le` platform.

### Package Management

Although `conda` is installed, we do not recommend to use conda to install a lib/package, because:

- `conda` does not reuse the existing system library yet if a system lib is already installed, `conda` installs it again.
- `conda` does not provide a stable Linux system library repository yet, for example, some lib works well on `debian:jessie` but fail on `debian:stretch`.

### Customization

These images are highly customizable. If you find a system lib / Python module / R packages is missing,
you can easily add one in the `install_XX.list` in the `work` folder.



# `QPod` feature matrix

|      Image Tag (Feature Spectrum)      | Image Information                                                                                                                                                                                                                                                  | Based On            | Description                                                                                                                                                                                                                           |
|:--------------------------:|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `base`                     | [![](https://images.microbadger.com/badges/image/qpod/qpod:base.svg)](https://microbadger.com/images/qpod/qpod:base)                                                                                                                                               | `ubuntu:latest`     | This is a base image (not for final use). The image add some basic OS libs and Python3 (conda) environment.                                                                                                                           |
| `jupyter-mini`             | [![](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-mini.svg)](https://microbadger.com/images/qpod/qpod:jupyter-mini)                                                                                                                               | `base`              | A minimal run-able Jupyter environment. (no NodeJS, no extension, no latex)                                                                                                                                                           |
| `jupyter-std`              | [![](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-std.svg)](https://microbadger.com/images/qpod/qpod:jupyter-std)                                                                                                                                 | `base`              | Standard basic Jupyter environment with NodeJS and Jupyter extensions.                                                                                                                                                                |
| `jupyter-full`             | [![](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-full.svg)](https://microbadger.com/images/qpod/qpod:jupyter-full)                                                                                                                               | `base`              | Full Jupyter environment with NodeJS, LaTex, Jupyter extensions.                                                                                                                                                                      |
| `py-std`                   | [![](https://images.microbadger.com/badges/image/qpod/qpod:py-std.svg)](https://microbadger.com/images/qpod/qpod:py-std)                                                                                                                                           | `jupyter-std`       | `jupyter-std` plus python packages for data science and AI packages. (CPU version of tensorflow installed, no LaTex)                                                                                                                                                                |
| `py-jdk`                   | [![](https://images.microbadger.com/badges/image/qpod/qpod:py-jdk.svg)](https://microbadger.com/images/qpod/qpod:py-jdk)                                                                                                                                           | `jupyter-std`       | `py-std` plus OpenJDK. (no LaTex)                                                                                                                                                                                                     |
| `r-mini`                   | [![](https://images.microbadger.com/badges/image/qpod/qpod:r-mini.svg)](https://microbadger.com/images/qpod/qpod:r-mini)                                                                                                                                           | `jupyter-mini`      | A minimal Jupyter environment for R. (no OpenJDK, no R data science packages, no LaTex, no Jupyter extensions)                                                                                                                        |
| `r-std`                    | [![](https://images.microbadger.com/badges/image/qpod/qpod:r-std.svg)](https://microbadger.com/images/qpod/qpod:r-std)                                                                                                                                             | `jupyter-std`       | Standard Jupyter environment for R data science, including popular R data science packages. (OpenJDK included since many R packages need Java, no LaTex, no Jupyter extensions)                                                       |
| `r-latex`                  | [![](https://images.microbadger.com/badges/image/qpod/qpod:r-latex.svg)](https://microbadger.com/images/qpod/qpod:r-latex)                                                                                                                                         | `jupyter-full`      | `r-std` plus LaTex and Jupyter extensions. This is the full R environment if you do not need RStudio.                                                                                                                                 |
| `r-studio`                 | [![](https://images.microbadger.com/badges/image/qpod/qpod:r-studio.svg)](https://microbadger.com/images/qpod/qpod:r-studio)                                                                                                                                       | `jupyter-full`      |  This is the full R environment if you want to use RStudio. `r-latex` plus RStudio.                                                                                                                                                   |
| `go`                       | [![](https://images.microbadger.com/badges/image/qpod/qpod:go.svg)](https://microbadger.com/images/qpod/qpod:go)                     | `jupyter-std`      | Image with Jupyter environment and golang installed.
| `julia`                    | [![](https://images.microbadger.com/badges/image/qpod/qpod:julia.svg)](https://microbadger.com/images/qpod/qpod:julia)                  | `jupyter-std`      | Image with Jupyter environment and julia installed.
| `octave`                   | [![](https://images.microbadger.com/badges/image/qpod/qpod:octave.svg)](https://microbadger.com/images/qpod/qpod:octave)                 | `jupyter-full`     | Image with Jupyter environment and Octave and LaTex installed.
| `full`, `latest`           | [![](https://images.microbadger.com/badges/image/qpod/qpod:full.svg)](https://microbadger.com/images/qpod/qpod:full)  [![](https://images.microbadger.com/badges/image/qpod/qpod.svg)](https://microbadger.com/images/qpod/qpod)                                   | `jupyter-full`      | All features and packages (Python, R, RStudio, OpenJDK, NodeJS, Go, Julia, Octave, LaTex, Jupyter extensions) for CPU included in this image. |
|             **👆The above Images do NOT have NVIDIA cuda/cudnn features installed.**   | | | **👇The Following Images have NVIDA cuda/cudnn features installed. Work for Linux only.** |             
| `cuda`, `base-cuda_10.0`    | [![](https://images.microbadger.com/badges/image/qpod/qpod:cuda.svg)](https://microbadger.com/images/qpod/qpod:cuda) [![](https://images.microbadger.com/badges/image/qpod/qpod:base-cuda_9.0.svg)](https://microbadger.com/images/qpod/qpod:base-cuda_10.0)                                                                                                                                   | `base`              | This image add version 10.0 of NVIDIA cuda and cudnn libs, including runtime and devel. We use the 10.0 version as default cuda version because popular Deep Learning packages hosted on `pypi` is build against `cuda 10.0`.            |
| `base-cuda_10.1`           | [![](https://images.microbadger.com/badges/image/qpod/qpod:base-cuda_10.1.svg)](https://microbadger.com/images/qpod/qpod:base-cuda_10.1)                                                                                                                             | `base`              | This image add version 10.1 (latest) of NVIDIA cuda and cudnn libs, including runtime and devel. It is now not used because popular Deep Learning packages hosted on ` pypi` is build against ` cuda 10.0` and not compatible with 10.1. |
| `jupyter-mini-cuda`        | [![](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-mini-cuda.svg)](https://microbadger.com/images/qpod/qpod:jupyter-mini-cuda)                                                                                                                     |  `cuda`             | A minimal Jupyter environment with NVIDIA cuda installed. No popular data science or AI Python installed. This might not be very useful, unless you just want to test Jupyter and cuda.                                               |
| `jupyter-full-cuda`        | [![](https://images.microbadger.com/badges/image/qpod/qpod:jupyter-full-cuda.svg)](https://microbadger.com/images/qpod/qpod:jupyter-full-cuda)                                                                                                                     | `cuda`              | `jupyter-mini-cuda` plus NodeJS, LaTex, and Jupyter extensions. Might not be very useful as above but will server as base of other images.                                                                                            |
| `py-cuda`                  | [![](https://images.microbadger.com/badges/image/qpod/qpod:py-cuda.svg)](https://microbadger.com/images/qpod/qpod:py-cuda)                                                                                                                                         | `jupyter-full-cuda` | This is the recommended image for Python based Deep Learning environment, which includes popular Python data science and AI packages. (We use `tensorflow` stack instead of `pytorch` or others.)                                     |
| `full-cuda`, `latest-cuda` | [![](https://images.microbadger.com/badges/image/qpod/qpod:full-cuda.svg)](https://microbadger.com/images/qpod/qpod:full-cuda)  [![](https://images.microbadger.com/badges/image/qpod/qpod:latest-cuda.svg)](https://microbadger.com/images/qpod/qpod:latest-cuda) | `jupyter-full-cuda` | This cuda-enabled image including full features: Python, R (and RStudio), OpenJDK, NodeJS, Go, Julia, Octave, LaTex, Jupyter extensions.

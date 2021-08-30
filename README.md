# QPod - Docker Image Stack

[![License](https://img.shields.io/badge/License-BSD%203--Clause-green.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/QPod/docker-images/qpod-docker-images)](https://github.com/QPod/docker-images/actions/workflows/docker.yml)
[![Join the Gitter Chat](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/QPod/)
[![Docker Pulls](https://img.shields.io/docker/pulls/qpod/qpod.svg)](https://hub.docker.com/r/qpod/qpod)
[![Docker Starts](https://img.shields.io/docker/stars/qpod/qpod.svg)](https://hub.docker.com/r/qpod/qpod)
[![Recent Code Update](https://img.shields.io/github/last-commit/QPod/docker-images.svg)](https://github.com/QPod/docker-images/stargazers)

Please generously STAR★ our project or donate to us!  [![GitHub Starts](https://img.shields.io/github/stars/QPod/docker-images.svg?label=Stars&style=social)](https://github.com/QPod/docker-images/stargazers)
[![Donate-PayPal](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://paypal.me/haobibo)
[![Donate-AliPay](https://img.shields.io/badge/Donate-Alipay-blue.svg)](https://raw.githubusercontent.com/wiki/haobibo/resources/img/Donate-AliPay.png)
[![Donate-WeChat](https://img.shields.io/badge/Donate-WeChat-green.svg)](https://raw.githubusercontent.com/wiki/haobibo/resources/img/Donate-WeChat.png)

[Wiki & Document](https://github.com/QPod/docker-images/wiki) | [中文使用指引(含中国地区镜像)](https://github.com/QPod/docker-images/wiki/QPod%E4%B8%AD%E6%96%87%E6%8C%87%E5%BC%95)

## Your Swiss Army Knife for AI & Data Science

In a nutshell, `QPod` ( [DockerHub](https://hub.docker.com/r/qpod/qpod/) | [GitHub](https://github.com/QPod/docker-images) ) is an **out-of-box Data Science / AI environment and platform** at your fingertip which you would love 💕.

AI/数据科学的瑞士军刀——QPod提供了一站式、开箱即用、可自由定制的，基于容器的、开源AI/数据科学开发、分析工具。

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

- Install **Docker >= 19.03**: `docker-ce` ( community version & free: [Linux](https://hub.docker.com/search/?offering=community&type=edition&operating_system=linux) | [macOS](https://hub.docker.com/editions/community/docker-ce-desktop-mac) | [Windows](https://desktop.docker.com/win/stable/amd64/Docker%20Desktop%20Installer.exe)   ) on your laptop/server. **Docker installed from default Ubuntu/CentOS repository probably won't work for GPU!**
- If you want to use *NVIDIA GPUs* with `QPod`, Linux server or latest Windows WSL2 is **required**. After installing **Docker >= 19.03**, also install both the [`NVIDIA driver`](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver) and the latest version of [`nvidia-container-toolkit`](https://github.com/NVIDIA/nvidia-docker#quickstart) to use the GPUs in containers.

### 1. Choose the features and choose a folder on your disk

- Choose a folder on your laptop/server to server as the base directory (e.g.: `/root`, `/User/me`, or `D:/work`). Use an absolute path instead of relative path -- files in this folder are visible in the environment (files outside this folder are not).

- Choose an tag from the table below (e.g `full` for your laptop, or `full-cuda` for a Linux server with NVIDIA GPU), depends on what features/moduels do you want.
Typically, you can choose `full` / `full-cuda` if you have enough disk space and no worry about your network speed.


<details>
  <summary> 👉 Click here to see a list of Docker Images run on CPUs only</summary>

| Image Name (Feature Spectrum) |             DockerHub Link             |  Based On |                                                                                                                                                Description                                                                                                                                               |
|:-----------------------------:|:--------------------------------------:|:---------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|              atom             | https://hub.docker.com/r/qpod/atom     | ubuntu    | (Not for final usage, add basic utilities based on `ubuntu`.)                                                                                                                                                                                                                                            |
|              base             | https://hub.docker.com/r/qpod/base     | qpod/atom | The image add some basic OS libs and Python3.8 (conda), as well as tini.                                                                                                                                                                                                                                 |
|            py-data            | https://hub.docker.com/r/qpod/py-data  | qpod/base | Python environment customized for Data Science tasks.                                                                                                                                                                                                                                                    |
|             py-nlp            | https://hub.docker.com/r/qpod/py-nlp   | qpod/base | Python environment customized for NLP tasks.                                                                                                                                                                                                                                                             |
|             py-cv             | https://hub.docker.com/r/qpod/py-cv    | qpod/base | Python environment customized for Computer Vision tasks.                                                                                                                                                                                                                                                 |
|             py-bio            | https://hub.docker.com/r/qpod/py-bio   | qpod/base | Python environment customized for Bioinfo tasks.                                                                                                                                                                                                                                                         |
|            py-chem            | https://hub.docker.com/r/qpod/py-chem  | qpod/base | Python environment customized for Computational Chemistry tasks.                                                                                                                                                                                                                                         |
|             py-std            | https://hub.docker.com/r/qpod/py-std   | qpod/base | Python environment including all the packages mentioned above installed.                                                                                                                                                                                                                                 |
|             py-jdk            | https://hub.docker.com/r/qpod/py-jdk   | qpod/base | `py-std` plus OpenJDK. (no LaTex)                                                                                                                                                                                                                                                                        |
|             r-mini            | https://hub.docker.com/r/qpod/r-mini   | qpod/base | Minimal R environment -- no JDK, no R data science packages, no LaTex.                                                                                                                                                                                                                                   |
|             r                 | https://hub.docker.com/r/qpod/r       | qpod/base | Standard R environment for data science -- including popular R data science packages. (OpenJDK included since many R packages need Java, no LaTex.)                                                                                                                                                      |
|            r-latex            | https://hub.docker.com/r/qpod/r-latex  | qpod/base | `r-std` + LaTex -- this is the full R environment if you do not need RStudio.                                                                                                                                                                                                                            |
|            r-studio           | https://hub.docker.com/r/qpod/r-studio | qpod/base | Full R environment if you want to use RStudio. `r-latex` + RStudio + RShiny.                                                                                                                                                                                                                             |
|              node             | https://hub.docker.com/r/qpod/node     | qpod/base | Minimal NodeJS environment (including npm and yarn).                                                                                                                                                                                                                                                     |
|              jdk              | https://hub.docker.com/r/qpod/jdk      | qpod/base | Minimal Java environment (OpenJDK)                                                                                                                                                                                                                                                                       |
|               go              | https://hub.docker.com/r/qpod/go       | qpod/base | Minimal Golang environment.                                                                                                                                                                                                                                                                              |
|             julia             | https://hub.docker.com/r/qpod/julia    | qpod/base | Minimal Julia environment.                                                                                                                                                                                                                                                                               |
|             octave            | https://hub.docker.com/r/qpod/octave   | qpod/base | Minimal Octave environment + LaTex.                                                                                                                                                                                                                                                                      |
|              core             | https://hub.docker.com/r/qpod/core     | qpod/base | ➕ Full Python environment (data + nlp + cv + bio + chem + tensorflow + pytorch)<br/> ➕ Full R environment (datascience + RStudio + RShiny) + LaTex <br/> ➕ Base NodeJS environment <br/> ➕ Base Java environment (OpenJDK + maven) <br/> ➕ Minimal Golang environment <br/> ➕ Minimal Julia environment <br/> ➕ Minimal Octave environment |
|         core-dev, full        | https://hub.docker.com/r/qpod/core-dev | qpod/core | All features and packages (Python, R, RStudio, OpenJDK, NodeJS, Go, Julia, LaTex) ➕ IDE tools: JupyterLab / Jupyter Notebook, VSCode Server                                                                                                                                                              |

</details>

<details>
  <summary> 👉 Click here to see a list of Docker Images run on GPUs + CPUs</summary>

| Image Name (Feature Spectrum) |              DockerHub Link             |    Based On    |                                                                    Description                                                                    |
|:-----------------------------:|:---------------------------------------:|:--------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------:|
|           cuda_10.0           | https://hub.docker.com/r/qpod/cuda_10.0 | qpod/base      | Version 10.0 of NVIDIA cuda and cudnn libs, including runtime and devel. (Specifically retained for tensorflow 1.1x)                              |
|           cuda_10.1           | https://hub.docker.com/r/qpod/cuda_10.1 | qpod/base      | Version 10.1 of NVIDIA cuda and cudnn libs, including runtime and devel.                                                                          |
|        cuda_10.2, cuda        | https://hub.docker.com/r/qpod/cuda_10.2 | qpod/base      | Version 10.2 of NVIDIA cuda and cudnn libs, including runtime and devel.                                                                          |
|           cuda_11.0           | https://hub.docker.com/r/qpod/cuda_11.0 | qpod/base      | Version 11.0 of NVIDIA cuda and cudnn libs, including runtime and devel. (Not used by downstream images -- to catch up with latest cuda version.) |
|       py-cuda-10.0, tf1       | https://hub.docker.com/r/qpod/tf1       | qpod/cuda_10.0 | Tensorflow 1.1x environment with GPU (cuda 10.0).                                                                                                 |
|       py-cuda-10.1, tf2       | https://hub.docker.com/r/qpod/tf2       | qpod/cuda_10.1 | Tensorflow 2.x environment with GPU (cuda 10.1).                                                                                                  |
|      py-cuda-10.2, torch      | https://hub.docker.com/r/qpod/torch     | qpod/cuda_10.2 | Pytorch 1.x environment with GPU (cuda 10.2).                                                                                                     |
|   full-cuda-10.1, core-cuda   | https://hub.docker.com/r/qpod/core-cuda | qpod/cuda_10.1 | Tensorflow 2.x + Pytorch 1.x environment with GPU (cuda 10.1).                                                                                    |
|      cuda-dev, full-cuda      | https://hub.docker.com/r/qpod/cuda-dev  | qpod/full-cuda-10.1 | `core-cuda` + IDE tools: JupyterLab / Jupyter Notebook + VSCode Server.                                                                           |

</details>

### 2. Start the container

Change the value of `IMG` and `WORKDIR` to your choices in the script below, and run the script. Shutdown Jupyter or other service/program which are using port 8888 or 9999.

#### For Linux/macOS/Windows WSL, run this in bash/terminal

```shell
IMG="qpod/full:latest"
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
- 👉 Use `IMG="qpod/full-cuda"` or other images with cuda support

#### For Windows, run this in [Terminal](https://github.com/microsoft/terminal) or CMD

Docker on Windows doesn't support GPU yet (cuda WSL support is coming soon).

```cmd
SET IMG="qpod/full:latest"
SET WORKDIR="D:/work"

docker run -d --restart=always ^
    --name=QPod ^
    --hostname=QPod ^
    -p 8888:8888 9999:9999 ^
    -v %WORKDIR%:/root ^
    %IMG%
timeout 10 && docker logs QPod 2>&1|findstr token=

```

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

- `conda` repo mirrors are generally not avaliable in restricted enterprise LAN, especially in fincial/medical related companies.
- `conda` does not reuse the existing system library yet if a system lib is already installed -- `conda` installs it again; and `conda` does not provide a stable Linux system library repository yet, for example, some lib works well on `debian:jessie` but fail on `debian:stretch`.

### Customization

These images are highly customizable. If you find a system lib / Python module / R packages is missing, you can easily add one in the `install_XX.list` in the `work` folder. Utilites scripts and functions in `/opt/utils` folder will be helpful for custimize images.

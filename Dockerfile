FROM ubuntu:22.04 AS jupyterlab
WORKDIR /tmp

RUN apt update && \
    apt install -y wget

    # 安装conda
ENV PATH="/opt/conda/bin:${PATH}"
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
        bash miniconda.sh -b -p /opt/conda && \
        conda install python=3.12.9 && \
        conda update conda && \
        conda init bash

# 设置默认镜像源，安装jupyterlab
RUN pip install traitlets jupyterlab  jupyterlab-language-pack-zh-CN \
       matplotlib ipywidgets pygments theme-darcula nvidia-ml-py \
      tornado protobuf markupsafe && \
      python -m pip install --upgrade pip && \
      pip cache purge

ARG USER_NAME=tomgiggs
ARG ROOT=root
ENV SHELL=/bin/bash
ENV PATH="/home/${USER_NAME}/.local/bin:${PATH}"
ENV TZ=Asia/Shanghai

# 普通用户不设置密码，无法切换
RUN useradd -m ${USER_NAME} && \
    usermod --shell /bin/bash ${USER_NAME}

#设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone

# system packages
RUN apt-get update && apt-get install -y gnupg2 ca-certificates

ARG CUDA_VERSION="11.8"

ARG TORCH_VERSION="2.3.1"
ARG TORCH_VISION_VERSION="0.18.1"
ARG TORCH_AUDIO_VERSION="2.3.1"

RUN conda install cudatoolkit=${CUDA_VERSION} -c pytorch -c conda-forge && \
    conda clean -t -y

RUN pip install torch==${TORCH_VERSION} torchvision==${TORCH_VISION_VERSION} torchaudio==${TORCH_AUDIO_VERSION}  && \
    conda clean -t -y

RUN conda init
WORKDIR /home
CMD ["jupyter", "lab","--ServerApp.ip=0.0.0.0","--port=9999", "--allow-root"]


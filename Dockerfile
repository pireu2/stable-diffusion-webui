FROM nvidia/cuda:11.8.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TORCH_CUDA_VERSION=cu118 \
    TORCH_VERSION=2.0.1 \
    WEB_UI_DIR=/app/stable-diffusion-webui \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    wget \
    git \
    python3.10 \
    python3.10-venv \
    libgl1 \
    libglib2.0-0 \
    libcudnn8 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m sduser

RUN mkdir -p /app && chown -R sduser:sduser /app

USER sduser

RUN git clone https://github.com/pireu2/stable-diffusion-webui.git ${WEB_UI_DIR} && \
    cd ${WEB_UI_DIR} && \
    python3.10 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip wheel && \
    pip install torch==${TORCH_VERSION}+${TORCH_CUDA_VERSION} \
    torchvision==0.15.2+${TORCH_CUDA_VERSION} \
    -f https://download.pytorch.org/whl/torch_stable.html

WORKDIR ${WEB_UI_DIR}

RUN mkdir -p ${WEB_UI_DIR}/outputs

ENTRYPOINT ["/bin/bash", "webui.sh", "--listen", "--enable-insecure-extension-access", "--api"]
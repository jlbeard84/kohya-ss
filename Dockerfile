ARG KOHYA_VERSION=v25.2.1

FROM nvidia/cuda:12.8.1-cudnn8-devel-ubuntu24.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3.11 python3.11-venv python3-pip git curl wget ffmpeg libgl1 libsm6 libxext6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/bmaltais/kohya_ss.git \
    --branch ${KOHYA_VERSION} \
    --single-branch kohya_ss

RUN python3.11 -m venv /app/kohya_ss/venv \
    && /app/kohya_ss/venv/bin/pip install --upgrade pip setuptools wheel \
    && /app/kohya_ss/venv/bin/pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128 \
    && /app/kohya_ss/venv/bin/pip install -r /app/kohya_ss/requirements.txt

ENV PATH="/app/kohya_ss/venv/bin:$PATH"

EXPOSE 7860
EXPOSE 6006

CMD ["python3", "/app/kohya_ss/gui.py", "--listen", "0.0.0.0", "--port", "7860"]
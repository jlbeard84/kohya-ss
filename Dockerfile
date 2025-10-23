FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        python3.11 python3.11-venv python3.11-distutils python3.11-dev python3.11-tk \
        python3-pip git curl wget ffmpeg \
        libgl1 libsm6 libxext6 libgoogle-perftools4 build-essential \
        tk-dev libffi-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

WORKDIR /app

RUN git clone https://github.com/bmaltais/kohya_ss.git --recursive --branch v25.2.1 --single-branch kohya_ss

WORKDIR /app/kohya_ss

# Create venv with system site packages
RUN python3.11 -m venv --system-site-packages /app/kohya_ss/venv \
    && /app/kohya_ss/venv/bin/pip install --upgrade pip setuptools wheel \
    && /app/kohya_ss/venv/bin/pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 xformers>=0.0.30 \
    --index-url https://download.pytorch.org/whl/cu128 \
    && /app/kohya_ss/venv/bin/pip install -r requirements_linux.txt \
    && /app/kohya_ss/venv/bin/pip cache purge \
    && find /app/kohya_ss/venv -name "*.pyc" -delete \
    && find /app/kohya_ss/venv -name "__pycache__" -type d -exec rm -rf {} + || true

# Final cleanup (keep tkinter-related packages)
RUN apt-get remove -y build-essential software-properties-common \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /root/.cache

ENV PATH="/app/kohya_ss/venv/bin:$PATH"
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc.so
ENV PYTHONPATH="/app/kohya_ss:$PYTHONPATH"

WORKDIR /app/kohya_ss

EXPOSE 7860
EXPOSE 6006

CMD ["python3", "kohya_gui.py", "--listen", "0.0.0.0", "--server_port", "7860", "--headless"]
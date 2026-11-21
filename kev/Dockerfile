FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    UV_LINK_MODE=copy \
    HF_HOME=/models

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app
RUN git clone --depth 1 https://github.com/jaredpalmer/kev.git . \
    && uv sync --extra serve --python 3.13

EXPOSE 8009
CMD ["uv", "run", "--extra", "serve", "python", "-m", "kev.serve", "--run", "jaredpalmer/kev-0.8b", "--host", "0.0.0.0", "--port", "8009"]
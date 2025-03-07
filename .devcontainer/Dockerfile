FROM ubuntu:latest AS dev

ARG TARGETARCH
ARG UV_VERSION=0.6.2

ENV DEBIAN_FRONTEND=noninteractive

# Install certificates and https transport first
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    curl \
    gnupg

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" | tee /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pipx \
    python3-pip \
    python3.12 \
    less \
    htop \
    linux-tools-common \
    linux-tools-generic \
    micro \
    git \
    openssl \
    ssh \
    terraform \
    unzip \
    jq \
    iputils-ping \
    net-tools

RUN pipx ensurepath && pipx install "uv==$UV_VERSION"

RUN if [ "$TARGETARCH" = "arm64" ]; then \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    else \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    fi && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

RUN terraform -install-autocomplete
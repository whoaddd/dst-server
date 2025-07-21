FROM ubuntu:20.04  

ENV DEBIAN_FRONTEND=noninteractive

# 添加i386架构支持并安装依赖
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    lib32gcc1 \
    lib32stdc++6 \
    libsdl2-2.0-0:i386 \
    libcurl4-gnutls-dev:i386 \
    libssl1.1:i386 \
    screen \
    locales \
    wget \
    ca-certificates && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# 创建用户并设置权限
RUN useradd -m dst && \
    mkdir -p /dst-server && \
    chown -R dst:dst /dst-server

USER dst
WORKDIR /dst-server

COPY --chown=dst:dst start-server.sh .
RUN chmod +x start-server.sh

CMD ["./start-server.sh"]
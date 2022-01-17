# OpenResty Docker image with NGINX + LUA + Debian Bullseye
FROM debian:bullseye

MAINTAINER "Robin Schulz <hello@rschu.me>"

ARG HOST_VOLUME_PATH="/Users/rschulz/www/private-projects/git-repos"
ENV HOST_VOLUME_PATH=${HOST_VOLUME_PATH}

ARG CONTAINER_MOUNT_PATH="/usr/local/src/git-repos"
ENV CONTAINER_MOUNT_PATH=${CONTAINER_MOUNT_PATH}

ARG FSWATCH_GREP_REGEX="(\/Users\/rschulz\/www\/private-projects\/git-repos\/[-\w]+\/.git)\s"
ENV FSWATCH_GREP_REGEX=${FSWATCH_GREP_REGEX}

# Application name
ARG APPLICATION_NAME="dura-docker-starter"
ENV APPLICATION_NAME ${APPLICATION_NAME}

# OpenSSL stuff
ARG OPENSSL_VERSION="3.0.1"

# Git stuff
ARG GIT_DOMAIN="github.com"
ENV GIT_DOMAIN=${GIT_DOMAIN}
ARG GIT_PERSONAL_ACCESS_TOKEN=""
ENV GIT_PERSONAL_ACCESS_TOKEN=${GIT_PERSONAL_ACCESS_TOKEN}
ARG GIT_USERNAME=""
ENV GIT_USERNAME=${GIT_USERNAME}
ARG GIT_USER_EMAIL=""
ENV GIT_USER_EMAIL=${GIT_USER_EMAIL}

# Exit script immediately if any of the commands below fails and returns a non-zero exit status
RUN set -x

RUN DEBIAN_FRONTEND=noninteractive

RUN echo "[Dockerfile] Install packages" \
    && apt-get update \
    && apt-get install -qqy --no-install-recommends \
        build-essential \
        curl \
        gcc \
        git \
        libssl-dev \
        pkg-config \
        make \
        wget \
        htop \
        nodejs \
        npm \
        vim \
        zlib1g-dev \
        supervisor \
        ssh-client \
        fswatch

RUN echo "[Dockerfile] Download and compile OpenSSL v${OPENSSL_VERSION}" \
    && cd /usr/local/src \
    && wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz --no-check-certificate \
    && tar -xf openssl-${OPENSSL_VERSION}.tar.gz \
    && cd openssl-${OPENSSL_VERSION} \
    && ./config \
        --prefix=/usr/local/ssl \
        --openssldir=/usr/local/ssl \
        shared \
        zlib \
    && make \
    && make test \
    && make install

RUN echo "[Dockerfile] Export OpenSSL environment variables" \
    && export OPENSSL_DIR=/usr/lib/ssl \
    && export OPENSSL_CONF=/etc/ssl/openssl.cnf

RUN echo "[Dockerfile] Install Rust" \
    && curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN echo "[Dockerfile] Git clone and install Dura" \
    && cd /usr/local/src \
    && git clone https://github.com/tkellogg/dura.git \
    && cd dura \
    && /root/.cargo/bin/cargo install --path .

RUN echo "[Dockerfile] Copy files to container"
ADD container/supervisor/programs.conf /etc/supervisor/conf.d/programs.conf
ADD container/supervisor/default.conf /etc/supervisor/supervisord.conf
ADD container/scripts/watcher.js /usr/local/watcher.js

RUN echo "[Dockerfile] Create directory: ${CONTAINER_MOUNT_PATH}" \
    && mkdir -p ${CONTAINER_MOUNT_PATH}

#RUN echo "[Dockerfile] Cleaning up"
#RUN apt-get clean \
#    && rm -rf /var/lib/apt/lists/*

RUN echo "[Dockerfile] Copy config files and bash scripts to container"
ADD container/scripts/*.sh /usr/local

RUN echo "[Dockerfile] Make bash scripts executable" \
    && chmod +x /usr/local/*.sh

ENTRYPOINT "/usr/local/entrypoint.sh"

# https://docs.docker.com/engine/reference/builder/#healthcheck
#HEALTHCHECK --interval="5m" --timeout="1m" --retries=10 --start-period=0s CMD /usr/local/healthcheck.sh || exit 1

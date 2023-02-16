# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:edge

ARG UNRAR_VERSION=6.1.7
ARG BUILD_DATE
ARG VERSION
ARG TRANSMISSION_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    build-base && \
  echo "**** install packages ****" && \
  apk add --no-cache --upgrade \
    findutils \
    p7zip \
    python3 gcc linux-headers g++ make git make gettext-dev curl-dev cmake python3 openssl-dev && \
  echo "**** install unrar from source ****" && \
  mkdir /tmp/unrar && \
  curl -o \
    /tmp/unrar.tar.gz -L \
    "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" && \  
  tar xf \
    /tmp/unrar.tar.gz -C \
    /tmp/unrar --strip-components=1 && \
  cd /tmp/unrar && \
  make && \
  install -v -m755 unrar /usr/local/bin && \
  echo "**** install transmission ****" && \
  export GIT_SSL_NO_VERIFY=1 && git clone https://github.com/Shurelol/transmission.git /tmp/transmission \
    && cd /tmp/transmission && mkdir build && cd build \
    && git submodule update --init --recursive \
    && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .. \
    && make && make install \
    && \
    ln -s /usr/local/bin/transmission-daemon /usr/bin/transmission-daemon && \
    ln -s /usr/local/bin/transmission-remote /usr/bin/transmission-remote && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies gcc linux-headers g++ make git make gettext-dev curl-dev cmake python3 openssl-dev && \
  rm -rf \
    /root/.cache \
    /tmp/* \
    /usr/local/bin/transmission-create \
    /usr/local/bin/transmission-edit \
    /usr/local/bin/transmission-show

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091 51413/tcp 51413/udp
VOLUME /config

# docker build . -f mcsema.dockerfile -t mcsema && docker run --rm -ti mcsema /bin/bash
# docker system prune

FROM ubuntu:16.04
LABEL maintainer="Toizi"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install \
    build-essential \
    sudo \
    git \
    python2.7 \
    python-pip \
    wget \
    realpath \
    libtinfo-dev \
    lsb-release \
    cmake \
    gcc-multilib \
    g++-multilib \
    curl \
    zlib1g-dev

RUN useradd -m mcsema && \
    echo mcsema:mcsema | chpasswd && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo 'mcsema  ALL=(root) NOPASSWD: ALL' >> /etc/sudoers

USER mcsema
WORKDIR /home/mcsema

RUN git clone --depth 1 https://github.com/trailofbits/mcsema.git && \
    export REMILL_VERSION=`cat ./mcsema/.remill_commit_id` && \
    git clone https://github.com/trailofbits/remill.git && \
    cd remill && \
    git checkout -b temp ${REMILL_VERSION} && \
    mv ../mcsema tools && \
    ./scripts/build.sh && \
    cd remill-build && \
    sudo make install
RUN sudo chmod o+r /usr/local/lib/python2.7/dist-packages/protobuf*/EGG-INFO/*
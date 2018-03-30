# docker build . -f mcsema.dockerfile -t mcsema
# docker system prune
# docker run --rm -ti --mount type=bind,source=$(echo ~/mcsema/tools/mcsema_disass),target=/home/mcsema/remill/tools/mcsema/tools/mcsema_disass/ --name=mcsema mcsema /bin/bash

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

RUN git clone -b radare2_support https://github.com/toizi/mcsema.git && \
    export REMILL_VERSION=`cat ./mcsema/.remill_commit_id` && \
    git clone https://github.com/trailofbits/remill.git && \
    cd remill && \
    git checkout -b temp ${REMILL_VERSION} && \
    mv ../mcsema tools && \
    ./scripts/build.sh && \
    cd remill-build && \
    sudo make install && \
    sudo chmod o+r /usr/local/lib/python2.7/dist-packages/protobuf*/EGG-INFO/*

RUN git clone https://github.com/radare/radare2.git && \
    sudo radare2/sys/install.sh && \
    sudo apt-get -y install pkg-config swig2.0 valabind && \
    r2pm init && \
    r2pm update && \
    sudo r2pm install lang-python2 && \
    sudo r2pm install r2api-python && \
    sudo r2pm install r2pipe-py && \
    sudo pip install r2pipe
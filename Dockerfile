FROM ubuntu:21.10

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y update && apt-get -y upgrade && \
        apt-get install -y python3 python3-pip python3-lxml \
        qbittorrent-nox tzdata p7zip-full p7zip-rar neofetch \
        aria2 curl pv jq ffmpeg xz-utils locales wget unzip \
        git g++ gcc autoconf automake m4 libtool \
        qt5-qmake qtdeclarative5-dev qtbase5-dev qtchooser \
        make libcurl4-openssl-dev qttools5-dev-tools \
        libcrypto++-dev libsqlite3-dev libc-ares-dev \
        libsodium-dev libnautilus-extension-dev \
        libssl-dev libfreeimage-dev swig
        
# Installing Mega SDK Python Binding
ENV MEGA_SDK_VERSION="3.9.2"
RUN git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION ~/home/sdk \
    && cd ~/home/sdk && rm -rf .git \
    && autoupdate -fIv && ./autogen.sh \
    && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl 

RUN apt-get -y update && apt-get -y upgrade && apt-get -y autoremove && apt-get -y autoclean
        
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

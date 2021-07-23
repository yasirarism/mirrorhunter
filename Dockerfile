FROM ubuntu:20.04

RUN set -ex \
    # setup env
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq -y install software-properties-common \
    && add-apt-repository universe \
    && add-apt-repository multiverse \
    && add-apt-repository ppa:rock-core/qt4 \
    && apt-get -qq update \
    && apt-get -qq -y install --no-install-recommends \
        # important
        python3-pip python3 python3-dev tzdata apt-utils build-essential \
        # build deps
        autoconf automake g++-10 gcc-10 gcc git libtool m4 make swig \
        # mega sdk deps
        libc-ares-dev libqt4-dev qt4-qmake libcrypto++-dev libcurl4-openssl-dev \
        libfreeimage-dev libsodium-dev libsqlite3-dev libssl-dev zlib1g-dev libc6 \
        # mirror bot deps
        unzip p7zip-full mediainfo p7zip-rar aria2 wget curl \
        pv jq ffmpeg locales python3-lxml xz-utils neofetch \
    && apt-get -qq -y autoremove --purge \
    # Installing MegaSDK Python binding
    && MEGA_SDK_VERSION="3.9.2" \
    && git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION ~/home/sdk \
    && cd ~/home/sdk && rm -rf .git \
    && ./autogen.sh && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl \
    && cd ~

# Installing MirrorBot dependencies
RUN curl -sLo /usr/local/bin/extract https://raw.githubusercontent.com/breakdowns/slam-mirrorbot/master/extract \
    && curl -sLo /usr/local/bin/pextract https://raw.githubusercontent.com/breakdowns/slam-mirrorbot/master/pextract \
    && chmod +x /usr/local/bin/extract /usr/local/bin/pextract \
    && wget https://raw.githubusercontent.com/breakdowns/slam-mirrorbot/master/requirements.txt \
    && pip3 install --no-cache-dir -r requirements.txt \
    && rm requirements.txt \
    # Cleanup environment
    && apt-get -qq -y purge autoconf automake g++ gcc libtool m4 make software-properties-common swig \
    && rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/* /var/tmp/* /tmp/* \
    && apt-get -qq -y update && apt-get -qq -y upgrade && apt-get -qq -y autoremove && apt-get -qq -y autoclean

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

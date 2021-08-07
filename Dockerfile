# Docker Base Image
FROM python:3-slim-buster

# Installing Dependencies
RUN apt-get -qq update \
    && apt install -y software-properties-common curl gpg \
    && apt-add-repository non-free \
    # for qBittorrent enchaned
    && echo 'deb http://download.opensuse.org/repositories/home:/nikoneko:/test/Debian_10/ /' | tee /etc/apt/sources.list.d/home:nikoneko:test.list \
    && curl -fsSL https://download.opensuse.org/repositories/home:nikoneko:test/Debian_10/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/home_nikoneko_test.gpg > /dev/null \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        git g++ gcc autoconf automake \
        m4 libtool qt4-qmake make libqt4-dev libcurl4-openssl-dev \
        libcrypto++-dev libsqlite3-dev libc-ares-dev \
        libsodium-dev libnautilus-extension-dev \
        libssl-dev libfreeimage-dev swig \
        unzip p7zip-full p7zip-rar aria2 curl pv jq ffmpeg locales python3-lxml xz-utils neofetch qbittorrent-enhanced ca-certificates \
    && apt-get -qq -t experimental upgrade -y && apt-get -qq -y autoremove --purge \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    # Installing MegaSDK Python binding
    && MEGA_SDK_VERSION="3.9.2" \
    && git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION ~/home/sdk \
    && cd ~/home/sdk && rm -rf .git \
    && ./autogen.sh && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl \
    && cd ~ \
    # Cleanup environment
    && apt-get -qq -y purge --autoremove \
       autoconf gpg automake g++ gcc libtool m4 make software-properties-common swig \
    && apt-get -qq -y clean \
    && rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/* /home/sdk

# Set Environment
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

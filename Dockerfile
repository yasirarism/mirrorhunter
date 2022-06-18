FROM ubuntu:22.04

CMD ["bash"]
WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app
ARG TARGETPLATFORM
ENV PYTHONWARNINGS=ignore
ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 TZ=Asia/Jakarta MEGA_SDK_VERSION=3.12.2
RUN /bin/sh -c bash /run/secrets/rahasia

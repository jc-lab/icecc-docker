FROM ubuntu:20.04 as icecc-builder
MAINTAINER Joseph Lee <joseph@jc-lab.net>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y \
    bash curl wget gnupg2 \
    debhelper build-essential git \
    automake autoconf \
    docbook2x docbook-xml libarchive-dev liblzo2-dev libzstd-dev libcap-ng-dev

RUN mkdir -p /work

COPY [ "icecc_1.3.1.orig.tar.gz", "/tmp/icecc_1.3.1.orig.tar.gz" ]
COPY [ "debian", "/work/src/debian" ]

RUN cd /work/src && \
    tar --strip-components 1 -xf /tmp/icecc_1.3.1.orig.tar.gz

RUN cd /work/src && \
    dpkg-buildpackage --no-sign -b

FROM ubuntu:20.04
MAINTAINER Joseph Lee <joseph@jc-lab.net>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y \
    ca-certificates bash curl netcat \
    build-essential git libarchive13 liblzo2-2 file libcap-ng0

COPY --from=icecc-builder "/work/icecc_1.3.1-1_amd64.deb" "/tmp/icecc_1.3.1-1_amd64.deb"
RUN dpkg -i /tmp/icecc_1.3.1-1_amd64.deb

RUN apt-get autoclean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY [ "start.sh", "/start.sh" ]
RUN chmod +x /start.sh

ENV JOBS=${JOBS:--1}
ENV ICECC_MODE=daemon
ENV ICECC_SCHEDULER_PORT=8765
ENV USE_TMPFS=n
ENV TMPFS_MOUNT_OPTIONS=rw,nosuid,nodev,mode=777

# Available
# ENV USE_SCHEDULER=scheduler_host

# EXPOSE 10245/tcp
# EXPOSE 8765/tcp

CMD [ "/start.sh" ]


FROM debian:12
LABEL org.opencontainers.image.authors="Jonathan Garbee"

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y apt-utils build-essential help2man cmake pkg-config git libcurl4-openssl-dev libboost-regex-dev libjsoncpp-dev \
    librhash-dev libtinyxml2-dev libhtmlcxx-dev libboost-system-dev \
    libboost-filesystem-dev libboost-program-options-dev libboost-date-time-dev \
    libboost-iostreams-dev libssl-dev zlib1g-dev libtidy-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone https://github.com/Sude-/lgogdownloader.git

WORKDIR /tmp/lgogdownloader
RUN mkdir build

WORKDIR /tmp/lgogdownloader/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install

WORKDIR /tmp
RUN rm -rf lgogdownloader && \
    apt-get purge -y build-essential help2man cmake pkg-config git && \
    apt-get autoremove --purge -y && \
    adduser --system --shell /bin/bash --home /home/user --uid 99 --ingroup users user

USER user

RUN echo "umask 0000" > /home/user/.bashrc && \
    mkdir /home/user/downloads

VOLUME ["/home/user/.cache/lgogdownloader", "/home/user/.config/lgogdownloader", "/home/user/downloads"]

USER user
WORKDIR /home/user

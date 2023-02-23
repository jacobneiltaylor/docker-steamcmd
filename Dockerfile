FROM --platform=amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CPU_MHZ=2500

RUN echo steam steam/question select "I AGREE" | debconf-set-selections && echo steam steam/license note '' | debconf-set-selections

RUN apt-get update && apt-get -y --no-install-recommends install software-properties-common && add-apt-repository -y multiverse && dpkg --add-architecture i386 && apt-get update && apt-get -y --no-install-recommends upgrade

RUN apt-get -y --no-install-recommends install \
    unzip \
    supervisor \
    jq \
    apt-transport-https \
    gnupg2 \
    wget \
    python3-pip \
    lsb-release \
    ca-certificates \
    lib32z1 \
    libncurses5:i386 \
    libbz2-1.0:i386 \
    lib32gcc-s1 \
    lib32stdc++6 \
    libtinfo5:i386 \
    libcurl3-gnutls:i386 \
    libsdl2-2.0-0:i386 \
    steamcmd && update-ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.ssh/id_rsa* /var/cache/apt/archives/*.deb && \
    apt-get autoremove --purge && \
    apt-get purge -y --auto-remove \
    -o APT::Install-Recommends=false \
    -o APT::Install-Suggests=false \
    -o APT::AutoRemove::RecommendsImportant=false \
    -o APT::AutoRemove::SuggestsImportant=false && \
    apt-get autoremove -y --purge \
    -o APT::Install-Recommends=false \
    -o APT::Install-Suggests=false \
    -o APT::AutoRemove::RecommendsImportant=false \
    -o APT::AutoRemove::SuggestsImportant=false && \
    apt-get clean

RUN pip3 install --no-cache-dir jinja2-cli

RUN mkdir /opt/steam && useradd -r -d /opt/steam steam  && chown steam:steam /opt/steam

USER steam
WORKDIR /opt/steam

RUN mkdir ./bin && mkdir ./.steam
RUN /usr/games/steamcmd +login anonymous +quit

COPY ./scripts/ bin/

ENV PATH=/opt/steam/bin:/usr/games:$PATH

CMD [ "/bin/bash" ]

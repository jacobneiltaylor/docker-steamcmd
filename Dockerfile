FROM --platform=amd64 jacobneiltaylor/docker-base:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CPU_MHZ=2500

RUN echo steam steam/question select "I AGREE" | debconf-set-selections && echo steam steam/license note '' | debconf-set-selections

RUN apt_pre.sh && apt-get -y --no-install-recommends install software-properties-common && add-apt-repository -y multiverse && dpkg --add-architecture i386 && apt-get update && apt-get -y --no-install-recommends upgrade

RUN apt_pre.sh && \
    apt-get -y --no-install-recommends install software-properties-common && \
    add-apt-repository -y multiverse && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y --no-install-recommends install \
    lib32z1 \
    libncurses5:i386 \
    libbz2-1.0:i386 \
    lib32gcc-s1 \
    lib32stdc++6 \
    libtinfo5:i386 \
    libcurl3-gnutls:i386 \
    libsdl2-2.0-0:i386 \
    steamcmd && update-ca-certificates && apt_post.sh

RUN pip install --no-cache-dir --upgrade pip && pip3 install --no-cache-dir jinja2-cli boto3 requests

RUN mkdir /opt/steam && useradd -r -d /opt/steam steam  && chown steam:steam /opt/steam

USER steam
WORKDIR /opt/steam

RUN mkdir ./bin && mkdir ./.steam
RUN /usr/games/steamcmd +login anonymous +quit

COPY ./scripts/ bin/

ENV PATH=/opt/steam/bin:/usr/games:$PATH

CMD [ "/bin/bash" ]

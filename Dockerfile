FROM ubuntu:latest

#non interactive Shell
ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get install -y \
    steamcmd \
    curl \
    cron \
    bzip2 \
    perl-modules \
    lsof \
    libc6-i386 \
    lib32gcc1 \
    sudo \
    tzdata \
    dnsutils \
    && ln -s /usr/games/steamcmd /usr/local/bin \
    && adduser --gecos "" --disabled-password steam

WORKDIR /home/steam
USER steam

RUN steamcmd +quit

USER root

RUN curl -sL https://git.io/arkmanager | sudo bash -s steam && \
    ln -s /usr/local/bin/arkmanager /usr/bin/arkmanager

COPY arkmanager/arkmanager.cfg /etc/arkmanager/arkmanager.cfg
COPY arkmanager/instance.cfg /etc/arkmanager/instances/main.cfg
COPY run.sh /home/steam/run.sh
COPY log.sh /home/steam/log.sh

RUN mkdir /ark && \
    chown -R steam:steam /home/steam/ /ark \
    && echo "%sudo   ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers && \
    usermod -a -G sudo steam && \
    touch /home/steam/.sudo_as_admin_successful

WORKDIR /home/steam
USER steam

ENV am_ark_SessionName="Ark Server" \
    am_serverMap="TheIsland" \
    am_ark_ServerAdminPassword="k3yb04rdc4t" \
    am_ark_MaxPlayers=70 \
    am_ark_QueryPort=27015 \
    am_ark_Port=7778 \
    am_ark_RCONPort=32330 \
    am_arkwarnminutes=15

# mounted as the directory to contain the server/backup/log/config files
VOLUME /ark
# mounted so that workshop (mod) downloads are persisted
VOLUME /home/steam/Steam

#steam query port
EXPOSE 27015/udp
#gameserver port
EXPOSE 7777-7778/udp

CMD [ "./run.sh" ]

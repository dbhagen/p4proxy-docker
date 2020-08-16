FROM ubuntu:bionic-20200713
ARG P4P_VER=r20.1
ENV DEBIAN_FRONTEND=noninteractive \
    P4P_VER=${P4P_VER} \
    P4P_MAXCACHEAGEDAYS=30 \
    P4P_MAXCACHESIZE=10GB \
    P4USER=p4proxy \
    P4PPORT=localhost:1666 \
    P4TARGET=localhost:1666 \
    P4PFSIZE=0 \
    P4DEBUG=0 \
    P4P_COMPRESS=TRUE \
    P4TRUST=/p4/config/.p4trust \
    P4TICKETS=/p4/config/.p4tickets

COPY startscript.sh /startscript.sh
COPY cache-clean.sh /cache-clean.sh
COPY cache-cron /etc/cron.d/cache-cron
ADD http://www.perforce.com/downloads/perforce/${P4P_VER:-r20.1}/bin.linux26x86_64/helix-core-server.tgz /tmp/helix-core-server.tgz
RUN mkdir -p /p4/bin && \
    mkdir -p /p4/cache && \
    mkdir -p /p4/logs && \
    mkdir -p /p4/ssl && \
    mkdir -p /p4/config && \
    tar -xvzf /tmp/helix-core-server.tgz -C /p4/bin && \
    chown -R root:root /p4/bin/p4* && \
    chmod -R 755 /p4/bin/p4* && \
    rm -rf /tmp/helix-core-server.tgz /tmp/p4p && \
    apt-get update -q -y && \
    apt-get install -qq --force-yes \
    cron \
    bc \
    vim && \
    chmod +x /startscript.sh && \
    chmod 0644 /etc/cron.d/cache-cron && \
    chmod +x /cache-clean.sh && \
    crontab /etc/cron.d/cache-cron

WORKDIR /p4/

VOLUME [ "/p4/cache", "/p4/logs", "/p4/ssl", "/p4/config" ]

EXPOSE 1666/tcp

CMD [ "/startscript.sh" ]
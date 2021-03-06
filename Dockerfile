FROM ubuntu:bionic-20200713
ARG P4P_VER=r20.1

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Helix Perforce P4Proxy Container Image" \
    org.label-schema.description="Docker encapsulated p4proxy instance" \
    org.label-schema.url="https://github.com/dbhagen/p4proxy-docker" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="e.g. https://github.com/microscaling/microscaling" \
    org.label-schema.vendor="Daniel B. Hagen" \
    org.label-schema.version=$P4P_VER \
    org.label-schema.schema-version="1.0"

ENV DEBIAN_FRONTEND=noninteractive \
    P4P_VER=$P4P_VER \
    P4P_MAXCACHEAGEDAYS=30 \
    P4P_MAXCACHESIZE=10GB \
    P4USER=p4proxy \
    P4PPORT=localhost:1666 \
    P4PTARGET=localhost:1666 \
    P4PFSIZE=0 \
    P4DEBUG=0 \
    P4PCOMPRESS=TRUE \
    P4TRUST=/p4/config/.p4trust \
    P4TICKETS=/p4/config/.p4tickets

COPY startscript.sh /startscript.sh
#COPY cache-clean.sh /cache-clean.sh
#COPY cache-cron /etc/cron.d/cache-cron
ADD http://www.perforce.com/downloads/perforce/${P4P_VER:-r20.1}/bin.linux26x86_64/helix-core-server.tgz /tmp/helix-core-server.tgz
# ADD http://www.perforce.com/downloads/perforce/r19.2/bin.linux26x86_64/helix-core-server.tgz /tmp/helix-core-server.tgz
RUN mkdir -p /p4/bin && \
    mkdir -p /p4/cache && \
    mkdir -p /p4/logs && \
    mkdir -p /p4/ssl && \
    mkdir -p /p4/config && \
    tar -xvzf /tmp/helix-core-server.tgz -C /p4/bin && \
    chown -R root:root /p4/bin/p4* && \
    chmod -R 755 /p4/bin/p4* && \
    rm -rf /tmp/helix-core-server.tgz /tmp/p4p && \
    chmod +x /startscript.sh

#    apt-get update -q -y && \
#    apt-get install -qq -y \
#    openssl \
#    cron \
#    bc \
#    ncdu \
#    vim && \
#    chmod +x /cache-clean.sh && \
#    chmod 0644 /etc/cron.d/cache-cron && \
#    crontab /etc/cron.d/cache-cron

WORKDIR /p4/

VOLUME [ "/p4/cache", "/p4/logs", "/p4/ssl", "/p4/config" ]

EXPOSE 1666/tcp

CMD [ "/startscript.sh" ]
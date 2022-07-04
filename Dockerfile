FROM alpine
LABEL maintainer="Nick Lucas <nlucas@ieee.org>"

ENV NEXTDNS_VERSION=1.37.11 \
    NEXTDNS_SHA256=102ea184cb92a8ba79a69de4f5a799daaaa2651539dd65b6fa24918d7edc8828

ENV NEXTDNS_ARGUMENTS="-listen :53 -report-client-info -log-queries"
ENV UID 1000
ENV GID 1000
ENV TIMEZONE UTC

RUN apk update \
  && apk add --no-cache -y curl libcap

RUN mkdir /tmp/nextdns \
    && curl -fsSL https://github.com/nextdns/nextdns/releases/download/v${NEXTDNS_VERSION}/nextdns_${NEXTDNS_VERSION}_linux_arm64.tar.gz -o /tmp/nextdns/nextdns.tar.gz \
    && cd /tmp/nextdns \
    && echo "${NEXTDNS_SHA256} *nextdns.tar.gz" | sha256sum -c - \
    && tar zxf nextdns.tar.gz \
    && addgroup --gid ${GID} nextdns \
    && adduser --system --uid ${UID} --grp nextdns --home /nextdns nextdns \
    && mv ./nextdns /nextdns/nextdns \
    && chown nextdns.nextdns /nextdns/nextdns \
    && setcap 'cap_net_bind_service=+ep' /nextdns/nextdns \
    && cd / \
    && rm -rf /tmp/nextdns \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 53/tcp 53/udp

USER nextdns

ADD ./run.sh /nextdns/run.sh

WORKDIR /nextdns
CMD ["./run.sh"]

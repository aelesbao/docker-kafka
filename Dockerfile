## -*- docker-image-name: "docker-kafka" -*-
#
# Kafka Dockerfile
# https://github.com/aelesbao/docker-kafka
#

FROM java:8-jre-alpine
MAINTAINER Augusto Elesbão <augusto@dharma.ws>

ENV GOSU_VERSION 1.9
RUN set -x \
    && apk add --no-cache --virtual .gosu-deps \
        dpkg \
        gnupg \
        openssl \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apk del .gosu-deps

ENV SCALA_VERSION="2.11" \
    KAFKA_VERSION="0.10.1.0" \
    KAFKA_HOME=/kafka \
    KAFKA_PORT=9092 \
    JMX_PORT=7203

# Install Kafka
RUN set -x \
    && apk add --no-cache --virtual .run-deps \
      bash \
    && apk add --no-cache --virtual .build-deps \
      tar \
      gnupg \
      openssl \
    && export GNUPGHOME="$(mktemp -d)" \
    && export KAFKA_RELEASE_ARCHIVE=kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && wget -O ${KAFKA_RELEASE_ARCHIVE} "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE}" \
    && wget -O ${KAFKA_RELEASE_ARCHIVE}.asc "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE}.asc" \
    && gpg --keyserver hkps.pool.sks-keyservers.net --recv-keys 27A7289E \
    && gpg --batch --verify ${KAFKA_RELEASE_ARCHIVE}.asc ${KAFKA_RELEASE_ARCHIVE} \
    && mkdir -p ${KAFKA_HOME} /data /logs \
    && tar -xzf ${KAFKA_RELEASE_ARCHIVE} -C ${KAFKA_HOME} --strip-components=1 \
    && rm -r "$GNUPGHOME" kafka_* \
    && apk del .build-deps \
    && adduser -D -h ${KAFKA_HOME} kafka kafka \
    && chown -R kafka:kafka ${KAFKA_HOME}

WORKDIR ${KAFKA_HOME}
VOLUME [ "/data", "/logs" ]

EXPOSE ${KAFKA_PORT} ${JMX_PORT}

ENV PATH ${KAFKA_HOME}/bin:${PATH}


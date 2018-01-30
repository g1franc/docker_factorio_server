FROM frolvlad/alpine-glibc:alpine-3.7

MAINTAINER g1franc <guillaume.francois55@gmail.com>

WORKDIR /opt

COPY ./new_smart_launch.sh /opt/
COPY ./factorio.crt /opt/

VOLUME /opt/factorio/saves /opt/factorio/mods

EXPOSE 34197/udp
#EXPOSE 27015/tcp

CMD ["./new_smart_launch.sh"]

ENV FACTORIO_AUTOSAVE_INTERVAL=2 \
    FACTORIO_AUTOSAVE_SLOTS=3 \
    FACTORIO_ALLOW_COMMANDS=false \
    FACTORIO_NO_AUTO_PAUSE=false \
    VERSION=0.16.20 \
    FACTORIO_SHA1=cef6512e48d723556c028448e228f22ae7a68890 \
    FACTORIO_WAITING=false \
    FACTORIO_MODE=normal \
    FACTORIO_SERVER_NAME= \
    FACTORIO_SERVER_DESCRIPTION= \
    FACTORIO_SERVER_MAX_PLAYERS= \
    FACTORIO_SERVER_VISIBILITY= \
    FACTORIO_USER_USERNAME= \
    FACTORIO_USER_PASSWORD= \
#    FACTORIO_USER_TOKEN= \
    FACTORIO_SERVER_GAME_PASSWORD= \
    FACTORIO_SERVER_VERIFY_IDENTITY=

RUN apk -U upgrade && apk --update add bash curl tar gzip xz libssl1.0 && \
    curl -sSL --cacert /opt/factorio.crt "https://www.factorio.com/get-download/${VERSION}/headless/linux64" -o /tmp/factorio_headless_x64_${VERSION}.tar.xz && \
    echo "$FACTORIO_SHA1  /tmp/factorio_headless_x64_${VERSION}.tar.xz" | sha1sum -c && \
    tar xf /tmp/factorio_headless_x64_${VERSION}.tar.xz && \
    rm /tmp/factorio_headless_x64_${VERSION}.tar.xz && \
    apk del curl tar gzip xz

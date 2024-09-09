FROM i386/ubuntu:xenial

RUN apt-get update \
    && apt-get install -y \
    curl \
    unzip \
    make \
    libstdc++6 \
    && curl "http://www.byond.com/download/build/515/515.1642_byond_linux.zip" -o byond.zip \
    && unzip byond.zip \
    && cd byond \
    && sed -i 's|install:|&\n\tmkdir -p $(MAN_DIR)/man6|' Makefile \
    && make install \
    && chmod 644 /usr/local/byond/man/man6/* \
    && apt-get purge -y --auto-remove curl unzip make \
    && cd .. \
    && rm -rf byond byond.zip /var/lib/apt/lists/*

COPY . .
RUN DreamMaker -max_errors 0 roguetown.dme
ENTRYPOINT [ "DreamDaemon", "roguetown.dmb", "-port", "1213", "-trusted", "-close", "-verbose" ]

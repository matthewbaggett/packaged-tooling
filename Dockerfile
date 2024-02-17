# checkov:skip=CKV_DOCKER_2 Healthcheck makes no sense here.
# checkov:skip=CKV_DOCKER_3 user cannot be determined at this stage.
FROM ubuntu:focal AS builder-precursor
ARG PHP_EXTENSIONS=filter,tokenizer,dom,mbstring,phar
WORKDIR /build
# hadolint ignore=DL3008
RUN apt-get -qq update && \
    apt-get -yqq install --no-install-recommends \
      ca-certificates \
      curl \
      wget \
      build-essential \
      git \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH="/build/bin:/build/static-php-cli/bin:${PATH}"

WORKDIR /build/static-php-cli
RUN git clone https://github.com/crazywhalecc/static-php-cli.git && \
    chmod +x bin/setup-runtime && \
    bin/setup-runtime && \
    ls -lh bin
RUN echo $PATH && \
    bin/composer install && \
    chmod +x bin/spc && \
    spc --version

RUN spc doctor --auto-fix && \
    spc download \
        --for-extensions=apcu,bcmath,bz2,calendar,ctype,curl,dba,dom,event,exif,fileinfo,filter,ftp,gd,gmp,iconv,imagick,imap,intl,mbregex,mbstring,mysqli,mysqlnd,opcache,openssl,pcntl,pdo,pdo_mysql,pdo_pgsql,pdo_sqlite,pgsql,phar,posix,protobuf,readline,redis,session,shmop,simplexml,soap,sockets,sodium,sqlite3,swoole,sysvmsg,sysvsem,sysvshm,tokenizer,xml,xmlreader,xmlwriter,xsl,zip,zlib \
        --with-php=8.2
RUN spc build \
        phar,$PHP_EXTENSIONS \
        --build-micro \
        --enable-zts

FROM builder-precursor AS builder-phar
ARG PHAR_DOWNLOAD_URL
ARG OUTPUT_BIN_NAME
WORKDIR /build

RUN wget -q $PHAR_DOWNLOAD_URL -O $OUTPUT_BIN_NAME.phar && \
    chmod +x $OUTPUT_BIN_NAME.phar \
RUN mkdir -p /build/bin && \
    spc \
      micro:combine \
      $OUTPUT_BIN_NAME.phar \
#      -I "memory_limit=512M" \
      --output /build/bin/$OUTPUT_BIN_NAME \
    && \
    chmod +x /build/bin/$OUTPUT_BIN_NAME



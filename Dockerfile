FROM ubuntu:latest AS builder
ARG PHP_EXTENSIONS=filter,tokenizer,dom,mbstring,phar
WORKDIR /build
RUN apt-get update && apt-get install -y \
      curl \
      wget \
      build-essential \
      git

ENV PATH="/build/bin:/build/static-php-cli/bin:${PATH}"

RUN git clone https://github.com/crazywhalecc/static-php-cli.git && \
    cd static-php-cli && \
    chmod +x bin/setup-runtime && \
    bin/setup-runtime && \
    ls -lh bin
RUN cd static-php-cli && \
    echo $PATH && \
    bin/composer install && \
    chmod +x bin/spc && \
    spc --version

RUN spc doctor --auto-fix && \
    spc download \
        --for-extensions=apcu,bcmath,bz2,calendar,ctype,curl,dba,dom,event,exif,fileinfo,filter,ftp,gd,gmp,iconv,imagick,imap,intl,mbregex,mbstring,mysqli,mysqlnd,opcache,openssl,pcntl,pdo,pdo_mysql,pdo_pgsql,pdo_sqlite,pgsql,phar,posix,protobuf,readline,redis,session,shmop,simplexml,soap,sockets,sodium,sqlite3,swoole,sysvmsg,sysvsem,sysvshm,tokenizer,xml,xmlreader,xmlwriter,xsl,zip,zlib \
        --with-php=8.2
RUN spc build \
        $PHP_EXTENSIONS \
        --build-micro \
        --enable-zts


FROM builder as builder-php-cs-fixer
ARG PHAR_DOWNLOAD_URL
ARG OUTPUT_BIN_NAME

RUN wget -q $PHAR_DOWNLOAD_URL -O $PHAR_NAME.phar && \
    chmod +x $OUTPUT_BIN_NAME.phar
RUN mkdir -p /build/bin && \
    spc \
      micro:combine \
      $OUTPUT_BIN_NAME.phar \
#      -I "memory_limit=512M" \
      --output /build/bin/$OUTPUT_BIN_NAME \
    && \
    chmod +x /build/bin/$OUTPUT_BIN_NAME


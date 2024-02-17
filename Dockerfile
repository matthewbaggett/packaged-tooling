FROM ubuntu:latest AS builder
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
        apcu,bcmath,bz2,calendar,ctype,curl,dba,dom,event,exif,fileinfo,filter,ftp,gd,gmp,iconv,imagick,imap,intl,mbregex,mbstring,mysqli,mysqlnd,opcache,openssl,pcntl,pdo,pdo_mysql,pdo_pgsql,pdo_sqlite,pgsql,phar,posix,protobuf,readline,redis,session,shmop,simplexml,soap,sockets,sodium,sqlite3,swoole,sysvmsg,sysvsem,sysvshm,tokenizer,xml,xmlreader,xmlwriter,xsl,zip,zlib \
        --build-micro \
        --enable-zts


FROM builder as builder-php-cs-fixer
RUN wget -qN https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/releases/download/v3.49.0/php-cs-fixer.phar && \
    chmod +x php-cs-fixer.phar && \
    mkdir -p /build/bin && \
   spc micro:combine php-cs-fixer.phar -I "memory_limit=512M" --output /build/bin/php-cs-fixer && \
    chmod +x /build/bin/php-cs-fixer && \
    ls -lah /build/bin && \
    /build/bin/php-cs-fixer --version


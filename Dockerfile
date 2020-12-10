ARG PHP_VERSION=8.0
FROM php:$PHP_VERSION-fpm-alpine

ENV LC_ALL=C

WORKDIR /app

RUN set -x \
    && apk add --no-cache \
        fcgi \
        git \
        nginx \
        s6 \
    && cd "$PHP_INI_DIR" \
    && sed -ri \
        -e 's/^(access.log)/;\1/' \
        ../php-fpm.d/docker.conf \
    && sed -ri \
        -e 's/;(ping\.path)/\1/' \
        ../php-fpm.d/www.conf \
    && ln -s php.ini-production php.ini \
    && sed -ri \
        -e 's/^(expose_php).*$/\1 = Off/' \
        -e 's/^(memory_limit).*$/\1 = 256M/' \
        php.ini \
    && mkdir /run/nginx \
    && sed -ri \
        -e 's/#(tcp_nopush on;)/\1/' \
        /etc/nginx/nginx.conf

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY --from=clevyr/prestissimo /tmp /root/.composer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

COPY rootfs/ /

ENV XDEBUG_MODE="debug"
ENV XDEBUG_CONFIG="client_host=host.docker.internal client_port=9000 start_with_request=trigger"

ONBUILD ARG SKIP_BUILD
ONBUILD ARG DEPS
ONBUILD ARG INSTALL

ONBUILD ARG INSTALL_BCMATH
ONBUILD ARG INSTALL_CALENDAR
ONBUILD ARG INSTALL_EXIF
ONBUILD ARG INSTALL_GD
ONBUILD ARG INSTALL_IMAGICK
ONBUILD ARG INSTALL_INTL
ONBUILD ARG INSTALL_MOSQUITTO
ONBUILD ARG INSTALL_MYSQL
ONBUILD ARG INSTALL_OPCACHE
ONBUILD ARG INSTALL_PGSQL
ONBUILD ARG INSTALL_REDIS
ONBUILD ARG INSTALL_SQLSRV
ONBUILD ARG INSTALL_XDEBUG
ONBUILD ARG INSTALL_ZIP

ONBUILD RUN \
    if [ "$SKIP_BUILD" != "true" ]; then \
        clevyr-build \
    ; fi

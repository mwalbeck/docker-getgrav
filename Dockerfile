FROM php:7.3-fpm-buster

ENV GRAV_VERSION 1.6.16

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        unzip \
        rsync \
    ; \
    rm -rf /var/lib/apt/lists/*;

RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libwebp-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libyaml-dev \
        libzip-dev \
    ; \
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr --with-webp-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" \
        zip \
        gd \
        opcache \
    ; \
    \
    pecl install apcu-5.1.17; \
    pecl install yaml-2.0.4; \
    \
    docker-php-ext-enable \
        apcu \
        yaml \
    ; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    \
    git clone --branch $GRAV_VERSION https://github.com/getgrav/grav.git /usr/share/grav; \
    cd /usr/share/grav; \
    rm -rf \
        .editorconfig \
        .gitignore \
        .travis.yml \
        .git \
        assets \
        backup \
        cache \
        images \
        logs \
        tmp \
        tests \
        webserver-configs \
        user \
    ;

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
FROM php:7.3.25-fpm-buster@sha256:10c80e18a4d81d51d067727dcdb979e92d1af468659c1092f5438dbb4e6b45a2

# renovate: datasource=github-tags depName=getgrav/grav versioning=semver
ENV GRAV_VERSION 1.7.0-rc.19

RUN set -ex; \
    \
    groupadd --system foo; \
    useradd --no-log-init --system --gid foo --create-home foo; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        unzip \
        rsync \
        gosu \
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
    pecl install apcu-5.1.18; \
    pecl install yaml-2.1.0; \
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
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY grav.ini $PHP_INI_DIR/conf.d/

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]

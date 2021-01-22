FROM php:7.3.26-fpm-buster@sha256:cca12409a6b5f035af4e495a25fc2639fc82516d02e25457dbdf8505676ee4b0

SHELL [ "/bin/bash", "-c" ]

# renovate: datasource=github-tags depName=getgrav/grav versioning=semver
ENV GRAV_VERSION 1.6.31
# renovate: datasource=github-tags depName=krakjoe/apcu versioning=semver
ENV PHP_APCU_VERSION v5.1.18
# renovate: datasource=github-tags depName=php/pecl-file_formats-yaml versioning=semver
ENV PHP_YAML_VERSION 2.2.1

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
    pecl install apcu-${PHP_APCU_VERSION:1}; \
    pecl install yaml-$PHP_YAML_VERSION; \
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

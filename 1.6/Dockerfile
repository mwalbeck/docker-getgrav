FROM php:7.3.28-fpm-buster@sha256:e7dd1db79543120565510fe4f01e944b2b6a85352fd80637728652455a63113d

SHELL [ "/bin/bash", "-exo", "pipefail", "-c" ]

# renovate: datasource=github-tags depName=getgrav/grav versioning=semver
ENV GRAV_VERSION 1.6.31
# renovate: datasource=github-tags depName=krakjoe/apcu versioning=semver
ENV PHP_APCU_VERSION v5.1.20
# renovate: datasource=github-tags depName=php/pecl-file_formats-yaml versioning=semver
ENV PHP_YAML_VERSION 2.2.1

RUN groupadd --system foo; \
    useradd --no-log-init --system --gid foo --create-home foo; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        unzip \
        rsync \
        gosu \
        ##### Build dependencies
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
    pecl install apcu-${PHP_APCU_VERSION:1}; \
    pecl install yaml-$PHP_YAML_VERSION; \
    \
    docker-php-ext-enable \
        apcu \
        yaml \
    ; \
    apt-get purge -y --auto-remove \
        libwebp-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libyaml-dev \
        libzip-dev \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
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
COPY grav.ini $PHP_INI_DIR/conf.d/

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]

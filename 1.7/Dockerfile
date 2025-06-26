FROM php:8.1.32-fpm-bullseye@sha256:3d394495ec03b285e61c44fedc9e82aa613a5179f20b957f7b2a2f77cbd48921

SHELL [ "/bin/bash", "-exo", "pipefail", "-c" ]

# renovate: datasource=github-tags depName=getgrav/grav versioning=semver
ENV GRAV_VERSION 1.7.48
# renovate: datasource=github-tags depName=krakjoe/apcu versioning=semver
ENV PHP_APCU_VERSION v5.1.24
# renovate: datasource=github-tags depName=php/pecl-file_formats-yaml versioning=semver
ENV PHP_YAML_VERSION 2.2.4

RUN groupadd --system foo; \
    useradd --no-log-init --system --gid foo --create-home foo; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        unzip \
        rsync \
        gosu \
        ##### Run dependencies
        libzip4 \
        libyaml-0-2 \
        libpng16-16 \
        libjpeg62-turbo \
        libwebp6 \
        libfreetype6 \
        libicu67 \
        ##### Build dependencies
        libwebp-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libyaml-dev \
        libzip-dev \
        libicu-dev \
    ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
	docker-php-ext-install -j "$(nproc)" \
        zip \
        gd \
        opcache \
        exif \
        intl \
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
        libicu-dev \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
    \
    git clone --branch $GRAV_VERSION https://github.com/getgrav/grav.git /usr/share/grav; \
    rm -rf \
        /usr/share/grav/.editorconfig \
        /usr/share/grav/.gitignore \
        /usr/share/grav/.travis.yml \
        /usr/share/grav/.git \
        /usr/share/grav/assets \
        /usr/share/grav/backup \
        /usr/share/grav/cache \
        /usr/share/grav/images \
        /usr/share/grav/logs \
        /usr/share/grav/tmp \
        /usr/share/grav/tests \
        /usr/share/grav/webserver-configs \
        /usr/share/grav/user \
    ;

COPY entrypoint.sh /entrypoint.sh
COPY grav.ini $PHP_INI_DIR/conf.d/

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]

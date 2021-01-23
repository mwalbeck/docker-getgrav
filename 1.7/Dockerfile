FROM php:7.4.14-fpm-buster@sha256:c1f7ffbe18bbde526c883284d6f02fd26ff11717c1b4e4e9e8815ea177768315

SHELL [ "/bin/bash", "-c" ]

# renovate: datasource=github-tags depName=getgrav/grav versioning=semver
ENV GRAV_VERSION 1.7.3
# renovate: datasource=github-tags depName=krakjoe/apcu versioning=semver
ENV PHP_APCU_VERSION v5.1.19
# renovate: datasource=github-tags depName=php/pecl-file_formats-yaml versioning=semver
ENV PHP_YAML_VERSION 2.2.1

RUN set -ex; \
    \
    groupadd --force --system --gid 33 www-data; \
    useradd --no-log-init --system --gid www-data --no-create-home --uid 33 www-data || true; \
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
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
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
    ; \
    chown -R www-data:www-data /var/www;

COPY entrypoint.sh /entrypoint.sh
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY grav.ini $PHP_INI_DIR/conf.d/

VOLUME [ "/var/www", "/tmp" ]
EXPOSE 9000

USER www-data:www-data

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]

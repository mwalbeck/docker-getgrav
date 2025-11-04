FROM debian:bookworm-slim@sha256:4d9b5b6cf5f643fdf2887eab79f2f916363704184ab270bf4a5c1d65102d03d2

SHELL [ "/bin/bash", "-exo", "pipefail", "-c" ]

# renovate: datasource=github-tags depName=getgrav/grav versioning=semver
ENV GRAV_VERSION=1.7.49.5

RUN groupadd --system foo; \
    useradd --no-log-init --system --gid foo --create-home foo; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        unzip \
        rsync \
        gosu \
        php-fpm \
        php-curl \
        php-xml \
        php-gd \
        php-json \
        php-mbstring \
        php-zip \
        php-apcu \
        php-opcache \
        php-yaml \
        php-intl \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    sed -i 's|^error_log = /var/log/php8\.2-fpm\.log$|error_log = /proc/self/fd/2|' /etc/php/8.2/fpm/php-fpm.conf; \
    sed -i 's|^listen = /run/php/php8\.2-fpm\.sock$|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf; \
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
COPY grav.ini /etc/php/8.2/fpm/conf.d/

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]

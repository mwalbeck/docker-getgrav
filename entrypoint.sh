#!/bin/sh
set -eu

cd /var/www/html
chown -R www-data:www-data .
find . -type f | xargs chmod 664
find ./bin -type f | xargs chmod 775
find . -type d | xargs chmod 775
find . -type d | xargs chmod +s
umask 0002

su -p www-data -s bin/grav install
su -p www-data -s bin/grav clearcache

exec "$@"
#!/bin/sh
set -eu

cd /var/www/html

rsync -rlD --delete \
           --exclude /backup/ \
           --exclude /logs/ \
           --exclude /tmp/ \
           --exclude /vendor/ \
           --exclude /user/ \
           /usr/share/grav/ /var/www/html

mkdir -p assets backup cache images logs tmp

chown -R www-data:www-data .

su -p www-data -s bin/grav install
su -p www-data -s bin/grav clearcache

exec "$@"
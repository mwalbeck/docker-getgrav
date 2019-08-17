#!/bin/sh
set -eu

cd /var/www/html

rsync -rlD --delete \
           --exclude /assets/ \
           --exclude /backup/ \
           --exclude /cache/ \
           --exclude /images/ \
           --exclude /logs/ \
           --exclude /tmp/ \
           --exclude /vendor/ \
           --exclude /user/ \
           /usr/share/grav/ /var/www/html

mkdir -p assets backup cache images logs tmp

chown -R www-data:www-data .
find . -type f | xargs chmod 664
find ./bin -type f | xargs chmod 775
find . -type d | xargs chmod 775
find . -type d | xargs chmod +s
umask 0002

su -p www-data -s bin/grav install
su -p www-data -s bin/grav clearcache

exec "$@"
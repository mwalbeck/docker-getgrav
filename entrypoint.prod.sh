#!/bin/sh
set -eu

GRAV_FOLDER=${GRAV_FOLDER:-html}

mkdir -p /var/www/"$GRAV_FOLDER"
cd /var/www/"$GRAV_FOLDER"

rsync -rlD --delete \
           --exclude /backup/ \
           --exclude /logs/ \
           --exclude /tmp/ \
           --exclude /vendor/ \
           --exclude /user/ \
           /usr/share/grav/ /var/www/"$GRAV_FOLDER"

mkdir -p assets backup cache images logs tmp

bin/grav install
bin/grav clearcache

chown www-data /proc/self/fd/1 /proc/self/fd/2
chown -R --from=root:root www-data:www-data /var/www/"$GRAV_FOLDER"

exec gosu www-data "$@"

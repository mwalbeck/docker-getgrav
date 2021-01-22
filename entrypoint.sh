#!/bin/sh
set -eu

GRAV_FOLDER=${GRAV_FOLDER:-html}

mkdir -p /var/www/$GRAV_FOLDER
cd /var/www/$GRAV_FOLDER

rsync -rlD --delete \
           --exclude /backup/ \
           --exclude /logs/ \
           --exclude /tmp/ \
           --exclude /vendor/ \
           --exclude /user/ \
           /usr/share/grav/ /var/www/$GRAV_FOLDER

mkdir -p assets backup cache images logs tmp

bin/grav install
bin/grav clearcache

exec "$@"

#!/bin/sh
set -eu

UID=${UID:-33}
GID=${GID:-33}
GRAV_FOLDER=${GRAV_FOLDER:-html}

usermod -o -u "$UID" www-data
groupmod -o -g "$GID" www-data

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

chown foo:foo /dev/pts/0
chown -R foo:foo .

su -p foo -s bin/grav install
su -p foo -s bin/grav clearcache

exec gosu foo "$@"

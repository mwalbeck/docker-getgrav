#!/bin/sh
set -eu

UID=${UID:-33}
GID=${GID:-33}
GRAV_FOLDER=${GRAV_FOLDER:-html}

usermod -o -u "$UID" foo
groupmod -o -g "$GID" foo

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

chown foo /proc/self/fd/1 /proc/self/fd/2
chown -R --from=root:root foo:foo /var/www/"$GRAV_FOLDER"

exec gosu foo "$@"

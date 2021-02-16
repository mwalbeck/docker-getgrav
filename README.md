# Grav - docker

Docker container for [GRAV CMS](https://getgrav.org/).

This image is based on the PHP fpm-buster image.

You can find the source code [here](https://git.walbeck.it/walbeck-it/docker-getgrav)

## Tags

* latest, 1.7, 1.7.*
* latest-prod, 1.7-prod, 1.7.*-prod
* 1.6, 1.6.*
* 1.6-prod, 1.6.*-prod

## Usage

This is purely php-fpm based image, which means you need another container to act as the webserver, I recommend nginx. For a nginx config to use with GRAV, you can have a look at the [GRAV documentation](https://learn.getgrav.org/17/webservers-hosting/servers/nginx)

GRAV is by default installed into /var/www/html where you will find all the folders from a normal GRAV install. A user has been created in container with a default id of 33 (same as www-data).

To provide your site data to the container simply do use a volume mount to the desired folder. You can see the docker-compose example at the bottom for an example with volume mount and nginx webserver.

When you deploy or update the docker container it will replace all the neccessary files and leave all folders with potential user generated content. The following folders are ignored

```
backup/
logs/
tmp/
vendor/
user/
```

All other folders will be overwritten, which also means that it's very easy to up and down grade your version of GRAV.

After the GRAV files have been installed a **bin/grav install** will be run to install the correct composer dependencies into vendor and all plugins specified in your dependencies file, if you have one. Lastly the cache will be cleared.

You can customise the user id and group id the container user runs as, and the folder name under /var/www, that GRAV will be installed into, with environment variables:

```
UID=1000
GID=1000
GRAV_FOLDER=awesome-site
```

With the above options the container user will run with a user id and group id of 1000. Grav will be installed into /var/www/awesome-site.

### Prod image

The prod image exists if you would like to use the docker image with the read-only flag enabled. The prod container will be run as www-data with its default UID and GID, 33. You cannot change this at the moment. You can still customise the grav folder name just like the default image.

### Commandline

You can easily use GRAV's commandline interface using docker exec:

```
docker exec -u foo CONTAINER bin/(gpm|grav|plugin)
```

If you choose a custom GRAV_FOLDER you need to specify the workdir like so, replacing GRAV_FOLDER with your chosen folder:

```
docker exec -u www-data -w /var/www/GRAV_FOLDER CONTAINER bin/(gpm|grav|plugin)
```

### Updating

To update the container you simple download the new container and replace it with the old one. For docker-compose that would be

```
docker-compose pull
docker-compose up -d
```

### Example docker-compose

This is a sample docker-compose file using this image along with the official nginx container. The UID and GID has been changed to 1000 with the user option and the grav folder is "awesome-grav-site".

```
version: '2'

volumes:
  grav:

networks:
  frontend:

services:
  app:
    image: mwalbeck/getgrav:latest
    restart: on-failure:5
    networks:
      - frontend
    volumes:
      - grav:/var/www/html
      - /path/to/user:/var/www/html/user
    environment:
      - UID=1000
      - GID=1000
      - GRAV_FOLDER=awesome-grav-site

  web:
    image: nginx:latest
    restart: on-failure:5
    networks:
      - frontend
    volumes:
      - /path/to/nginx:/etc/nginx:ro
    volumes_from:
      - app:ro
    ports:
      - 80:80
      - 443:443
```

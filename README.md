# Grav - docker

Docker container for [GRAV CMS](https://getgrav.org/).

This image is based on the PHP fpm-buster image.

You can find the source code [here](https://git.walbeck.it/walbeck-it/docker-getgrav)

## Tags

* latest
* 1.6
* 1.6.*
* 1.7
* 1.7.*

## Usage

This is purely php-fpm based image, which means you need another container to act as the webserver, I recommend nginx. For a nginx config to use with GRAV, you can have a look at the [GRAV documentation](https://learn.getgrav.org/17/webservers-hosting/servers/nginx)

GRAV is by default installed into /var/www/html where you will find all the folders from a normal GRAV install. By default the container is run as user www-data with id 33.

To provide your site data to the container simply do use a volume mount to the desired folder. You can see the docker-compose example at the bottom for an example with volume mount and nginx webserver.

When you deploy or update the docker container it will replace all the neccessary files and leave all folders with potential user generated content. The following folders are ignored

    backup/
    logs/
    tmp/
    vendor/
    user/

All other folders will be overwritten, which also means that it's very easy to up and down grade your version of GRAV.

After the GRAV files have been installed a **bin/grav install** will be run to install the correct composer dependencies into vendor and all plugins specified in your dependencies file, if you have one. Lastly the cache will be cleared.

You can customize which user the container runs as by using the [user option](https://docs.docker.com/engine/reference/run/#user).

You can also change the folder name under /var/www, that GRAV will be installed into, by setting the following environment variable:

    GRAV_FOLDER=awesome-site

With the above option Grav will be installed into /var/www/awesome-site.

If you wish you can run the container with the read-only option enabled.

### Commandline

You can easily use GRAV's commandline interface using docker exec


    docker exec -u www-data CONTAINER bin/(gpm|grav|plugin)

### Updating

To update the container you simple download the new container and replace it with the old one. For docker-compose that would be

    docker-compose pull
    docker-compose up -d

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
    user: 1000:1000
    networks:
      - frontend
    volumes:
      - grav:/var/www/html
      - /path/to/user:/var/www/html/user
    environment:
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

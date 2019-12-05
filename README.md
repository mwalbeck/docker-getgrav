# Grav - docker

Docker container for [GRAV CMS](https://getgrav.org/).

This image is based on the PHP fpm-buster image.

You can checkout the dockerfile over on [Github](https://github.com/mwalbeck/docker-getgrav), and you're very welcome to report any issue you may find.

## Tags

* latest - lastest release
* 1.6 - latest 1.6.* release
* 1.6.* - that specific version of grav

## Usage

GRAV is installed into /var/www/html where you will find all the folders from a normal grav install.

The php process and the files are run/owned by the www-data user.

You can simple create the volumes you need linked to the desired folders. You can also have a look at the example docker-compose file below if you are in need of inspiration.

This GRAV container works best if you utilize a dependencies file. If you're not familiar with it, you can checkout this [skeleton page](https://github.com/getgrav/grav-skeleton-onepage-site/blob/develop/.dependencies) to get an idea.

When you deploy the docker container it will replace all the neccessary files and leave all folders with potential user generated content. The following folders are ignored
```
backup/
logs/
tmp/
vendor/
user/
```
After the GRAV files have been installed a **bin/grav install** will be run to install the correct composer dependencies into vendor and all plugins specified in your dependencies file. Lastly the cache will be cleared.

### Commandline

You can easily use GRAV's commandline interface using docker exec

```
docker exec -u www-data CONTAINER bin/(gpm|grav|plugin)
```
### Updating

To update the container you simple download the new container and replace it with the old one. For docker-compose that would be

```
docker-compose pull
docker-compose up -d
```

### Example docker-compose

This is a sample docker-compose file using this image along with the official nginx container.

```
version: '2'

volumes:
  grav:

networks:
  frontend:

services:
  app:
    image: mwalbeck/getgrav:latest
    restart: always
    networks:
      - frontend
    volumes:
      - grav:/var/www/html
      - /path/to/user:/var/www/html/user

  web:
    image: nginx:latest
    restart: unless-stopped
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
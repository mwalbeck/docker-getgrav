# Grav - docker

Based on php fpm-buster image

Below is an example docker compose

```
version: '2'

volumes:
  grav:

networks:
  frontend:

services:
  app:
    build: .
    restart: always
    networks:
      - frontend
    volumes:
      - grav:/var/www/html
      - /user:/var/www/html/user

  web:
    image: linuxserver/nginx
    restart: unless-stopped
    networks:
      - frontend
    cap_add:
      - NET_ADMIN
    volumes:
      - /config:/config
      - grav:/var/www/html
      - /user:/var/www/html/user
    ports:
      - 80:80
    environment:
      - PUID=33
      - PGID=33
```
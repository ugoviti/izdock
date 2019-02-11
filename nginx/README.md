# Description
Production ready NGINX Web Server + configuration inotify watch for automatic daemon reload

# Supported tags
-	`1.14.2`, `1.14`, `1`, `latest`

Where **BUILD** is the build number (look into project [Tags](tags/) page to discover the latest BUILD NUMBER)

# Dockerfile
- https://github.com/ugoviti/izdock/blob/master/nginx/Dockerfile

# Features
- Small image footprint
- Based on official [nginx](/_/nginx/) and [Debian Slim](/_/debian/) image
- Configuration inotify watch for automatic daemon reload

# What is nginx?

nginx [engine x] is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server

![logo](http://nginx.org/nginx.png)

# How to use this image.

This image only contains the service from the defaults repository.

# Environment variables

You can change the default behaviour using the following variables (in bold the default values):

**NGINX Web Server:**
:FIXME:

### Create a `Dockerfile` in your project

```dockerfile
FROM izdock/nginx
COPY ./public-html/ /usr/local/apache2/htdocs/
```

Then, run the commands to build and run the Docker image:

```console
$ docker build -t my-nginx .
$ docker run -dit --name my-webapp -p 8080:80 my-nginx
```

Visit http://localhost:8080 and you will see It works!

### Without a `Dockerfile`

If you don't want to include a `Dockerfile` in your project, it is sufficient to do the following:

```console
$ docker run -dit --name my-webapp -p 8080:80 -v "$PWD":/var/www/localhost/htdocs izdock/nginx
```

### Configuration

To customize the configuration of the nginx server, just `COPY` your custom configuration in as `/etc/nginx/conf.d/default.conf`.

```dockerfile
FROM izdock/nginx
COPY ./my-nginx.conf /etc/nginx/conf.d/default.conf
```

# Quick reference

-	**Where to get help**:
	[InitZero Corporate Support](https://www.initzero.it/)

-	**Where to file issues**:
	[https://github.com/ugoviti](https://github.com/ugoviti)

-	**Maintained by**:
	[Ugo Viti](https://github.com/ugoviti)

-	**Supported architectures**:
	[`amd64`]

-	**Supported Docker versions**:
	[the latest release](https://github.com/docker/docker-ce/releases/latest) (down to 1.6 on a best-effort basis)

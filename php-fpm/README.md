# Description
Production ready PHP-FPM image based on Alpine Linux + izsendmail for MTA logging

# Supported tags (`Dockerfile` will be included in a future release)

All images are based on [izdock httpd image](/r/izdock/httpd/)

-	`7.2.8-BUILD`, `7.2.8`, `7.2`, `7`, `latest`
-	`7.1.20-BUILD`, `7.1.20`, `7.1`,
-	`5.6.37-BUILD`, `5.6.37`, `5.6`, `5`

Where **BUILD** is the build number (look into project [Tags](tags/) page to discover the latest BUILD NUMBER)

# Features
- Small image footprint
- The Apache HTTPD Web Server is removed from this image
- You can use `izdock/php-fpm` as sidecar image (Docker Compose or Kubernetes) for NGINX or Apache configured with MPM Event and Reverse Proxy for PHP pages
- Build from scratch PHP interpreter with all modules included, plus external modules (igbinary apcu msgpack opcache memcached redis xdebug phpiredis realpath_turbo tarantool)
- Included izsendmail bash script as wrapper for `msmtp` for PHP logging of outgoing emails
- Many customizable variables to use

# Quick reference

-	**Where to get help**:
	[InitZero Corporate Support](https://www.initzero.it/)

-	**Where to file issues**:
	[https://github.com/ugoviti](https://github.com/ugoviti)

-	**Maintained by**:
	[Ugo Viti](https://github.com/ugoviti)

-	**Supported architectures**: ([more info](https://github.com/docker-library/official-images#architectures-other-than-amd64))
	[`amd64`](https://hub.docker.com/r/amd64/httpd/

-	**Supported Docker versions**:
	[the latest release](https://github.com/docker/docker-ce/releases/latest) (down to 1.6 on a best-effort basis)

# What is php-fpm?

TODO

# How to use this image.

TODO

### Create a `Dockerfile` in your project

TODO

### Without a `Dockerfile`

If you don't want to include a `Dockerfile` in your project, it is sufficient to do the following:

```console
$ docker run -dit --name my-webapp -p 8080:80 -v "$PWD":/var/www/localhost/htdocs izdock/php-fpm
```

### Configuration

TODO

## `izdock/php-fpm:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of.

This image is based on the popular [Alpine Linux project](http://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](http://www.musl-libc.org) instead of [glibc and friends](http://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as `git` or `bash`) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [`alpine` image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).

# License

View [license information](http://php.net/license/index.php) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

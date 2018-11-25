# Description
Production ready PHP-FPM (FastCGI Process Manager) image based on Alpine Linux + izsendmail for MTA logging

# Supported tags
-	`7.2.12-BUILD`, `7.2.12`, `7.2`, `7`, `latest`
-	`7.1.24-BUILD`, `7.1.24`, `7.1`,
-	`5.6.38-BUILD`, `5.6.38`, `5.6`, `5`

Where **BUILD** is the build number (look into project [Tags](tags/) page to discover the latest BUILD NUMBER)

# Dockerfile
- https://github.com/ugoviti/izdock/blob/master/php-fpm/Dockerfile

# Features
- Small image footprint (all images are based on [izdock httpd image](/r/izdock/httpd/))
- The Apache HTTPD Web Server is removed from this image
- You can use `izdock/php-fpm` as sidecar image (Docker Compose or Kubernetes) for NGINX or Apache configured with MPM Event and Reverse Proxy for PHP pages
- Build from scratch PHP interpreter with all modules included, plus external modules (igbinary apcu msgpack opcache memcached redis xdebug phpiredis realpath_turbo tarantool)
- Included izsendmail bash script as wrapper for `msmtp` for PHP logging of outgoing emails
- Many customizable variables to use

# What is php-fpm?

PHP-FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features useful for sites of any size, especially busier sites.

These features include:

- Adaptive process spawning (NEW!)
- Basic statistics (ala Apache's mod_status) (NEW!)
- Advanced process management with graceful stop/start
- Ability to start workers with different uid/gid/chroot/environment and different php.ini (replaces safe_mode)
- Stdout & stderr logging
- Emergency restart in case of accidental opcode cache destruction
- Accelerated upload support
- Support for a "slowlog"
- Enhancements to FastCGI, such as fastcgi_finish_request() - a special function to finish request & flush all data while continuing to do something time-consuming (video converting, stats processing, etc.)

... and much more.

It was not designed with virtual hosting in mind (large amounts of pools) however it can be adapted for any usage model.


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

## `izdock/php-fpm:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of.

This image is based on the popular [Alpine Linux project](http://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](http://www.musl-libc.org) instead of [glibc and friends](http://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as `git` or `bash`) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [`alpine` image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).

# License

View [license information](http://php.net/license/index.php) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

# Description
Production ready [ProxySQL](http://www.proxysql.com/) image based on Debian 9 Slim

# Supported tags (`Dockerfile` will be included in a future release)

-	`1.4.10-BUILD`, `1.4.10`, `1.4`, `1`, `latest`

Where **BUILD** is the build number (look into project [Tags](tags/) page to discover the latest BUILD NUMBER)

# Features
- Small image footprint
- Using [tini](https://github.com/krallin/tini) as init process

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

# What is ProxySQL?

ProxySQL helps you squeeze the last drop of performance out of your MySQL cluster, without controlling the applications that generate the queries.

# How to use this image.

### Create a `Dockerfile` in your project

TODO

### Without a `Dockerfile`

If you don't want to include a `Dockerfile` in your project, it is sufficient to do the following:

```console
$ docker run -dit --name proxysql -p 3306:3306 izdock/proxysql
```

### Configuration

TODO

# License

View [license information](http://www.proxysql.com/) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

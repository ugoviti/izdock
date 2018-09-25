# Description
Production ready [ProxySQL](http://www.proxysql.com/) image based on Debian 9 (stretch) Slim

# Supported tags
-	`1.4.11-BUILD`, `1.4.11`, `1.4`, `1`, `latest`
-	`1.4.10-BUILD`, `1.4.10`

Where **BUILD** is the build number (look into project [Tags](tags/) page to discover the latest BUILD NUMBER)

# Dockerfile
- https://github.com/ugoviti/izdock/blob/master/proxysql/Dockerfile

# Features
- Small image footprint based on [Debian 9 (stretch) Slim](https://hub.docker.com/_/debian/)
- Using [tini](https://github.com/krallin/tini) as init process

# What is ProxySQL?
ProxySQL is a high performance, high availability, protocol aware proxy for MySQL.
ProxySQL helps you squeeze the last drop of performance out of your MySQL cluster, without controlling the applications that generate the queries.
ProxySQL has an advanced multi-core architecture. It's built from the ground up to support hundreds of thousands of concurrent connections, multiplexed to potentially hundreds of backend servers. The largest ProxySQL deployment spans several hundred proxies.

# How to use this image.

### Configuration

Create `proxysql.cnf`:

```ini
datadir="/var/lib/proxysql"

admin_variables =
{
  admin_credentials="admin:tcPzhHnWYr795pzK"
  mysql_ifaces="0.0.0.0:6032"
  refresh_interval=2000
}

mysql_variables=
{
  threads=2
  max_connections=2048
  default_query_delay=0
  #default_query_timeout=10000
  poll_timeout=2000
  interfaces="0.0.0.0:3306"
  default_schema="information_schema"
  stacksize=1048576
  connect_timeout_server=3000
  monitor_history=60000
  monitor_connect_interval=20000
  monitor_ping_interval=10000
  ping_timeout_server=500
  commands_stats=true
  sessions_sort=true
}

mysql_servers =
(
  { address="database.prod.svc.cluster.local", port=3306, hostgroup=0, max_connections=2048 }
)

mysql_users =
(
  { username = "admin", password = "tcPzhHnWYr795pzK", default_hostgroup = 0 },
  { username = "user1", password = "xc3PCTanXWoWppHE", default_hostgroup = 0 },
  { username = "user2", password = "2S8hGuAhZ9XD5k9F", default_hostgroup = 0 }
)

mysql_query_rules =
(
#	{
#		rule_id=1
#		active=1
#		match_pattern="^SELECT"
#		destination_hostgroup=0
#		apply=1
#	}
)
```

### Create a `Dockerfile` in your project

```dockerfile
FROM izdock/proxysql
COPY ./proxysql.cnf /etc/proxysql.cnf
```

### Without a `Dockerfile`

If you don't want to include a `Dockerfile` in your project, it is sufficient to do the following:

```console
$ docker run -dit --name proxysql -p 3306:3306 -v /path/to/proxysql.cnf:/etc/proxysql.cnf izdock/proxysql
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

# License

View [license information](http://www.proxysql.com/) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

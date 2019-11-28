ARG image_from=zabbix/zabbix-agent:centos

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

# custom app configuration variables
ENV APP_NAME              "zabbix-agent"
ENV APP_DESCRIPTION       "Zabbix Agent"
ENV APP_CONF              ""
ENV APP_CONF_PHP          ""
ENV APP_DATA              ""
ENV APP_LOGS              ""

RUN set -eux && \
  yum -y install epel-release && \
  yum install -y jq libxml2 && \
  mkdir -p /etc/zabbix/scripts /etc/zabbix/zabbix_agentd.d && \
  cd /etc/zabbix/zabbix_agentd.d/ && \
  curl -fSL --connect-timeout 30 https://raw.githubusercontent.com/kreicer/zabbix-phpfpm-monitoring/master/fpm-monitoring.conf -o fpm-monitoring.conf && \
  cd /etc/zabbix/scripts && \
  curl -fSL --connect-timeout 30 https://raw.githubusercontent.com/kreicer/zabbix-phpfpm-monitoring/master/fpm-monitoring.sh -o fpm-monitoring.sh && \
  chmod 755 fpm-monitoring.sh && \
  yum -y clean all --enablerepo='*' && \
  rm -rf /var/cache/yum

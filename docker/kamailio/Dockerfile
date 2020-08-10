FROM debian:jessie as build-env

MAINTAINER Andrew Webster <webstean@gmail.com>

#
WORKDIR /app

# avoid httpredir errors
RUN sed -i 's/httpredir/deb/g' /etc/apt/sources.list

RUN rm -rf /var/lib/apt/lists/* && apt-get update &&   apt-get install --assume-yes gnupg wget
# kamailio repo
RUN echo "deb http://deb.kamailio.org/kamailio52 jessie main" >   /etc/apt/sources.list.d/kamailio.list
RUN wget -O- http://deb.kamailio.org/kamailiodebkey.gpg | apt-key add -

# install
# RUN apt-get update && apt-get install --assume-yes kamailio=5.2.7+bpo10 kamailio-autheph-modules=5.2.7+bpo10 kamailio-berkeley-bin=5.2.7+bpo10 kamailio-berkeley-modules=5.2.7+bpo10 kamailio-cnxcc-modules=5.2.7+bpo10 kamailio-cpl-modules=5.2.7+bpo10 kamailio-dbg=5.2.7+bpo10 kamailio-erlang-modules=5.2.7+bpo10 kamailio-extra-modules=5.2.7+bpo10 kamailio-geoip-modules=5.2.7+bpo10 kamailio-geoip2-modules=5.2.7+bpo10 kamailio-ims-modules=5.2.7+bpo10 kamailio-json-modules=5.2.7+bpo10 kamailio-kazoo-modules=5.2.7+bpo10 kamailio-ldap-modules=5.2.7+bpo10 kamailio-lua-modules=5.2.7+bpo10 kamailio-memcached-modules=5.2.7+bpo10 kamailio-mongodb-modules=5.2.7+bpo10 kamailio-mono-modules=5.2.7+bpo10 kamailio-mysql-modules=5.2.7+bpo10 kamailio-nth=5.2.7+bpo10 kamailio-outbound-modules=5.2.7+bpo10 kamailio-perl-modules=5.2.7+bpo10 kamailio-phonenum-modules=5.2.7+bpo10 kamailio-postgres-modules=5.2.7+bpo10 kamailio-presence-modules=5.2.7+bpo10 kamailio-python-modules=5.2.7+bpo10 kamailio-python3-modules=5.2.7+bpo10 kamailio-rabbitmq-modules=5.2.7+bpo10 kamailio-radius-modules=5.2.7+bpo10 kamailio-redis-modules=5.2.7+bpo10 kamailio-ruby-modules=5.2.7+bpo10 kamailio-sctp-modules=5.2.7+bpo10 kamailio-snmpstats-modules=5.2.7+bpo10 kamailio-sqlite-modules=5.2.7+bpo10 kamailio-systemd-modules=5.2.7+bpo10 kamailio-tls-modules=5.2.7+bpo10 kamailio-unixodbc-modules=5.2.7+bpo10 kamailio-utils-modules=5.2.7+bpo10 kamailio-websocket-modules=5.2.7+bpo10 kamailio-xml-modules=5.2.7+bpo10 kamailio-xmpp-modules=5.2.7+bpo10
RUN apt-get update && apt-get install --assume-yes kamailio=5.2.7+bpo10 kamailio-autheph-modules=5.2.7+bpo10 kamailio-berkeley-bin=5.2.7+bpo10 kamailio-berkeley-modules=5.2.7+bpo10 kamailio-cnxcc-modules=5.2.7+bpo10 kamailio-cpl-modules=5.2.7+bpo10 kamailio-dbg=5.2.7+bpo10 kamailio-erlang-modules=5.2.7+bpo10 kamailio-extra-modules=5.2.7+bpo10 kamailio-geoip-modules=5.2.7+bpo10 kamailio-geoip2-modules=5.2.7+bpo10 kamailio-ims-modules=5.2.7+bpo10 kamailio-json-modules=5.2.7+bpo10 kamailio-kazoo-modules=5.2.7+bpo10 kamailio-ldap-modules=5.2.7+bpo10 kamailio-lua-modules=5.2.7+bpo10 kamailio-memcached-modules=5.2.7+bpo10 kamailio-mongodb-modules=5.2.7+bpo10 kamailio-mono-modules=5.2.7+bpo10 kamailio-mysql-modules=5.2.7+bpo10 kamailio-nth=5.2.7+bpo10 kamailio-outbound-modules=5.2.7+bpo10 kamailio-perl-modules=5.2.7+bpo10 kamailio-phonenum-modules=5.2.7+bpo10 kamailio-postgres-modules=5.2.7+bpo10 kamailio-presence-modules=5.2.7+bpo10 kamailio-python-modules=5.2.7+bpo10 kamailio-python3-modules=5.2.7+bpo10 kamailio-rabbitmq-modules=5.2.7+bpo10 kamailio-radius-modules=5.2.7+bpo10 kamailio-redis-modules=5.2.7+bpo10 kamailio-ruby-modules=5.2.7+bpo10 kamailio-sctp-modules=5.2.7+bpo10 kamailio-snmpstats-modules=5.2.7+bpo10 kamailio-sqlite-modules=5.2.7+bpo10 kamailio-systemd-modules=5.2.7+bpo10 kamailio-tls-modules=5.2.7+bpo10 kamailio-unixodbc-modules=5.2.7+bpo10 kamailio-utils-modules=5.2.7+bpo10 kamailio-websocket-modules=5.2.7+bpo10 kamailio-xml-modules=5.2.7+bpo10 kamailio-xmpp-modules=5.2.7+bpo10

VOLUME /etc/kamailio

# needs database created
RUN kamctl add 1234 abc123 && kamctl add 1111 abc123 && kamctl add 2345 abc123
# clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["kamailio", "-DD", "-E"]

FROM debian:jessie as run-env
WORKDIR /app
COPY --from=build-env 


FROM alpine:latest as kamailio

### FROM kamailio/kamailio-ci:latest-alpine as kamailio

LABEL maintainer="webstean@gmail.com"

# Root Stuff

# Create User
# RUN groupadd -r postgres && useradd --no-log-init -r -g postgres postgres.

# Prereqs
RUN apk --no-cache add tzdata libpq

# Timezone
RUN cp /usr/share/zoneinfo/Australia/Melbourne /etc/localtime && \
    echo "Australia/Melbourne" >  /etc/timezone && \
    date && mkdir -p /etc/kamailio/db

ENV AW=tem
ENV LANG=en_US.UTF-8 
ENV LANGUAGE=en_US.UTF-8
ENV DB=/etc/kamailio/db/
ENV USERAS=kamailio

# Install Kamailio
RUN apk --no-cache add sqlite kamailio kamailio-presence kamailio-sqlite kamailio-tls kamailio-db 
RUN apk --no-cache add kamailio-authephemeral kamailio-carrierroute kamailio-cpl kamailio-ev kamailio-extras kamailio-geoip2 kamailio-ims kamailio-json kamailio-openrc kamailio-outbound kamailio-sctp kamailio-sipdump
RUN apk --no-cache add kamailio-utils kamailio-xml curl 

# Install Letsencrypt
#RUN apk --no-cache add netcat-openbsd bc curl wget git bash openssl
#RUN apk --no-cache apk libressl
#RUN git clone https://github.com/Neilpang/acme.sh.git /tmp

# Get Geoip database
#RUN curl -v "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=tyrhLJpJiWmke42x&suffix=tar.gz" --output /etc/kamailio/db/geoip.tar.gz
#RUN tar t -f /etc/kamailio/db/geoip.tar.gz
#RUN ls -la /etc/kamailio/db
#RUN false
#RUN tar x -zv --exclude 'GeoLite2-Country_*/' -f /etc/kamailio/db/geoip.tar.gz -C /etc/kamailio/db
#RUN ls -la /etc/kamailio/db
#RUN ls -la /etc/kamailio/db/GeoLite2-Country_20200818
#RUN false
#RUN mv /etc/kamailio/GeoLite2-Country*/GeoLite2-Country.mmdb ${DB}

RUN chown ${USERAS}:${USERAS} /etc/kamailio/* && chown ${USERAS}:${USERAS} /etc/kamailio

RUN mkdir -p /usr/local/etc/kamailio/ && chown -R ${USERAS}:${USERAS} /usr/local/etc/kamailio

# Configure kamailio to talk to SQLLite Database
RUN echo "SIP_DOMAIN=sip.local.net" > /etc/kamailio/kamctlrc
RUN echo "DBENGINE=SQLITE" >> /etc/kamailio/kamctlrc
RUN echo "DB_PATH=${DB}/sqlite" >> /etc/kamailio/kamctlrc
RUN echo "INSTALL_EXTRA_TABLES=yes" >> /etc/kamailio/kamctlrc
RUN echo "INSTALL_PRESENCE_TABLES=yes" >> /etc/kamailio/kamctlrc
RUN echo "INSTALL_DBUID_TABLES=yes" >> /etc/kamailio/kamctlrc

##RUN ls -la /usr/lib/kamailio/modules/tl*
##RUN false

RUN mkdir -p ${DB} && kamdbctl create
RUN chown -R ${USERAS}:${USERAS} ${DB} && chmod 0700 ${DB}

RUN kamctl add 201 201 && kamctl add 202 202 && kamctl add 301 301 && kamctl add 302 302

# Change User
USER ${USERAS}

### RUN cat /etc/kamailio/kamailio.cfg | grep module

COPY files/sip-router.cfg /etc/kamailio/kamailio-local.cfg
COPY files/routing.cfg /etc/kamailio/routing.cfg
COPY files/dispatcher.list /etc/kamailio/dispatcher.list
COPY files/tls.cfg /etc/kamailio
COPY files/tls.cfg /usr/local/etc/kamailio/tls.cfg
COPY files/GeoLite2-Country.mmdb /etc/kamailio/db/GeoLite2-Country.mmdb

RUN cat /etc/kamailio/dispatcher.list

### RUN curl https://raw.githubusercontent.com/kamailio/kamailio/master/etc/kamailio.cfg -o /etc/kamailio/kamailio.cfg
RUN cat /etc/kamailio/routing.cfg >> /etc/kamailio/kamailio.cfg

# Permission Modules files
RUN curl https://raw.githubusercontent.com/kamailio/kamailio/master/src/modules/permissions/config/permissions.allow -o /etc/kamailio/permissions.allow
RUN curl https://raw.githubusercontent.com/kamailio/kamailio/master/src/modules/permissions/config/permissions.deny -o /etc/kamailio/permissions.deny
RUN curl https://raw.githubusercontent.com/kamailio/kamailio/master/src/modules/permissions/config/register.allow -o /etc/kamailio/register.allow
RUN curl https://raw.githubusercontent.com/kamailio/kamailio/master/src/modules/permissions/config/register.deny -o /etc/kamailio/register.deny

RUN echo "All : ALL" >> /etc/kamailio/permissions.allow
RUN echo "All : ALL" >> /etc/kamailio/register.allow

RUN grep auth_db /etc/kamailio/kamailio.cfg

## RUN ls -la /etc/kamailio
## RUN false

COPY files/docker-entrypoint.sh /

#### ENTRYPOINT ["/docker-entrypoint.sh"]

ENTRYPOINT ["kamailio", "-DD", "-E"]

# Expose the PostgreSQL port
# SIP/SCTP
EXPOSE 5060/udp
# SIP
EXPOSE 5060/tcp
# SIP with TLS
EXPOSE 5061/tcp


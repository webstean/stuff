FROM alpine:latest as kamailio-sqlite

LABEL maintainer="webstean@gmail.com"

# Root Stuff

# Create User
# RUN groupadd -r postgres && useradd --no-log-init -r -g postgres postgres.

# Install Postresql into /usr/bin
RUN apk update && apk --no-cache add tzdata libpq sqlite sudo

# Enable sudo for all
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

## RUN dnf -y install dnf-plugins-core && dnf config-manager --add-repo https://rpm.kamailio.org/centos/kamailio.repo && dnf install kamailio

## RUN yum -y install yum-utils && yum-config-manager --add-repo https://rpm.kamailio.org/centos/kamailio.repo && yum install kamailio

# Timezone
RUN cp /usr/share/zoneinfo/Australia/Melbourne /etc/localtime && \
    echo "Australia/Melbourne" >  /etc/timezone && \
    date 

ENV TZ="Australia/Melbourne"
ENV LANG=en_AU.UTF-8
ENV LANGUAGE=
RUN locale-gen ${LANG}

ENV PGDATA /var/lib/kamailio/data
ENV USERAS kamailio

ENV RUN_KAMAILIO=yes

# Install Kamailio
RUN apk --no-cache add  kamailio kamailio-json kamailio-sctp kamailio-presence \
                        kamailio-sqlite kamailio-mysql kamailio-extras kamailio-uuid kamailio-websocket \
                        kamailio-ev kamailio-geoip2-modules

RUN chown ${USERAS}:${USERAS} /etc/kamailio/* && chown ${USERAS}:${USERAS} /etc/kamailio

RUN mkdir -p ${PGDATA} && chown -R ${USERAS}:${USERAS} ${PGDATA} && chmod 0700 ${PGDATA}

#RUN mkdir /var/run/postgresql && chown -R ${USERAS}:${USERAS} /var/run/postgresql

# Change User
USER ${USERAS}

# Configure kamailio to talk to Database
RUN sed "/^[# ]*SIP_DOMAIN/cSIP_DOMAIN=sip.local.net" -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBENGINE/cDBENGINE=MYSQLSQLITE' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DB_PATH/cDB_PATH=${PGDATA}/${USERAS}' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBHOST/cDBHOST=localhost' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBNAME/cDBNAME=openser' -i /etc/kamailio/kamctlrc
#RUN sed '/^[# ]*DBRWUSER/cDBRWUSER=openser' -i /etc/kamailio/kamctlrc
#RUN sed '/^[# ]*DBRWPW/cDBRWPW="openser"' -i /etc/kamailio/kamctlrc
#RUN sed '/^[# ]*DBROUSER/cDBROUSER=openserro' -i /etc/kamailio/kamctlrc
#RUN sed '/^[# ]*DBROPW/cDBROPW=openserro' -i /etc/kamailio/kamctlrc
#RUN sed '/^[# ]*DBROOTUSER/cDBROOTUSER="postgres" ' -i /etc/kamailio/kamctlrc
RUN echo "INSTALL_EXTRA_TABLES=no" >> /etc/kamailio/kamctlrc
RUN echo "INSTALL_PRESENCE_TABLES=no" >> /etc/kamailio/kamctlrc
RUN echo "INSTALL_DBUID_TABLES=no" >> /etc/kamailio/kamctlrc

RUN touch /etc/kamailio/kamailio-local.cfg

## RUN echo "enable_sctp = 1" >> /etc/kamailio/kamailio-local.cfg

RUN echo "log_stderror = yes" >> /etc/kamailio/kamailio-local.cfg

## GeoIP - /usr/share/GeoIP

# silently drop scanners
##RUN echo "## Block Rogue Agents " >> /etc/kamailio/kamailio-local.cfg
##RUN echo "route {" >> /etc/kamailio/kamailio-local.cfg
##RUN echo "     if(\$ua) =~ \"friendly-scanner|sipcli|VaxSIPUserAgent\" {" >> /etc/kamailio/kamailio-local.cfg
##RUN echo "     # silently drop scanners" >> /etc/kamailio/kamailio-local.cfg
##RUN echo "     sl_send_reply("200", "Ok");" >> /etc/kamailio/kamailio-local.cfg
##RUN echo "     exit;" >> /etc/kamailio/kamailio-local.cfg
##RUN echo "   }" >> /etc/kamailio/kamailio-local.cfg
##RUN echo "}" >> /etc/kamailio/kamailio-local.cfg

RUN echo "## Add Path extension for Asterisk" >> /etc/kamailio/kamailio-local.cfg
RUN echo "add_path_received()" >> /etc/kamailio/kamailio-local.cfg

RUN cat /etc/kamailio/kamailio-local.cfg

##RUN echo "DBENGINE=SQLITE" > /etc/kamailio/kamctlrc
##RUN echo "SIP_DOMAIN=sip.local.net" >> /etc/kamailio/kamctlrc
##RUN echo "DBHOST=localhost" >> /etc/kamailio/kamctlrc
##RUN echo "DB_PATH=${PGDATA}/${USERAS}" >> /etc/kamailio/kamctlrc
##RUN echo "DBNAME=openser" >> /etc/kamailio/kamctlrc
##RUN echo "INSTALL_EXTRA_TABLES=yes" >> /etc/kamailio/kamctlrc
##RUN echo "INSTALL_PRESENCE_TABLES=yes" >> /etc/kamailio/kamctlrc
##RUN echo "INSTALL_DBUID_TABLES=yes" >> /etc/kamailio/kamctlrc

RUN sqlite3 ${PGDATA}/${USERAS} && kamdbctl create ${PGDATA}/${USERAS}

RUN kamctl add 1234 1234 && kamctl add 2345 2345 && kamctl add 9999 9999 && kamctl add 1111 1111 

COPY files/docker-entrypoint.sh /
COPY files/kamailio.cfg /etc/kamailio/kamailio.cfg

ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose the SIP port
EXPOSE 5060/udp

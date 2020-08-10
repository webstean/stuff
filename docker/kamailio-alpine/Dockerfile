FROM alpine:latest as kamailio

LABEL maintainer="webstean@gmail.com"

# Root Stuff

# Create User
# RUN groupadd -r postgres && useradd --no-log-init -r -g postgres postgres.

# Install Postresql into /usr/bin
RUN apk --no-cache add tzdata libpq postgresql postgresql-client postgresql-contrib

# Timezone
RUN cp /usr/share/zoneinfo/Australia/Melbourne /etc/localtime && \
    echo "Australia/Melbourne" >  /etc/timezone && \
    date 

ENV LANG=en_US.UTF-8 
ENV LANGUAGE=en_US.UTF-8
ENV PGDATA /var/lib/kamailio/data
ENV USERAS postgres

# Install Kamailio
RUN apk --no-cache add kamailio kamailio-presence kamailio-postgres

RUN chown ${USERAS}:${USERAS} /etc/kamailio/* && chown ${USERAS}:${USERAS} /etc/kamailio

RUN mkdir -p ${PGDATA} && chown -R ${USERAS}:${USERAS} ${PGDATA} && chmod 0700 ${PGDATA}

RUN mkdir /var/run/postgresql && chown -R ${USERAS}:${USERAS} /var/run/postgresql

# Change User
USER ${USERAS}

# Configure kamailio to talk to Database
RUN sed "/^[# ]*SIP_DOMAIN/cSIP_DOMAIN=sip.local.net" -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBENGINE/cDBENGINE=PGSQL' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBHOST/cDBHOST=localhost' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBNAME/cDBNAME=openser' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBRWUSER/cDBRWUSER=openser' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBRWPW/cDBRWPW="openser"' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBROUSER/cDBROUSER=openserro' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBROPW/cDBROPW=openserro' -i /etc/kamailio/kamctlrc
RUN sed '/^[# ]*DBROOTUSER/cDBROOTUSER="postgres" ' -i /etc/kamailio/kamctlrc

# Configure
RUN pg_ctl -D ${PGDATA} initdb && \
    cp /usr/share/postgresql/postgresql.conf.sample ${PGDATA}/postgresql.conf && \
    echo "host all  all    0.0.0.0/0  md5" >> ${PGDATA}/pg_hba.conf && \
    echo "listen_addresses='*'" >> ${PGDATA}/postgresql.conf && \
    pg_ctl -D ${PGDATA} start && echo postgres > /tmp/.pgpass && \
    chmod 600 /tmp/.pgpass && \
    kamdbctl create openser && \
    kamctl add 1234 1234 && kamctl add 2345 2345 && kamctl add 9999 9999 && kamctl add 1111 1111 && \
    pg_ctl -D ${PGDATA} stop

COPY files/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose the PostgreSQL port
EXPOSE 5432


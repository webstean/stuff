#!/bin/sh
chown -R postgres "$PGDATA"


#
# Kamailio TLS Configuration File
# for Microsoft Direct Routing
#
[server:default]
method = TLSv1.2+
verify_certificate = yes
require_certificate = yes
private_key = /etc/letsencrypt/live/sbc.lordsomerscamp.org.au/privkey.pem
certificate = /etc/letsencrypt/live/sbc.lordsomerscamp.org.au/fullchain.pem
#ca_list = /etc/ca-certificates.conf

[client:default]
method = TLSv1.2+
verify_certificate = yes
require_certificate = yes
private_key = /etc/letsencrypt/live/sbc.lordsomerscamp.org.au/privkey.pem
certificate = /etc/letsencrypt/live/sbc.lordsomerscamp.org.au/fullchain.pem
#ca_list = /etc/ca-certificates.conf


######################################################################
# Send calls to the PSTN-Gateways:
######################################################################
route[PSTN-Gateway] {
#Kamal: Commented below
#   if (!ds_select_domain("1", "4")) {
#		xlog("L_WARN","No PSTN-Gateways available - M=$rm R=$ru F=$fu T=$tu IP=$si:$sp ID=$ci\n\n");
#		send_reply("503", "Service not available");
#		exit;
#	}
	# Relay the request:
	t_on_failure("PSTN_failure");

	t_relay();
	exit;
}

######################################################################
# xxxxxxxxxxxxxxxxxxxxxxxxxxx
######################################################################
route[PSTN_HANDLING] {
	# First, we translate "tel:"-URI's to SIP-URI's:
	# $ru:           tel:+(34)-999-888-777
	# $fu:           sip:test@foo.com
	# becomes $ru:   sip:+34999888777@foo.com;user=phone
	if (!tel2sip("$ru", "$fd", "$ru"))
		xlog("L_WARN","Failed to convert $ru to a sip:-URI - M=$rm R=$ru F=$fu T=$tu IP=$si:$sp ID=$ci\n\n");

	if ($rU =~ "\+[0-9]+") {
#!ifdef WITH_ENUM
        # Now let's check, if the number can be found in ENUM:
		if(!enum_query()) {
			# ENUM failed, send it to the PSTN-Gateway:
        }
#!endif
		route(PSTN);
		break;
	}
}

route[PSTN] {
    return ;
}






if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf

    : ${POSTGRES_USER:="postgres"}
    : ${POSTGRES_DB:=$POSTGRES_USER}

    if [ "$POSTGRES_PASSWORD" ]; then
      pass="PASSWORD '$POSTGRES_PASSWORD'"
      authMethod=md5
    else
      echo "==============================="
      echo "!!! NO PASSWORD SET !!! (Use \$POSTGRES_PASSWORD env var)"
      echo "==============================="
      pass=
      authMethod=trust
    fi
    echo


    if [ "$POSTGRES_DB" != 'postgres' ]; then
      createSql="CREATE DATABASE $POSTGRES_DB;"
      echo $createSql | gosu postgres postgres --single -jE
      echo
    fi

    if [ "$POSTGRES_USER" != 'postgres' ]; then
      op=CREATE
    else
      op=ALTER
    fi

    userSql="$op USER $POSTGRES_USER WITH SUPERUSER $pass;"
    echo $userSql | gosu postgres postgres --single -jE
    echo

    gosu postgres pg_ctl -D "$PGDATA" \
        -o "-c listen_addresses=''" \
        -w start

    echo
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sh)  echo "$0: running $f"; . "$f" ;;
            *.sql) echo "$0: running $f"; psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < "$f" && echo ;;
            *)     echo "$0: ignoring $f" ;;
        esac
        echo
    done

    gosu postgres pg_ctl -D "$PGDATA" -m fast -w stop

    { echo; echo "host all all 0.0.0.0/0 $authMethod"; } >> "$PGDATA"/pg_hba.conf
fi

exec gosu postgres "$@"
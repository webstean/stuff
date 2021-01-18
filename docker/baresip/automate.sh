#!/bin/sh
export BARESIP_IP=127.0.0.1
export BARESIP_PORT=5555
export CMDFILE=/tmp/baresip

cat > ${CMDFILE} <<EOF
/uanew sip:100@sbc.lordsomerscamp.org.au;auth_pass=mypassword;;answermode=auto
d 200
b
EOF

netcat -u ${BARESIP_IP} -p {BARESIP_PORT} < $CMDFILE



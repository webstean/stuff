#!/bin/sh
# Kamailio exec module - script with exec_msg("execshow.sh")
#SIP_HF_<hf_name> contains value of each header field in request. If a header field occurred multiple times, values are concatenated and comma-separated. <hf_name> is in capital letters. Ff a header-field name occurred in compact form, <hf_name> is canon
echo Kamailio Header Fields....
echo $SIP_HF_*

echo Trans. Identifier : $SIP_TID
echo Dialog Identifier : $SIP_DID

echo Source IP Address : $SIP_SRCIP

echo Orginal URI       : $SIP_ORURI
echo Changed URI       : $SIP_RURI

echo SIP User          : $IP_USER
echo SIP User (Orginal): $SIP_OUSER

#!/bin/bash
set -e


echo Starting baresip...
exec /baresip/baresip -f /baresip/etc -v -f "/baresip" "-e /about" "-e /sysinfo"
exit $?

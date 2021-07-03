#!/bin/sh

sudo apt install -y unzip

# Get image file
wget https://downloads.raspberrypi.org/raspios_lite_armhf_latest --trust-server-names --timestamping
unzip *-armhf.zip

# Write image file

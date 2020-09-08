#!/bin/bash

# Check if we are running as the root user
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root - exiting" ; exit 1 ; fi

# Check if this is a Raspberry Pi
if [ (egrep -q "BCM(283(5|6|7)|270(8|9)|2711)" /proc/cpuinfo) -ne 0 ] ; then echo "This is not a Raspiberry Pi - exiting" ; exit 1 ; fi

# Allow any user to run sudo
bash -c "echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"

# Turn off Swapping
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

# Check Power Supply
apt-get install sysbench
https://gist.githubusercontent.com/maxme/d5f000c84a4313aa531288c35c3a8887/raw/fc355cd96e5e18e69df06ee4c34f50b7cd9a4a2a/raspberry-power-supply-check.sh
./raspberry-power-supply-check.sh

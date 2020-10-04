#!/bin/bash

# Check if we are running as the root user
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root - exiting" ; exit 1 ; fi

# Check if this is a Raspberry Pi
if ( ! cat /proc/cpuinfo | grep Model | grep "Raspberry" ) > /dev/null ; then echo "This is not a Raspiberry Pi - exiting" ; exit 1 ; fi

# Enable sudo for all users
if ! (sudo id | grep -q root) ; then 
    bash -c "echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
fi

# Turn off Swapping
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

# Unattended Upgrades
sudo apt-get install unattended-upgrades
sudo unattended-upgrade -d -v --dry-run
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Check Power Supply
apt-get install -y sysbench
wget https://gist.githubusercontent.com/maxme/d5f000c84a4313aa531288c35c3a8887/raw/fc355cd96e5e18e69df06ee4c34f50b7cd9a4a2a/raspberry-power-supply-check.sh
chmod +x raspberry-power-supply-check.sh
./raspberry-power-supply-check.sh

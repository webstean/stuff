#!/bin/bash

# Check if we are running as the root user
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root - exiting" ; exit 1 ; fi

# Check if this is a Raspberry Pi
if ( ! cat /proc/cpuinfo | grep Model | grep "Raspberry" ) > /dev/null ; then echo "This is not a Raspiberry Pi - exiting" ; exit 1 ; fi

# Enable sudo for users member of sudo group
if ! (sudo id | grep -q root) ; then 
    bash -c "echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
fi

# Install some essentials
sudo apt-get install ufw dos2unix vim

# Firewall
sudo ufw status verbose
# sudo ufw enable
# sudo ufw status
### Note: ufw won't be enabled until you enabled it

# Turn off Swapping
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo systemctl disable dphys-swapfile

# Setup some basic dev stuff
sudo apt-get install -y git curl
git config --global color.ui true
git config --global user.name "Andrew Webster"
git config --global user.email "webstean@gmail.com"
git config --list

# Move Pi log to RAM
if [ ! -d ~/log2ram ]; then
    git clone https://github.com/azlux/log2ram.git ~/log2ram
    chmod +x ~/log2ram/install.sh
    pushd ~/log2ram && sudo ./install.sh && popd
fi

# Latest update
sudo apt update && sudo apt full-upgrade
sudo rpi-eeprom-update -d -a

# Unattended Upgrades
sudo apt-get install -y unattended-upgrades
sudo unattended-upgrade -d -v --dry-run
sudo dpkg-reconfigure --priority=low unattended-upgrades

exit 0

# 3CX Session Border Controller
# wget https://downloads-global.3cx.com/downloads/misc/d10pi.zip; sudo bash d10pi.zip .

# Check Power Supply
sudo apt-get install -y sysbench
wget https://gist.githubusercontent.com/maxme/d5f000c84a4313aa531288c35c3a8887/raw/fc355cd96e5e18e69df06ee4c34f50b7cd9a4a2a/raspberry-power-supply-check.sh
chmod +x raspberry-power-supply-check.sh
# sudo ./raspberry-power-supply-check.sh

# Enable Linux features for Docker
if ! (grep "cgroup_enable=memory cgroup_memory=1 swapaccount=1" /boot/cmdline.txt ) ; then
    bash -c "echo -n 'cgroup_enable=memory cgroup_memory=1 swapaccount=1' >>/boot/cmdline.txt"
    sed '${s/$/cgroup_enable=memory cgroup_memory=1 swapaccount=1/}' /boot/cmdline.txt >/boot/cmdline.txt
fi

# Install IOTstack
sudo bash -c '[ $(egrep -c "^allowinterfaces eth0,wlan0" /etc/dhcpcd.conf) -eq 0 ] && echo "allowinterfaces eth0,wlan0" >> /etc/dhcpcd.conf'
sudo apt install -y git curl
# Install docker for $USER (usually pi user)
git clone https://github.com/SensorsIot/IOTstack.git ~/IOTstack 
curl -fsSL https://get.docker.com | sh
sudo usermod -G docker -a $USER
sudo usermod -G bluetooth -a $USER
sudo apt install -y python3-pip python3-dev
sudo pip3 install -U docker-compose
sudo pip3 install -U ruamel.yaml==0.16.12 blessed

exit 0

sudo reboot
cd ~/IOTstack
./menu.sh
docker-compose up -d

exit 0

# Get Docker
sudo apt-get install -y apt-transport-https ca-certificates software-properties-common git curl
sudo curl -fsSL get.docker.com -o get-docker.sh && sudo sh get-docker.sh
sudo usermod -aG docker pi
sudo curl https://download.docker.com/linux/raspbian/gpg
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo docker run hello-world
sudo docker images hello-world

# Get IOTstack
if [ ! -d ~/IOTstack ]; then
    git clone https://github.com/SensorsIot/IOTstack.git IOTstack
    cd ~/IOTstack
    git pull origin master
    git checkout master
    ### git checkout experimental
    docker-compose down
    ./menu.sh
    docker-compose up -d
    cd ..
    ## to remove
    # cd ~/IOTstack
    # sudo git clean -d -x -f
fi


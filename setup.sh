#!/bin/bash

# Setup Linux for Visual Studio Code

# for convenience
# Edit /etc/sudoes and amend:-
# Allow members of group sudo to execute any command
echo %sudo   ALL=(ALL:ALL) NOPASSWD:ALL
echo needs to be added to /etc/sudoers file to avoid the password prompts
echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

:# Update apt
if [ -f /usr/bin/apt ] ; then
    sudo apt-get update 
    sudo apt-get -y upgrade
    export INSTALL_CMD=sudo apt-get install -y
fi

# Update yum
if [ -f /usr/bin/yum ] ; then  
    sudo yum -y update
    sudo yum -y upgrade
    export INSTALL_CMD=yum install -y
fi

# Build System Support 
sudo apt-get -y install build-essential git wget curl unzip dos2unix htop

# Python - just incase
sudo apt-get -y install python

# Ensure git is install
sudo apt-get -y install git
git config --global color.ui true
git config --global user.name "Andrew Webster"
git config --global user.email "webstean@gmail.com"
cat /dev/zero | ssh-keygen -q -N "" -C "webstean@gmail.com"

# *DATABASE* SQL Lite
sudo apt-get install sqlite3
sqlite3 --version
# create database
# sqlite test.db

# sqlite3 is the cli
# sudo apt-get install sqlitebrowser
# but it needs XWindows

# *DATABASE* Postgres
sudo apt-get install -y postgresql postgresql-contrib
# To start Postgress
# sudo -u postgres pg_ctlcluster 11 main start

# Ruby on Rails
sudo apt-get install -y git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev 
sudo apt-get install -y libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev 
sudo apt-get install -y software-properties-common libffi-dev nodejs yarn

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

rbenv install 2.7.1
rbenv global 2.7.1
ruby -v

gem install bundler
rbenv rehash

# WSL Distribution Switcher
# needs to run from Windows
git pull https://github.com/RoliSoft/WSL-Distribution-Switcher ~/git/WSL-Distribution-Switcher
~/git/WSL-Distribution-Switcher/get-prebuilt.py debian
~/git/WSL-Distribution-Switcher/get-prebuilt.py alphine
~/git/WSL-Distribution-Switcher/get-prebuilt.py oraclelinux

# Add SSL support for APT repositories (required for Docker)
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

# Docker 
# cleanup
sudo apt-get purge docker lxc-docker docker-engine docker.io
# add key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg > ~/aw.txt
sudo apt-key add ~/aw.txt
if [ -f /usr/bin/apt ] ; then
    # add apt repository for docker
    sudo apt-get -y install software-properties-common
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is) $(lsb_release -cs) stable" 
fi
# install docker
dbus_status=$(service dbus status)
# satisfy the many applications which depend on dbus to function:
if [[ $dbus_status = *"is not running"* ]]; then
          sudo service dbus --full-restart
fi
echo $dbus_status
sudo apt-get -y install docker docker.io

# Audio Support
apt-get -y install libasound2-dev libasound2 libasound2-data module-init-tools libsndfile1-dev
sudo modprobe snd-dummy
sudo modprobe snd-aloop
# need more - to hear sound under WSL you need the pulse daemon running (on Windows)

# Install Go Language Support
sudo apt-get -y install curl
cd ~
curl -O https://storage.googleapis.com/golang/getgo/installer_linux
chmod 700 installer_linux
./installer_linux
sudo mv .go /usr/local/go
echo 'export GOPATH=/usr/local/go' >> ~/.bashrc
echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
exec $SHELL

# Install Linux Debugger - gdb - VS Code needs delv for Go as the debugger
sudo apt-get -y install gdb

# Install Go Language Debugger (Delve)
# need git installed first
go get github.com/go-delve/delve/cmd/dlv
# should put in the right place as GOPATH should now be correct
# sudo mv ~/go/bin/dlv /usr/local/go/bin
# sudo cp -r ~/go/src /usr/local/go/src

# Install some Reference GIT Repos
mkdir ~/git
# An example of multi-repository C project
sudo apt-get -y install pkg-config alsa-utils libasound2-dev
git clone https://github.com/alfredh/baresip ~/git/baresip
git clone https://github.com/creytiv/re ~/git/re
git clone https://github.com/creytiv/rem  ~/git/rem
# Install Libre
cd ~/git/re && make && sudo make install && sudo ldconfig
# Install Librem
cd ~/git/rem && make && sudo make install && sudo ldconfig
# Install baresip
cd ~/git/baresip && make && sudo make install && sudo ldconfig
# Test Baresip to initialize default config and Exit
baresip -t -f $HOME/.baresip
# Install Configuration from baresip-docker
git clone https://github.com/QXIP/baresip-docker.git ~/git/baresip-docker
cp -R ~/git/baresip-docker $HOME/.baresip
cp -R ~/git/baresip-docker/.asoundrc $HOME
# Run Baresip set the SIP account
#CMD baresip -d -f $HOME/.baresip && sleep 2 && curl http://127.0.0.1:8000/raw/?Rsip:root:root@127.0.0.1 && sleep 5 && curl http://127.0.0.1:8000/raw/?dbaresip@conference.sip2sip.info && sleep 60 && curl http://127.0.0.1:8000/raw/?bq

# Install vcpkg
# vcpkg helps you manage C and C++ libraries on Windows, Linux and MacOS
git clone https://github.com/Microsoft/vcpkg.git ~/git/vcpkg
~/git/vcpkg/bootstrap-vcpkg.sh
~/git/vcpkg/vcpkg integrate install
~/git/vcpkg/vcpkg integrate bash
exec $SHELL

# DATABASE clients

# Oracle

# SQL Server


# apt clean  up
if [ -f /usr/bin/apt ] ; then
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
fi


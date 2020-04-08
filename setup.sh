#!/bin/bash

# Setup Linux for Visual Studio Code

# Set software versions to install
ENV WEB http://www.creytiv.com/pub
ENV LIBRE re-0.4.17 
ENV LIBREM rem-0.4.7 
ENV BARESIP baresip-0.4.20
ENV BARESIPGIT # https://github.com/alfredh/baresip.git

# Update Apt
sudo apt-get update 
sudo apt-get -y upgrade

# Build System Support 
sudo apt-get -y install build-essential git wget curl unzip dos2unix

# Python
sudo apt-get -y install python

# Ensure git is install
sudo apt-get -y install git
git config --global color.ui true
git config --global user.name "Andrew Webster"
git config --global user.email "webstean@gmail.com"
cat /dev/zero | ssh-keygen -q -N "" -C "webstean@gmail.com"

# Postgres
sudo apt-get install postgresql postgresql-contrib
# need to create user

# Ruby on Rails
apt-get install -y git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev 
apt-get install -y libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev 
apt-get install -y software-properties-common libffi-dev nodejs yarn

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
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

# Docker 
# cleanup
sudo apt-get purge docker lxc-docker docker-engine docker.io
# add key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add –
# add repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable" 
# install docker
sudo apt-get install docker-ce

# Audio Support
apt-get -y install libasound2-dev libasound2 libasound2-data module-init-tools libsndfile1-dev
sudo modprobe snd-dummy
sudo modprobe snd-aloop
# need more - to hear sound under WSL you need the pulse daemon running (on Windows)

# Install Go Language Support
cd ~
curl -O https://storage.googleapis.com/golang/getgo/installer_linux
chmod 700 installer_linux
./installer_linux
sudo mv .go /usr/local/go
# Install Go Language Debugger (Delve)
go get github.com/go-delve/delve/cmd/dlv

# Install some GIT Repos
mkdir ~/git
# An example of multi-repository C project
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

# Install vcpkg
# Vcpkg helps you manage C and C++ libraries on Windows, Linux and MacOS
git clone https://github.com/Microsoft/vcpkg.git ~/git/vcpkg
~/git/vcpkg/bootstrap-vcpkg.sh
~/git/vcpkg/vcpkg integrate install
~/git/vcpkg/vcpkg integrate bash

# Install Debugger (C++) - gdb
sudo apt-get -y install gdb

# apt clean  up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Default Baresip run command arguments
CMD ["baresip", "-d","-f","/root/.baresip"]
#CMD baresip -d -f $HOME/.baresip && sleep 2 && curl http://127.0.0.1:8000/raw/?Rsip:root:root@127.0.0.1 && sleep 5 && curl http://127.0.0.1:8000/raw/?dbaresip@conference.sip2sip.info && sleep 60 && curl http://127.0.0.1:8000/raw/?bq

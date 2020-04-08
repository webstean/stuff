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
    export INSTALL_CMD=sudo yum install -y
fi

# Develpoer Build System Support 
$INSTALL_CMD build-essential git wget curl unzip dos2unix htop libcurl3

# Python - just incase
$INSTALL_CMD python

# Ensure git is install and configure it 
$INSTALL_CMD git
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
$INSTALL_CMD apt-transport-https ca-certificates curl software-properties-common

# Docker 
# cleanup
sudo apt-get purge docker lxc-docker docker-engine docker.io
# add key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg > ~/aw.txt
sudo apt-key add ~/aw.txt
if [ -f /usr/bin/apt ] ; then
    # add apt repository for docker
    $INSTALL_CMD software-properties-common
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is) $(lsb_release -cs) stable" 
    # got with stable
    # sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is) $(lsb_release -cs) edge"
    # sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is) $(lsb_release -cs) nightly"
fi
# install docker
dbus_status=$(service dbus status)
# Ensure dbus is running:
if [[ $dbus_status = *"is not running"* ]]; then
          sudo service dbus --full-restart
fi
echo $dbus_status
$INSTALL_CMD docker docker.io

# Linux (ALSA) Audio Support
$INSTALL_CMD libasound2-dev libasound2 libasound2-data module-init-tools libsndfile1-dev
sudo modprobe snd-dummy
sudo modprobe snd-aloop
# need more - to hear sound under WSL you need the pulse daemon running (on Windows)

# Install Go Language (golang) Support
$INSTALL_CMD curl
cd ~
curl -O https://storage.googleapis.com/golang/getgo/installer_linux
chmod 700 installer_linux
./installer_linux
sudo mv .go /usr/local/go
echo 'export GOHOME=$HOME/go '>> ~/.bashrc
mkdir $HOME/go
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
exec $SHELL

# Install Oracle Database Instant Client via permanent OTN link
cd ~
# Permanent Link (latest version) - Instant Client - Basic (x86 64 bit) - you need this for anything else to work
# Note: there is no Instant Client for the ARM processor, Intel/AMD x86 only
wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip
unzip instantclient-basic*.zip
rm instantclient-basic*.zip
set -- $(pwd)/instantclient-basic*
export LD_LIBRARY_PATH=$1
echo export LD_LIBRARY_PATH=$LD_LIBRARY_PATH/ >> ~/.bashrc
echo export PATH="$LD_LIBRARY_PATH:\$PATH" >> ~/.bashrc

# Permanent Link (latest version) - Instant Client - SQLplus (x86 64 bit) - addon (tiny - why not)
wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip
unzip instantclient-sqlplus*.zip

# Permanent Link (latest version) - Instant Client - Tools (x86 64 bit) - addons incl Data Pump
wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-tools-linuxx64.zip
unzip instantclient-tools*.zip
rm instantclient-tools*.zip

# With the normal Oracle Client, oraenv script sets the ORACLE_HOME, ORACLE_BASE and LD_LIBRARY_PATH variables and
# updates the PATH variable for Oracle
# But, with the Instant Client you only need the LD_LIBRARY_PATH set. And BTW: The Instant Client cannot be patched (reinstall a newer version)
# Add LD_LIBRARY_PATH to the sudoers env_keep parameter so other accounts will work, like cron scripts or add to /etc/profile.d

# Eg. $ sqlplus scott/tiger@//myhost.example.com:1521/myservice

# Install Microsoft SQL Server 2019 Client and optionally Server
if [ -f /usr/bin/apt ] ; then
    # prereq
    $INSTALL_CMD libcurl3
    $INSTALL_CMD curl
    #
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
    sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
    sudo apt-get update
    # Client
    sudo ACCEPT_EULA=Y apt-get install -y msodbcsql mssql-tools unixodbc-dev
    if [ -d /opt/mssql-tools/bin/ ] ; then  
        echo "# Microsoft SQL Server Tools..." >> ~/.bashrc
        echo 'export PATH="/opt/ssql-tools/bin:$PATH"' >> ~/.bashrc
        # sqlcmd -S localhost -U SA -P '<YourPassword>'
    fi
    # Server (it's big)
    # sudo ACCEPT_EULA=Y apt-get install -y mssql-server
    # FYI: SQL Server for Linux listens on TCP port for connections (by default port 1433)
    systemctl status mssql-server --no-pager
fi

if [ -f /usr/bin/yum ] ; then
    # Damn Microsoft - the http is case senstive the repository is redhat instead Redhat that we get from lsb_release
    sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/$(lsb_release -si)/$(lsb_release -sr)/mssql-server-2019.repo
    $INSTALL_CMD mssql-server
    systemctl status mssql-server --no-pager
fi

# run SQL Server setup - NEED TO CHECK OUT
if [ -x /opt/mssql/bin/mssql-conf ] ; then
    sudo /opt/mssql/bin/mssql-conf setup
fi

# Install Go Package for Oracle DB connections
# Needs Oracle instant client installed at run time
# 
go get github.com/mattn/go-oci8

# Install Go Language Debugger (Delve)
# go get needs git installed first
go get github.com/go-delve/delve/cmd/dlv
# should put in the right place as GOPATH should now be correct
# sudo mv ~/go/bin/dlv /usr/local/go/bin
# sudo cp -r ~/go/src /usr/local/go/src

# Install Linux Debugger - gdb - VS Code needs delv for Go as the debugger
$INSTALL_CMD gdb

# Install some Reference GIT Repos
mkdir ~/git
# An example of multi-repository C project
$INSTALL_CMD pkg-config alsa-utils libasound2-dev
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

# apt clean  up
if [ -f /usr/bin/apt ] ; then
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
fi


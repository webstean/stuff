#!/bin/bash

# Setup WSL Linux for use Visual Studio Code (VS Code)
# See: https://code.visualstudio.com/docs/remote/linux
# for VS Code to work remotely on a MAC
# See: https://support.apple.com/en-au/guide/mac-help/mchlp1066/mac

# Supported Distributions (WSL and remote)
# - Red Hat and deriatvies (Oracle & Centos)
# - Debian 
# - Ubuntu
# - Raspbian (Raspberry Pi)
# - Alpine - note, MS Code only has limited remoted support for Alpine

if [ -z "$SHELL" ] ; then
    export SHELL=/bin/sh
fi

# Alpine apt - sudo won't be there by default om Alpine
if [ -f /sbin/apk ] ; then  
    apk add sudo
fi

# for convenience
# Edit /etc/sudoes and amend:-
echo '%sudo   ALL=(ALL:ALL) NOPASSWD:ALL'
echo 'needs to be added to /etc/sudoers file to avoid the password prompts'
echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

# Proxy Support
# Squid default port is 3128, but many setup the proxy on port 80,8000,8080
# Unauthenticated
# sudo sh -c 'echo # {HTTP,HTTPS,FTP}_PROXY=http://proxy.support.com:port   >  /etc/profile.d/proxy.sh'
# 
# Authenticated
# sudo sh -c 'echo # {HTTP,HTTPS,FTP}_PROXY=http://proxy.support.com\\USERN\@ME:port   >  /etc/profile.d/proxy.sh'

# No Proxy - aka exceptions
# sudo sh -c 'echo # NO_PROXY=localhost,127.0.0.1,::1,10.0.0.0/8 >> /etc/profile.d/proxy.sh'

# Alpine
if [ -f /sbin/apk ] ; then  
    sudo apk update
    sudo apk upgrade
    sudo apk upgrade --available
    export INSTALL_CMD="sudo apk add --no-cache --force-broken-world"
fi

# Debian, Ubuntu apt
if [ -f /usr/bin/apt ] ; then
    sudo apt-get update 
    sudo apt-get -y upgrade
    export INSTALL_CMD="sudo apt-get install -y"
fi

# Centos, RedHat, OraclieLinux yum
if [ -f /usr/bin/yum ] ; then  
    sudo yum -y update
    sudo yum -y upgrade
    export INSTALL_CMD="sudo yum install -y"
fi

# Developer Build System Support 
$INSTALL_CMD vim tzdata openssh-server
$INSTALL_CMD build-essential git wget curl unzip dos2unix htop libcurl3

# Firewall Rules for SSH Server
ufw allow ssh

# Install Python
$INSTALL_CMD python
$INSTALL_CMD python-dev py-pip build-base 

# Ensure git is install and then configure it 
$INSTALL_CMD git
git config --global color.ui true
git config --global user.name "Andrew Webster"
git config --global user.email "webstean@gmail.com"
git config --list

# Generate an SSH
$INSTALL_CMD openssh-client
cat /dev/zero | ssh-keygen -q -N "" -C "webstean@gmail.com"

# *DATABASE* SQL Lite
$INSTALL_CMD sqlite3 libsqlite3-dev
if [ -f /sbin/apk ] ; then  
    $INSTALL_CMD sqlite libsqlite-dev
fi
sqlite3 --version
# create database
# sqlite test.db

# sqlite3 is the cli
# sudo apt-get install sqlitebrowser
# but it needs XWindows

# *DATABASE* Postgres
$INSTALL_CMD postgresql postgresql-contrib
# To start Postgress
# sudo -u postgres pg_ctlcluster 11 main start

# Ruby on Rails
$INSTALL_CMD git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev 
$INSTALL_CMD libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev 
$INSTALL_CMD software-properties-common libffi-dev nodejs yarn

# sudo git clone https://github.com/rbenv/rbenv.git /opt/rbenv
# sudo sh -c 'echo export PATH=/opt/rbenv:\$PATH >  /etc/profile.d/ruby.sh'
# sudo sh -c 'echo eval "$(rbenv init -)"        >> /etc/profile.d/ruby.sh'
# exec "$SHELL"

# sudo git clone https://github.com/rbenv/ruby-build.git /opt/rbenv/plugins/ruby-build
# sudo sh -c 'echo export PATH="/opt/rbenv/plugins/ruby-build/bin:\$PATH" >> /etc/profile.d/ruby.sh'
# exec "$SHELL"

# apt install rbenv

# rbenv install 2.7.1
# rbenv global 2.7.1
# ruby -v

# gem install bundler
# rbenv rehash

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
# Turn on Docker Build kit
sudo sh -c 'echo export DOCKER_BUILDKIT="1" >> /etc/profile.d/ruby.sh'

# Linux (ALSA) Audio Support
$INSTALL_CMD libasound2-dev libasound2 libasound2-data module-init-tools libsndfile1-dev
sudo modprobe snd-dummy
sudo modprobe snd-aloop
# need more - to hear sound under WSL you need the pulse daemon running (on Windows)

# Dependencies for Oracle Client
$INSTALL_CMD libaio unzip

# Alpine
$INSTALL_CMD musl-dev libaio-dev libnsl-dev
sudo ldconfig

# Install Oracle Database Instant Client via permanent OTN link
# Permanent Link (latest version) - Instant Client - Basic (x86 64 bit) - you need this for anything else to work
# Note: there is no Instant Client for the ARM processor, Intel/AMD x86 only
tmpdir=$(mktemp -d)
wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip -nc -O $tmpdir
sudo mkdir -p /opt/oracle
sudo unzip $tmpdir/instantclient-basic*.zip -d /opt/oracle
sudo chmod 755 /opt
sudo chmod 755 /opt/oracle

# rm instantclient-basic*.zip
set -- /opt/oracle/instantclient*
export LD_LIBRARY_PATH=$1
sudo sh -c "echo export LD_LIBRARY_PATH=$1  >  /etc/profile.d/oracle.sh"
sudo sh -c "echo export PATH=$1:'\$PATH'    >> /etc/profile.d/oracle.sh"

# Permanent Link (latest version) - Instant Client - SQLplus (x86 64 bit) - addon (tiny - why not)
wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip -nc -O $tmpdir
sudo unzip $tmpdir/instantclient-sqlplus*.zip -d $LD_LIBRARY_PATH/..
# rm instantclient-sqlplus*.zip

# Permanent Link (latest version) - Instant Client - Tools (x86 64 bit) - addons incl Data Pump
wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-tools-linuxx64.zip -nc -O $tmpdir
sudo unzip $tmpdir/instantclient-tools*.zip -d $LD_LIBRARY_PATH/..
# rm instantclient-tools*.zip

# With the normal Oracle Client, oraenv script sets the ORACLE_HOME, ORACLE_BASE and LD_LIBRARY_PATH variables and
# updates the PATH variable for Oracle
# But, with the Instant Client you only need the LD_LIBRARY_PATH set. And BTW: The Instant Client cannot be patched (reinstall a newer version)

# Eg. $ sqlplus scott/tiger@//myhost.example.com:1521/myservice

# Alpine Libraries for Oracle client
if [ -f /sbin/apk ] ; then
    # enable Edge repositories - hoepfully this will go away eventually
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    apk update
    $INSTALL_CMD libnsl libaio musl-dev autconfig
fi

# Install Microsoft SQL Server 2019 Client and optionally SQL Server
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
    
    # Server (it's big)
    # sudo ACCEPT_EULA=Y apt-get install -y mssql-server
    # FYI: SQL Server for Linux listens on TCP port for connections (by default port TCP 1433)
    systemctl status mssql-server --no-pager
fi

if [ -f /usr/bin/yum ] ; then
    # Damn Microsoft - the http is case senstive the repository is redhat instead Redhat that we get from lsb_release
    sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/$(lsb_release -si)/$(lsb_release -sr)/mssql-server-2019.repo
    $INSTALL_CMD mssql-server
    systemctl status mssql-server --no-pager
fi

if [ -d /opt/mssql-tools/bin/ ] ; then  
        sudo sh -c 'echo export PATH="/opt/ssql-tools/bin:$PATH"  > /etc/profile.d/mssql.sh'
        # sqlcmd -S localhost -U SA -P '<YourPassword>'
fi

# run SQL Server setup - NEED TO CHECK OUT
if [ -x /opt/mssql/bin/mssql-conf ] ; then
    /opt/mssql/bin/mssql-conf setup
fi

# Install Go Language (golang) Support
$INSTALL_CMD curl
cd ~
curl -O https://storage.googleapis.com/golang/getgo/installer_linux
chmod 700 installer_linux
./installer_linux
sudo mv .go /usr/local/go
sudo sh -c 'echo export GOHOME=\$HOME/go                  >  /etc/profile.d/golang.sh'
mkdir $HOME/go
sudo sh -c 'echo export GOROOT=/usr/local/go              >> /etc/profile.d/golang.sh'
sudo sh -c 'echo export PATH="/usr/local/go/bin:\$PATH"   >> /etc/profile.d/golang.sh'
exec "$SHELL"

# Install Go Package for Oracle DB connections
# Needs Oracle instant client installed at run time
go get github.com/mattn/go-sqlite3
sudo sh -c 'echo export CGO_ENABLED="1"                   >> /etc/profile.d/golang.sh'

# Install Go Language Debugger (Delve)
# go get needs git installed first
go get github.com/go-delve/delve/cmd/dlv

# Install Go Methods for SQL Lite
go get github.com/mattn/go-sqlite3

# Install Linux Debugger - gdb - VS Code needs delv for Go as the debugger
$INSTALL_CMD gdb

# Install some Reference GIT Repos
mkdir ~/git
git clone https://github.com/oracle/docker-images ~/git/oracle-docker-images
# An example of multi-repository C project that is updated regularly
$INSTALL_CMD pkg-config alsa-utils libasound2-dev
# Gstreamer bits, so the baresip gstreamer module will be built
$INSTALL_CMD gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-x 
$INSTALL_CMD libgstreamer-plugins-base1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev
git clone https://github.com/alfredh/baresip ~/git/baresip
git clone https://github.com/creytiv/re ~/git/re
git clone https://github.com/creytiv/rem  ~/git/rem
git clone https://github.com/openssl/openssl ~/git/openssl

# Install & Build Libre
cd ~/git/re && make && sudo make install && sudo ldconfig
# Install & Build Librem
cd ~/git/rem && make && sudo make install && sudo ldconfig
# Build baresip
cd ~/git/baresip && make RELEASE=1 && sudo make RELEASE=1 install && sudo ldconfig
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

# Join an on-premise Active Directory domain
# Ubuntu
# sudo apt-get install krb5-user samba sssd sssd-tools libnss-sss libpam-sss ntp ntpdate realmd adcli
# Centos/ReadHat/Oracle
#sudo yum install -y realmd sssd krb5-workstation krb5-libs oddjob oddjob-mkhomedir samba-common-tools
# ensure NTP is running and time is correct
# Domain name needs to be upper case
#AD_DOMAIN=AADDSCONTOSO.COM
#AD_USER=webstean@$AD_DOMAIN
#sudo realm discover $AD_DOMAIN && kinit contosoadmin@$AD_DOMAIN && sudo realm join --verbose $AD_DOMAIN -U '$AD_USER' --install=/

# Install AWS CLI
cd ~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ~/./aws/install
/usr/local/bin/aws --version

# apt clean  up
if [ -f /usr/bin/apt ] ; then
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
fi

# yum clean  up
if [ -f /usr/bin/yum ] ; then
    yum clean all && rm -rf /tmp/* /var/tmp/*
fi

# yum clean  up
if [ -f /sbin/apk ] ; then
    apk cache clean
fi

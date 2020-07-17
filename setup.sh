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

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

if [ -z "$SHELL" ] ; then
    export SHELL=/bin/sh
fi

# Alpine apt - sudo won't be there by default om Alpine
if [ -f /sbin/apk ] ; then  
    apk add sudo
fi

sudo bash -c "echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"

# Proxy Support

# Squid default port is 3128, but many setup the proxy on port 80,8000,8080
# Authenticated
# USERN=UserName
# @ME=Password
# sudo sh -c 'echo # {HTTP,HTTPS,FTP}_PROXY=http://proxy.support.com\\USERN\@ME:port   >  /etc/profile.d/proxy.sh'

# Unauthenticated
# sudo sh -c 'echo # {HTTP,HTTPS,FTP}_PROXY=http://proxy.support.com:port   >  /etc/profile.d/proxy.sh'
# 
# Proxy exceptions
# sudo sh -c 'echo # NO_PROXY=localhost,127.0.0.1,::1,10.0.0.0/8 >> /etc/profile.d/proxy.sh'

# Ensure git is install and then configure it 
$INSTALL_CMD git
git config --global color.ui true
git config --global user.name "Andrew Webster"
git config --global user.email "webstean@gmail.com"
git config --list

# Generate an SSH
$INSTALL_CMD openssh-client
cat /dev/zero | ssh-keygen -q -N "" -C "webstean@gmail.com"

# Install some Reference GIT Repos
mkdir ~/git
git clone https://github.com/oracle/docker-images ~/git/oracle-docker-images
# An example of multi-repository C project that is updated regularly
$INSTALL_CMD pkg-config alsa-utils libasound2-dev
# Gstreamer bits, so the baresip gstreamer module will be built
$INSTALL_CMD gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-x 
$INSTALL_CMD libgstreamer-plugins-base1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev
git clone https://github.com/baresip/baresip ~/git/baresip
git clone https://github.com/baresip/re ~/git/re
git clone https://github.com/creytiv/rem  ~/git/rem
git clone https://github.com/openssl/openssl ~/git/openssl
# Install & Build Libre
cd ~/git/openssl && make && sudo make install && sudo ldconfig
# Install & Build Libre
cd ~/git/re && make RELEASE=1 && sudo make RELEASE=1 install && sudo ldconfig
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

# Install FZF (fuzzy finder on the terminal and used by a Vim plugin).
git clone --depth 1 https://github.com/junegunn/fzf.git ~/git/fzf 
~/git/fzf/install

# Install ASDF (version manager for non-Dockerized apps).
git clone https://github.com/asdf-vm/asdf.git ~/git/asdf --branch v0.7.8

# Install Node through ASDF.
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs 12.17.0
asdf global nodejs 12.17.0

# Install Ruby through ASDF.
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 2.7.1
asdf global ruby 2.7.1


# Install Ansible.
pip3 install --user ansible

# Install Terraform.
# curl "https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip" -o "terraform.zip" \
#  && unzip terraform.zip && chmod +x terraform \
#  && sudo mv terraform ~/.local/bin && rm terraform.zip

# Firewall Rules for SSH Server
ufw allow ssh

# Install Python
$INSTALL_CMD python
$INSTALL_CMD python-dev py-pip build-base 

# *DATABASE* SQL Lite
$INSTALL_CMD sqlite3 libsqlite3-dev
if [ -f /sbin/apk ] ; then  
    $INSTALL_CMD sqlite libsqlite-dev
fi
# create database
# sqlite test.db

# sqlite3 is the cli, sqlitebrowser is the GUI
# but needs XWindows
# $INSTALL_CMD sqlitebrowser

# Ruby on Rails
#$INSTALL_CMD git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev 
#$INSTALL_CMD libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev 
#$INSTALL_CMD software-properties-common libffi-dev nodejs yarn

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

# Docker 
# Add SSL support for APT repositories (required for Docker)
$INSTALL_CMD apt-transport-https ca-certificates curl software-properties-common
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

# Alpine
$INSTALL_CMD musl-dev libaio-dev libnsl-dev
sudo ldconfig

# Install Oracle Database Instant Client via permanent OTN link
# Dependencies for Oracle Client
$INSTALL_CMD libaio unzip
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

# Install Microsoft SQL Server Client
if [ -f /usr/bin/apt ] ; then
    # Import the public repository GPG keys
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

    # Register the Microsoft Ubuntu repository
    echo sudo apt-add-repository https://packages.microsoft.com/ubuntu/$(lsb_release -sr)/prod

    # Update the list of products
    sudo apt-get update

    # Install mssql-cli
    sudo apt-get install mssql-cli

    # Install missing dependencies
    sudo apt-get install -f
fi

if [ -d /opt/mssql-tools/bin/ ] ; then  
        sudo sh -c 'echo export PATH="/opt/ssql-tools/bin:$PATH"  > /etc/profile.d/mssql.sh'
        # sqlcmd -S localhost -U SA -P '<YourPassword>'
fi

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

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Azure Arc Agent - Download the installation package.
# wget https://aka.ms/azcmagent -O ~/Install_linux_azcmagent.sh

# Azure Arc Agent - Install the connected machine agent. 
# bash ~/Install_linux_azcmagent.sh

# azcmagent connect --resource-group "<resourceGroupName>" --tenant-id "<tenantID>" --location "<regionName>" --subscription-id "<subscriptionID>"

sudo bash -c 'cat << EOF > /etc/profile.d/display.sh
# WSL 1 - Easy 
if grep -qE "(Microsoft|WSL)" /proc/version &>/dev/null; then
    if [ "$(umask)" = "0000" ]; then
        umask 0022
    fi
    export DISPLAY=:0
fi
# WSL 2 - Complicated during to Virtual Network
if grep -q "microsoft" /proc/version &>/dev/null; then
    # Requires: https://sourceforge.net/projects/vcxsrv/ (or alternative)
    export DISPLAY=\$(ip route list | sed -n -e "s/^default.*[[:space:]]\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\).*/\1/p"):0
fi
EOF'

sudo sh -c 'echo "# Ensure \$LINES and \$COLUMNS always get updated."  >  /etc/profile.d/bash.sh'
sudo sh -c 'echo shopt -s checkwinsize                                 >>  /etc/profile.d/bash.sh'

sudo sh -c 'echo "# Limit number of lines and entries in the history." >>  /etc/profile.d/bash.sh'
sudo sh -c 'echo export HISTFILESIZE=50000                             >>  /etc/profile.d/bash.sh'
sudo sh -c 'echo export HISTSIZE=50000                                 >>  /etc/profile.d/bash.sh'

sudo sh -c 'echo "# Add a timestamp to each command."                  >>  /etc/profile.d/bash.sh'
sudo sh -c 'echo export HISTTIMEFORMAT=\"%Y/%m/%d %H:%M:%S:\"          >>  /etc/profile.d/bash.sh'

sudo sh -c 'echo "# Duplicate lines and lines starting with a space are not put into the history." >>  /etc/profile.d/bash.sh'
sudo sh -c 'echo export HISTCONTROL=ignoreboth                         >>  /etc/profile.d/bash.sh'

sudo sh -c 'echo "# Append to the history file, dont overwrite it."    >>  /etc/profile.d/bash.sh'
sudo sh -c 'echo shopt -s histappend                                   >>  /etc/profile.d/bash.sh'

sudo sh -c 'echo "# Enable bash completion."                           >>  /etc/profile.d/bash.sh'
sudo sh -c "echo [ -f /etc/bash_completion ] && . /etc/bash_completion >>  /etc/profile.d/bash.sh"

sudo sh -c 'echo "# Improve output of less for binary files."          >> /etc/profile.d/bash.sh'
sudo sh -c 'echo [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"   >>  /etc/profile.d/bash.sh'

# configure WSL
sudo sh -c 'echo [automount]             >   /etc/wsl.conf'
sudo sh -c 'echo root = /                >>  /etc/wsl.conf'
sudo sh -c 'echo options = "metadata"    >>  /etc/wsl.conf'

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

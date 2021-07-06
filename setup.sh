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

# Alpine apt - sudo won't be there by default on Alpine
if [ -f /sbin/apk ] ; then  
    apk add sudo
fi

# Enable sudo for all users
if ! (sudo id | grep -q root) ; then 
    bash -c "echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
fi

# Proxy Support

# Environent Variables
#set HTTP_PROXY=http://192.168.1.4:3128
#set HTTPS_PROXY=http://192.168.1.4:3128
#set NO_PROXY=localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8

# 
# Proxy exceptions
# sudo sh -c 'echo # NO_PROXY=localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8 >> /etc/profile.d/proxy.sh'


# Squid default port is 3128, but many setup the proxy on port 80,8000,8080
# Authenticated
# USERN=UserName
# @ME=Password
# sudo sh -c 'echo # {HTTP,HTTPS,FTP}_PROXY=http://proxy.support.com\\USERN\@ME:port   >  /etc/profile.d/proxy.sh'

# Unauthenticated
# sudo sh -c 'echo # {HTTP,HTTPS,FTP}_PROXY=http://proxy.support.com:port   >  /etc/profile.d/proxy.sh'
# 
# Proxy exceptions
# sudo sh -c 'echo # NO_PROXY=localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8 >> /etc/profile.d/proxy.sh'

# Set Timezone
sudo timedatectl set-timezone Australia/Melbourne
timedatectl

# Set Locale
sudo update-locale LANG=en_AU.UTF-8 LANGUAGE= LC_MESSAGES= LC_COLLATE= LC_CTYPE=
# need reboot to show up properly - it will update /etc/default/locale

# Ensure git is install and then configure it 
${INSTALL_CMD} git
git config --global color.ui true
git config --global user.name "Andrew Webster"
git config --global user.email "webstean@gmail.com"
# cached credentials for 4 hours
git config --global credential.help cache =timeout=14400 
git config --list

# Generate an SSH Certificate
${INSTALL_CMD} openssh-client
cat /dev/zero | ssh-keygen -q -N "" -C "webstean@gmail.com"

# Install dependencies for reference GIT Repos
mkdir ~/git
git clone https://github.com/oracle/docker-images ~/git/oracle-docker-images

# BARESIP: An example of multi-repository C project that is updated regularly
${INSTALL_CMD} pkg-config alsa-utils libasound2-dev libpulse-dev
${INSTALL_CMD} gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-x 
${INSTALL_CMD} libgstreamer-plugins-base1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev
${INSTALL_CMD} build-essential pkg-config intltool libtool libsndfile1-dev libjson-c-dev libopus-dev
${INSTALL_CMD} libsndfile1-dev libspandsp-dev libgtk2.0-dev libjack-jackd2-dev

# Grep for SIP Network Sessions
${INSTALL_CMD} sngrep
# Video Codecs
${INSTALL_CMD} libavcodec-dev libavutil-dev libcairo2-dev
# ${INSTALL_CMD} libavdevice-dev libavformat-dev mpg123-dev 

# Create an example certificate
openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /etc/ssl/certs/example.crt -keyout /etc/ssl/certs/example.key \
    -subj "/C=AU/ST=Victoria/L=Melbourne/O=webstean/OU=IT/CN=webstean.com"
cat /etc/ssl/certs/example.crt /etc/ssl/certs/example.key > /etc/ssl/certs/example.pem

mkdir -p /usr/local/src

git clone https://github.com/letsencrypt/letsencrypt /usr/local/src/letsencrypt

#./letsencrypt-auto --help
# sudo certbot certificates

#if [ -d /etc/apache2 ] ; then
#    sudo -H /usr/local/src/letsencrypt/letsencrypt-auto certonly --apache -d example.com -d www.example.com
#else
#    sudo -H /usr/local/src/letsencrypt/letsencrypt-auto certonly --standalone -d example.com -d www.example.com
#fi

# WILDCARD: This need a DNS record
# certbot certonly -d 'lordsomerscamp.org.au,*.lordsomercamp.org.au' --server https://acme-v02.api.letsencrypt.org/directory --preferred-challenges dns --agree-tos --email webstean@gmail.com

# WILDCARD: this need a file put on the web server 
# certbot certonly -d -d 'lordsomerscamp.org.au,*.lordsomercamp.org.au' --server https://acme-v02.api.letsencrypt.org/directory --agree-tos --email webstean@gmail.com

# test
# sudo certbot renew --dry-run

git clone https://github.com/openssl/openssl /usr/local/src/openssl
git clone https://github.com/baresip/re /usr/local/src/re
git clone https://github.com/creytiv/rem  /usr/local/src/rem
git clone https://github.com/baresip/baresip /usr/local/src/baresip
git clone https://github.com/juha-h/libzrtp /usr/local/src/git/libzrtp

# Install & Build libzrtp
cd /usr/local/src/libzrtp && ./bootstrap.sh && ./configure CFLAGS="-O0 -g3 -W -Wall -DBUILD_WITH_CFUNC -DBUILD_DEFAULT_CACHE -DBUILD_DEFAULT_TIMER" && make && sudo make install && sudo ldconfig
# Install & Build openssl
cd /usr/local/src/openssl && ./config && make && sudo make install && sudo ldconfig
# Install & Build re
# Build as Release (no SIP debugging)
# cd /usr/local/src/re && make RELEASE=1 && sudo make RELEASE=1 install && sudo ldconfig
# Build with debug enabled
cd /usr/local/src/re && sudo make install && sudo ldconfig
# Install & Build rem (Note: re is a dependency)
cd /usr/local/src/rem && sudo make install
# Build baresip
cd /usr/local/src/baresip && make RELEASE=1 EXTRA_MODULES=b2bua && sudo make RELEASE=1 EXTRA_MODULES=b2bua install
# ldconfig - just for kicks
sudo ldconfig

# Get some decent config files for baresip
curl https://raw.githubusercontent.com/webstean/stuff/master/baresip/accounts -o ~/.baresip/accounts
curl https://raw.githubusercontent.com/webstean/stuff/master/baresip/config -o ~/.baresip/config
curl https://raw.githubusercontent.com/webstean/stuff/master/baresip/contacts -o ~/.baresip/contacts
baresip -t 28

# Run Baresip set the SIP account
#CMD baresip -d -f $HOME/.baresip && sleep 2 && curl http://127.0.0.1:8000/raw/?Rsip:root:root@127.0.0.1 && sleep 5 && curl http://127.0.0.1:8000/raw/?dbaresip@conference.sip2sip.info && sleep 60 && curl http://127.0.0.1:8000/raw/?bq
# /uanew sip:12345@webstean.com:5060;auth_user=12345;auth_pass=ABC123

# Install FZF (fuzzy finder on the terminal and used by a Vim plugin).
git clone --depth 1 https://github.com/junegunn/fzf.git ~/git/fzf 
~/git/fzf/install

# Install Python
${INSTALL_CMD} python
${INSTALL_CMD} python-dev py-pip build-base 

# asdf prereqs
${INSTALL_CMD} dirmngr gpg curl
# Install ASDF (version manager for non-Dockerized apps).
mkdir -p ~/.asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout dirmngr "$(git describe --abbrev=0 --tags)"
chmod +x ~/.asdf/asdf.sh
source ~/.asdf/asdf.sh

# Install Node through ASDF.
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs latest
asdf global nodejs latest

# Install Ruby through ASDF.
#asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
#asdf install ruby 2.7.1
#asdf global ruby 2.7.1

# Install Ansible.
pip3 install --user ansible

# Install Terraform.
# curl "https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip" -o "terraform.zip" \
#  && unzip terraform.zip && chmod +x terraform \
#  && sudo mv terraform ~/.local/bin && rm terraform.zip

# Firewall Rules for SSH Server
ufw allow ssh

# *DATABASE* SQL Lite
${INSTALL_CMD} sqlite3 libsqlite3-dev
if [ -f /sbin/apk ] ; then  
    ${INSTALL_CMD} sqlite libsqlite-dev
fi
# create database
# sqlite test.db

# sqlite3 is the cli, sqlitebrowser is the GUI
# but needs XWindows
# ${INSTALL_CMD} sqlitebrowser

# Ruby on Rails
#${INSTALL_CMD} git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev 
#${INSTALL_CMD} libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev 
#${INSTALL_CMD} software-properties-common libffi-dev nodejs yarn

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

# Docker - do we need this?
# Add SSL support for APT repositories (required for Docker)
${INSTALL_CMD} apt-transport-https ca-certificates curl software-properties-common
# cleanup
sudo apt-get purge docker lxc-docker docker-engine docker.io
# add key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg > ~/aw.txt
sudo apt-key add ~/aw.txt
if [ -f /usr/bin/apt ] ; then
    # add apt repository for docker
    ${INSTALL_CMD} software-properties-common
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
${INSTALL_CMD} docker docker.io
# Turn on Docker Build kit
sudo sh -c 'echo export DOCKER_BUILDKIT="1" >> /etc/profile.d/docker.sh'

# Alpine
${INSTALL_CMD} musl-dev libaio-dev libnsl-dev
sudo ldconfig

# Install Oracle Database Instant Client via permanent OTN link
# Dependencies for Oracle Client
${INSTALL_CMD} libaio unzip
# Permanent Link (latest version) - Instant Client - Basic (x86 64 bit) - you need this for anything else to work
# Note: there is no Instant Client for the ARM processor, Intel/AMD x86 only
tmpdir=$(mktemp -d)
wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip -nc --directory-prefix=${tmpdir}
wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip -nc --directory-prefix=${tmpdir}
wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-tools-linuxx64.zip -nc --directory-prefix=${tmpdir}

if [   -d /opt/oracle ] ; then sudo rm -rf /opt/oracle ; fi 
if [ ! -d /opt/oracle ] ; then sudo mkdir -p /opt/oracle ; fi 
sudo chmod 755 /opt
sudo chmod 755 /opt/oracle
sudo chown $USER /opt/oracle
sudo unzip ${tmpdir}/instantclient-basic*.zip -d /opt/oracle
sudo unzip ${tmpdir}/instantclient-sqlplus*.zip -d /opt/oracle
sudo unzip ${tmpdir}/instantclient-tools*.zip -d /opt/oracle


# rm instantclient-basic*.zip
set -- /opt/oracle/instantclient*
export LD_LIBRARY_PATH=$1
sudo sh -c "# Oracle Instant Client         >  /etc/profile.d/instant-oracle.sh"
sudo sh -c "echo export LD_LIBRARY_PATH=$1  >> /etc/profile.d/instant-oracle.sh"
sudo sh -c "echo export PATH=$1:'\$PATH'    >> /etc/profile.d/instant-oracle.sh"

# With the normal Oracle Client, oraenv script sets the ORACLE_HOME, ORACLE_BASE and LD_LIBRARY_PATH variables and
# updates the PATH variable for Oracle
# But, with the Instant Client you only need the LD_LIBRARY_PATH set. And BTW: The Instant Client cannot be patched (reinstall a newer version)

# Eg. $ sqlplus scott/tiger@//myhost.example.com:1521/myservice

# Alpine Libraries for Oracle client
if [ -f /sbin/apk ] ; then
    # enable Edge repositories - hopefully this will go away eventually
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    apk update
    ${INSTALL_CMD} libnsl libaio musl-dev autconfig
fi

# Install Microsoft SQL Server Client
sudo apt-get install -y libunwind8 python3-pip
sudo pip install --user mssql-cli

if [ -d /opt/mssql-tools/bin/ ] ; then  
        sudo sh -c 'echo export PATH="/opt/ssql-tools/bin:$PATH"  > /etc/profile.d/mssql.sh'
        # sqlcmd -S localhost -U SA -P '<YourPassword>'
fi

# Join an on-premise Active Directory domain
# Ubuntu
# sudo apt-get install krb5-user samba sssd sssd-tools libnss-sss libpam-sss ntp ntpdate realmd adcli
# Centos/ReadHat/Oracle
# sudo yum install -y realmd sssd krb5-workstation krb5-libs oddjob oddjob-mkhomedir samba-common-tools
# ensure NTP is running and time is correct
# Domain name needs to be upper case
#AD_DOMAIN=AADDSCONTOSO.COM
#AD_USER=webstean@$AD_DOMAIN
#sudo realm discover $AD_DOMAIN && kinit contosoadmin@$AD_DOMAIN && sudo realm join --verbose $AD_DOMAIN -U '$AD_USER' --install=/

# Grant the 'AAD DC Administrators' group sudo privileges
# sudo bash -c "%AAD\ DC\ Administrators@lordsomerscamp.org.au ALL=(ALL) NOPASSWD:ALL"

# Install AWS CLI
cd ~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ~/./aws/install

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Azure Arc Agent -won't work on WSL VM as they dont run systemd
if [[ ! $(grep Microsoft /proc/version) ]]; then
    cd ~
    wget https://aka.ms/azcmagent -O ~/Install_linux_azcmagent.sh
    bash ~/Install_linux_azcmagent.sh
#    azcmagent connect --resource-group "<resourceGroupName>" --tenant-id "<tenantID>" --location "<regionName>" --subscription-id "<subscriptionID>"
#    azcmagent connect --resource-group "LSCPH-RaspberryPi" --tenant-id "<tenantID>" --location "<regionName>" --subscription-id "2d2089b6-d701-49aa-9600-bc2e3796d53a"
    azcmagent connect \
        --service-principal-id "{serviceprincipalAppID}" \
        --service-principal-secret "{serviceprincipalPassword}" \
        --resource-group "LSCPH-RaspberryPi" \
        --tenant-id "fd72f9ff-96b6-4a20-a870-ceaa17d70bc8" \
        --location "{resourceLocation}" \
        --subscription-id "2d2089b6-d701-49aa-9600-bc2e3796d53a"
fi

# Install Google Cloud (GCP) CLI
cd ~ && curl https://sdk.cloud.google.com > install.sh
chmod +x install.sh
bash install.sh --disable-prompts
~/google-cloud-sdk/install.sh --quiet

# install sysstat and enable it
sudo apt-get install sysstat

$ sudo vi /etc/default/sysstat
change ENABLED="false" to ENABLED="true"
save the file
Last, restart the sysstat service:

$ sudo service sysstat restart


# Solution: Xwindows Display
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
export LIBGL_ALWAYS_INDIRECT=1
EOF'

# sudo bash -c 'cat << EOF > /etc/systemd/system/pulseaudio.service
# [Unit]
# Description=PulseAudio system server

# [Service]
# Type=notify
# Exec=pulseaudio --daemonize=no --system --realtime --log-target=journal
# #Exec=pulseaudio -p /usr/local/lib/pulse-10.0/modules/ -n -F /usr/local/etc/pulse/system.pa --system --disallow-exit=1 --disable-shm=1 --fail=1

# [Install]
# WantedBy=multi-user.target
# EOF'

# systemctl --system enable pulseaudio.service
# systemctl --system start pulseaudio.service

# sudo bash -c 'cat << EOF > /etc/pulse/client.conf
# default-server = /var/run/pulse/native
# autospawn = no
# EOF'

# System wide

# openssl req -x509 \
#     -newkey rsa:2048 \
#     -keyout key.pem \
#     -out cert.pem \
#     -days 36500 \
#     -nodes \
#     -subj "/C=AU/ST=Victoria/L=Melbourne/O=webstean/OU=IT/CN=webstean.com"

# openssl genrsa -out server.key 2048
# openssl req -new -key server.key -out server.csr -subj "/C=AU/ST=Victoria/L=Melbourne/O=webstean/OU=IT/CN=webstean.com"
# openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt     

sudo bash -c 'cat << EOF > /etc/profile.d/pulsewsl.sh
# Pulse Audio
# To hear audio under WSL2 the Linux pulseaudio needs to point to the Pulse Daemon/Service
# -- running on Windows
# See: https://www.freedesktop.org/wiki/Software/PulseAudio/Ports/Windows/Support/
export PULSE_SERVER=tcp:\$(ip route list | sed -n -e "s/^default.*[[:space:]]\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\).*/\1/p")
# export PULSE_SEREVER = unix:/tmp/pulse-socket
# Run natively - when WSL can support ALSA directly
# export PULSE_SERVER="unix:/var/run/pulse/native"
# FYI: Pulse Server listens on port 4713/tcp
EOF'

# apt install pulseaudio

# Install Jack (Audio)
# apt-get install qjackctl

# pulseaudio --start --log-target=syslog

sudo sh -c 'echo "# Ensure \$LINES and \$COLUMNS always get updated."   >  /etc/profile.d/bash.sh'
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

sudo sh -c 'echo "# Alias to provide distribution name"                 >> /etc/profile.d/bash.sh'
sudi sh -c 'alias distribution=$(. /etc/os-release;echo $ID$VERSION_ID) >> /etc/profile.d/bash.sh'

# configure WSL
sudo sh -c 'echo [automount]                >   /etc/wsl.conf'
sudo sh -c 'echo root = /                   >>  /etc/wsl.conf'
sudo sh -c 'echo options = "metadata"       >>  /etc/wsl.conf'

sudo sh -c 'echo [interop]                  >>  /etc/wsl.conf'
sudo sh -c 'echo enabled = true             >>  /etc/wsl.conf'
sudo sh -c 'echo appendWindowsPath = true   >>  /etc/wsl.conf'

sudo sh -c 'echo [network]                  >>  /etc/wsl.conf'
sudo sh -c 'echo generateResolvConf = false >>  /etc/wsl.conf'
sudo sh -c 'echo generateHosts = false      >>  /etc/wsl.conf'

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

#!/usr/bin/env bash

# Debug this script if in debug mode
(( $DEBUG == 1 )) && set -x

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
    # AAD
    bash -c "echo '%aad_admins ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
    # AD DS
    bash -c "echo '%AAD\ DC\ Administrators@lordsomerscamp.org.au ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
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

# Set Timezone - includes keeping the machine to the right time but not sure how?
sudo timedatectl set-timezone Australia/Melbourne
timedatectl status 

# Set Locale
sudo apt-get install -y locales-all
sudo locale-gen "en_AU.UTF-8"
# sudo update-locale LANG="en_AU.UTF-8" LANGUAGE="en_AU:en" 
# sudo update-locale LANG=en_AU.UTF-8 LANGUAGE= LC_MESSAGES= LC_COLLATE= LC_CTYPE=
sudo update-locale LANG=en_AU.UTF-8 LANGUAGE=en_AU:en LC_MESSAGES=en_AU.UTF-8 LC_COLLATE= LC_CTYPE=
locale
# need reboot to show up properly - it will update /etc/default/locale

# Ensure git is install and then configure it 
${INSTALL_CMD} git
git config --global color.ui true
git config --global user.name "Andrew Webster"
git config --global user.email "webstean@gmail.com"
# cached credentials for 4 hours
git config --global credential.help cache =timeout=14400 
git config --global advice.detachedHead false
git config --list
# root
sudo git config --global color.ui true
sudo git config --global user.name "Andrew Webster"
sudo git config --global user.email "webstean@gmail.com"
# cached credentials for 4 hours
sudo git config --global credential.help cache =timeout=14400 
sudo git config --global advice.detachedHead false
sudo git config --list

# Generate an SSH Certificate
${INSTALL_CMD} openssh-client
cat /dev/zero | 
ssh-keygen -t rsa -b 4096 -C "webstean@gmail.com" -N '' -f ~/.ssh/id_rsa <<< $'\ny'

# github compatible
cat /dev/zero |
ssh-keygen -t ed25519 -C "webstean@gmail.com"-N '' -f ~/.ssh/id_ed25519 <<< $'\ny'


# Handle SSH Agent - at logon
sudo sh -c 'echo "# ssh-agent.sh - start ssh agent" > /etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "# The ssh-agent is a helper program that keeps track of user identity keys and their passphrases. " >> /etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "# The agent can then use the keys to log into other servers without having the user type in a " >> /etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "# password or passphrase again. This implements a form of single sign-on (SSO)." >> /etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "env=~/.ssh/agent.env" >> /etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "agent_load_env () { test -f \"\$env\" && . \"\$env\" >| /dev/null ; }" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "agent_start () { ">>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "    (umask 077; ssh-agent >| \"\$env\")" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "    . "\$env" >| /dev/null" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "}" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "agent_load_env" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "agent_run_state=\$(ssh-add -l >| /dev/null 2>&1; echo \$?)" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "if [ ! \"\$SSH_AUTH_SOCK\" ] || [ \$agent_run_state = 2 ]; then" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "        agent_start" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "        ssh-add" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "elif [ \"\$SSH_AUTH_SOCK\" ] && [ \$agent_run_state = 1 ]; then ">>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "        ssh-add" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "fi" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "unset env" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "" >>/etc/profile.d/ssh-agent.sh'

# ssh setup
# from host ssh-copy-id pi@raspberrypi.local - to enable promptless logon

# Install dependencies for reference GIT Repos
sudo mkdir -p /usr/local/oracle && sudo chown ${USER} /usr/local/oracle && chmod 755 /usr/local/oracle 
git clone https://github.com/oracle/docker-images /usr/local/oracle/oracle-docker-images

# BARESIP: An example of multi-repository C project that is updated regularly
${INSTALL_CMD} pkg-config alsa-utils libasound2-dev libpulse-dev
${INSTALL_CMD} gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-x 
${INSTALL_CMD} libgstreamer-plugins-base1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev
${INSTALL_CMD} build-essential pkg-config intltool libtool libsndfile1-dev libjson-c-dev libopus-dev
${INSTALL_CMD} libsndfile1-dev libspandsp-dev libgtk2.0-dev libjack-jackd2-dev

# Grep for SIP Network Sessions
### ${INSTALL_CMD} sngrep
# Video Codecs
${INSTALL_CMD} libavcodec-dev libavutil-dev libcairo2-dev
# ${INSTALL_CMD} libavdevice-dev libavformat-dev mpg123-dev 

mkdir -p /usr/local/src

#certbot
#${INSTALL_CMD}
sudo apt-get install -y snap
sudo snap install core && sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo -H /usr/bin/certbot certonly --standalone -d sbc.lordsomerscamp.org.au -d sbc.lordsomerscamp.com -d sbc.lordsomerscamp.com.au -d sbc.webstean.com

#./letsencrypt-auto --help
# sudo certbot certificates

#if [ -d /etc/apache2 ] ; then
#    sudo -H /usr/local/src/letsencrypt/letsencrypt-auto certonly --apache -d example.com -d www.example.com
#else
#    sudo -H /usr/local/src/letsencrypt/certbot/certbot certonly --standalone -d sbc.lordsomerscamp.org.au -d sbc.lordsomerscamp.com -d sbc.lordsomerscamp.com.au -d sbc.webstean.com
#fi

# WILDCARD: This need a DNS record
# certbot certonly -d 'lordsomerscamp.org.au,*.lordsomercamp.org.au' --server https://acme-v02.api.letsencrypt.org/directory --preferred-challenges dns --agree-tos --email webstean@gmail.com

# WILDCARD: this need a file put on the web server 
# certbot certonly -d -d 'lordsomerscamp.org.au,*.lordsomercamp.org.au' --server https://acme-v02.api.letsencrypt.org/directory --agree-tos --email webstean@gmail.com

# test
# sudo certbot renew --dry-run

# sound support
# This contains (among other utilities) the alsamixer and amixer utilities.
# amixer is a shell command to change audio settings,
# while alsamixer provides a more intuitive ncurses based interface for audio device configuration.
# should automatically find usb sound card devices
# speaker-test -c 2
sudo apt-get install -y alsa-utils 
# aplay -L

# build dependencies
sudo apt-get install -y build-essential pkg-config intltool libtool autoconf

if [ -d /usr/local/src ] ; then sudo rm -rf /usr/local/src ; fi
sudo mkdir -p /usr/local/src && sudo chown ${USER} /usr/local/src && chmod 744 /usr/local/src 

# openssl - setup
if [ -d /usr/local/src/openssl ] ; then sudo rm -rf /usr/local/src/openssl ; fi
git clone https://github.com/openssl/openssl /usr/local/src/openssl

# Install & Build openssl
# install - includes the documentaiton, install_sw does not
cd /usr/local/src/openssl && ./config && sudo make install_sw
# fix for libssl.so.3: cannot open
#cp /usr/local/lib64/libcrypto.so.3 /usr/local/lib/
#cp /usr/local/lib64/libcrypto.a /usr/local/lib/
#cp /usr/local/lib64/libssl.so.3 /usr/local/lib
# fix for libssl.so.3: cannot open
#ln -s /usr/local/lib64/libcrypto.so.3 /usr/local/lib64/libcrypto.so
#ln -s /usr/local/lib64/libssl.so.3 /usr/local/lib64/libssl.so
sudo ldconfig && openssl version -a

# sngrep - depends on openssl
sudo apt-get install -y autoconf libpcap-dev ncurses-dev # libgnutl*-dev libgcrypt*-dev
if [ -d /usr/local/src/sngrep ] ; then sudo rm -rf /usr/local/src/sngrep ; fi
git clone https://github.com/irontec/sngrep /usr/local/src/sngrep
# info:  GnuTLS and OpenSSL can not be enabled at the same time 
cd /usr/local/src/sngrep && sudo ./bootstrap.sh && sudo ./configure --with-openssl --enable-eep --enable-unicode && sudo make install
# cd /usr/local/src/sngrep && ./bootstrap.sh && ./configure --with-gnutls  --enable-eep && make --enable-unicode && sudo make install
# allow sngrep to run by non-root
sudo setcap 'CAP_NET_RAW+eip' /usr/local/bin/sngrep
# /etc/sngreprc for options

# bcf729 - rtpengine dependency
sudo apt install -y dpkg-dev autotools-dev dh-autoreconf pkg-config unzip
export VER=1.0.4
if [ -d /usr/local/src/bcg729-deb ] ; then sudo rm -rf /usr/local/src/bcg729-deb ; fi
mkdir -p /usr/local/src/bcg729-deb && sudo chown ${USER} /usr/local/src/bcg729-deb && cd /usr/local/src/bcg729-deb
curl https://codeload.github.com/BelledonneCommunications/bcg729/tar.gz/$VER >bcg729_$VER.orig.tar.gz
tar zxf bcg729_$VER.orig.tar.gz 
cd bcg729-$VER 
git clone https://github.com/ossobv/bcg729-deb.git debian 
dpkg-buildpackage -us -uc -sa
cd ../
dpkg -i libbcg729-*.deb

# rtpengine
sudo apt-get install -y debhelper default-libmysqlclient-dev gperf libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev
sudo apt-get install -y libbencode-perl libcrypt-openssl-rsa-perl libcrypt-rijndael-perl libdigest-crc-perl libdigest-hmac-perl libevent-dev
sudo apt-get install -y libhiredis-dev libio-multiplex-perl libio-socket-inet6-perl libiptc-dev libjson-glib-dev libmosquitto-dev libnet-interface-perl
sudo apt-get install -y libsocket6-perl libspandsp-dev libswresample-dev libsystemd-dev libwebsockets-dev libxmlrpc-core-c3-dev libxtables-dev
sudo apt-get install -y markdown libpcap-dev libghc-curl-dev
sudo apt install -y -t focal-backports iptables-dev 
sudo apt install -y -t focal-backports debhelper
sudo apt install -y -t focal-backports init-system-helpers
sudo apt install -y dkms
if [ -d /usr/local/src/rtpengine ] ; then sudo rm -rf /usr/local/src/rtpengine ; fi
BRANCH=mr8.5.5.1
BRANCH=mr8.5.5.1
git clone -b ${BRANCH} https://github.com/sipwise/rtpengine /usr/local/src/rtpengine
cd /usr/local/src/rtpengine && sudo dpkg-checkbuilddeps && sudo dpkg-buildpackage
cd ../
sudo dpkg -i ngcp-rtpengine-daemon_*.deb ngcp-rtpengine-iptables_*.deb ngcp-rtpengine-kernel-dkms_*.deb 
#

# libzrtp - big in the asterisk world
if [ -d /usr/local/src/libzrtp ] ; then rm -rf /usr/local/src/libzrtp ; fi
git clone https://github.com/juha-h/libzrtp /usr/local/src/libzrtp
# Install & Build libzrtp
### cd /usr/local/src/libzrtp && ./bootstrap.sh && ./configure CFLAGS="-O0 -g3 -W -Wall -DBUILD_WITH_CFUNC -DBUILD_DEFAULT_CACHE -DBUILD_DEFAULT_TIMER" && make && sudo make install && sudo ldconfig


# baresip
if [ -d /usr/local/src/re ] ; then rm -rf /usr/local/src/re ; fi
if [ -d /usr/local/src/rem ] ; then rm -rf /usr/local/src/rem ; fi
if [ -d /usr/local/src/baresip ] ; then rm -rf /usr/local/src/baresip ; fi
sudo git clone https://github.com/baresip/re /usr/local/src/re
sudo git clone https://github.com/baresip/rem  /usr/local/src/rem
sudo git clone https://github.com/baresip/baresip /usr/local/src/baresip

# BARESIP: An example of a largish github project that is updated regularly
sudo apt-get install -y alsa-utils libasound2-dev libpulse-dev
sudo apt-get install -y gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-x 
sudo apt-get install -y libgstreamer-plugins-base1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev
sudo apt-get install -y build-essential pkg-config intltool libtool libsndfile1-dev libjson-c-dev libopus-dev
sudo apt-get install -y libsndfile1-dev libspandsp-dev libgtk2.0-dev libjack-jackd2-dev
# Video Codecs
sudo apt-get install -y libavcodec-dev libavutil-dev libcairo2-dev

# Install & Build re
# Build as Release (no SIP debugging)
# cd /usr/local/src/re && make RELEASE=1 && sudo make RELEASE=1 install && sudo ldconfig
# Build with debug enabled
cd /usr/local/src/re && sudo make install && sudo ldconfig
# Install & Build rem (Note: re is a dependency)
cd /usr/local/src/rem && sudo make install && sudo ldconfig 
# Build baresip (Note: both re and rem are dependencies)
cd /usr/local/src/baresip && sudo make RELEASE=1 && sudo make RELEASE=1 install

# Create an example certificate - for baresip
sudo openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /etc/ssl/certs/example.crt -keyout /etc/ssl/certs/example.key \
    -subj "/C=AU/ST=Victoria/L=Melbourne/O=webstean/OU=IT/CN=webstean.com"
sudo sh -c 'cat /etc/ssl/certs/example.crt /etc/ssl/certs/example.key > /etc/ssl/certs/example.pem'

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

# Allow pi user to run docker commands - need to logout before become effective
sudo usermod -aG docker pi

# Test docker
sudo docker pull hello-world && sudo docker run hello-world

# Install docker-compose (btw: included with MAC desktop version)
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose && sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# Install docker-compose completion
sudo curl -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

# run Azure CLI as a container
sudo git clone https://github.com/gtrifonov/raspberry-pi-alpine-azure-cli.git
cd .\raspberry-pi-alpine-azure-cli
sudo docker build . -t azure-cli
sudo docker run -d -it --rm --name azure-cli azure-cli

# Alpine
${INSTALL_CMD} musl-dev libaio-dev libnsl-dev
sudo ldconfig

# Enable Linux features for Docker/k3s
if ! (grep "cgroup_enable=memory cgroup_memory=1 swapaccount=1" /boot/cmdline.txt ) ; then
    echo Updating /boot/cmdline with cgroup - doesnt work - needs to be fixed
    sudo bash -c "echo -n 'cgroup_enable=memory cgroup_memory=1 swapaccount=1' >>/boot/cmdline.txt"
    sudo bash -c "sed '${s/$/cgroup_enable=memory cgroup_memory=1 swapaccount=1/}' /boot/cmdline.txt >/boot/cmdline.txt"
fi

# k3s - master
sudo iptables -F
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo reboot

curl -sfL https://get.k3s.io | sh -
sudo systemctl status k3s
# "fix" file permissions for development / devops
if [ -f /etc/rancher/k3s/k3s.yaml ] ; sudo chmod 555 /etc/rancher/k3s/k3s.yaml ; fi
if [ -f /var/lib/rancher/k3s/server/token ] ; sudo chmod 555 /var/lib/rancher/k3s/server/token ; fi
echo waiting 30 seconds....
sleep 30
sudo k3s kubectl get node
# list of pods running locally
sudo crictl pods
k3s check-config

# for kubectl - if installed, eg 'kubecl get pods --all-namespaces'
sudo sh -c 'echo "# Note: By default /etc/rancher/k3s/k3s.yaml is only readable by root" > /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "if [ -f /etc/rancher/k3s/k3s.yaml ] ; export KUBECONFIG=/etc/rancher/k3s/k3s.yaml ; fi" >> /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "# Note: By default /var/lib/rancher/k3s/server/token is only readable by root" >> /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "if [ -f /var/lib/rancher/k3s/server/token ] ; export K3S_TOKEN=`cat /var/lib/rancher/k3s/server/token`" >> /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "# Hostname for k3s" >> /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "# export K3S_URL=https://somehost.com:6443 " >> /etc/profile.d/kubeconfig.sh'

# Certificate
# CERT_PRIV   : Private Key
# CERT_FULL   : Full chanin of certificate
# CERT_CA     : Certificate Authority List
# CERT_VERIFY : Verify Certtificate (Boolean)

# S3 Buckets
# S3-BUCKET_NAME
# S3-ACCESS-KEY
# S3-SECRET-KEY

# DATASOURCE
#????

# Load Testing, example
# hey -z 5m -c 2 -q 10 http://url.com/api
# for 5 minutes, 2 conccurent requests, no more 10 requests per second

# openfaas - serverless open source

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
sudo chmod -r 755 /opt
sudo chown ${USER} /opt/oracle
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

# Install AWS CLI (Linux)
cd ~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ~/./aws/install

# Install Azure CLI (Mac)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && az version
az config set auto-upgrade.enable=yes # automatic upgrade enabled
az config set auto-upgrade.prompt=no  # dont prompt

## on MAC
# brew update && brew install azure-cli
# brew tap homebrew/autoupdate

## need to AAD logon working with
## interactively via browser
# az login

## 

# Install Google Cloud (GCP) CLI
cd ~ && curl https://sdk.cloud.google.com > install.sh
chmod +x install.sh
bash install.sh --disable-prompts
~/google-cloud-sdk/install.sh --quiet

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

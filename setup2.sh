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

# if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
if [[ $(id -u) -eq 0 ]] ; then echo "Please DO NOT run as root" ; exit 1 ; fi


if [ -z "$SHELL" ] ; then
    export SHELL=/bin/sh
fi

# Alpine apt - sudo won't be there by default on Alpine
if [ -f /sbin/apk ] ; then  
    apk add sudo
fi

# Enable sudo for all users - by modifying /etc/sudoers
if ! (grep NOPASSWD:ALL /etc/sudoers ) ; then 
    # Everyone
    bash -c "echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
    # AAD
    bash -c "echo '%aad_admins ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
    # AD DS
    bash -c "echo '%AAD\ DC\ Administrators@lordsomerscamp.org.au ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
fi

# Alpine Libraries for Oracle client
if [ -f /sbin/apk ] ; then
    # enable Edge repositories - hopefully this will go away eventually
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    apk update
    ${INSTALL_CMD} libnsl libaio musl-dev autconfig
fi

# Add Microsoft Repos
if [ -f /usr/bin/apt ] ; then
    # Import the public repository GPG keys
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

    # Register the Microsoft Ubuntu repository
    repo=https://packages.microsoft.com/$(lsb_release -s -i)/$(lsb_release -sr)/prod
    # convert to lowercase
    repo=${repo,,}
    echo $repo
    sudo apt-add-repository $repo
    
    # Update the list of products
    sudo apt-get update
    
    # Install Microsoft tools
    sudo apt-get install -y azure-functions-core-tools
    sudo apt-get install -y mssql-tools sqlcmd
    sudo apt-get install -y powershell
    sudo apt-get install -y unixodbc-bin
    
    # cleanup
    sudo apt autoremove
fi

## Global environmment variables (editable)
sudo sh -c "echo # export AW1=AW1       >  /etc/profile.d/global-variables.sh"
# Turn off Microsoft telemetry for Azure Function Tools
sudo sh -c "echo # export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1       >>  /etc/profile.d/global-variables.sh"

# Environent Variables for proxy support
# Squid default port is 3128, but many setup the proxy on port 80,8000,8080
sudo sh -c 'echo "## Web Proxy Setup - edit as required"                               >  /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "web-proxy() {"                                                       >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  port=3128"                                                         >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  webproxy=proxy.com.au"                                             >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  ## Proxy Exceptions"                                               >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  export NO_PROXY=localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8" >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  ## Anonymous Proxy"                                                >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  export HTTP_PROXY=http://\${webproxy}:\${port}"                    >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  export HTTPS_PROXY=http://\${webproxy}:\${port}"                   >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  export FTP_PROXY=http://\${webproxy}:\${port}"                     >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  return;"                                                           >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  ## Proper Proxy"                                                   >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  USERN=UserName"                                                    >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  @ME=Password"                                                      >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  export HTTP_PROXY=http://\${USERN}:\${@ME}\${webproxy}:\${port}/"  >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  export HTTPS_PROXY=http://\${USERN}:\${@ME}\${webproxy}:\${port}/" >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "  export FTP_PROXY=http://\${USERN}:\${@ME}\${webproxy}:\${port}/"   >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "}"                                                                   >> /etc/profile.d/web-proxy.sh'
sudo sh -c 'echo "# web-proxy()"                                                       >> /etc/profile.d/web-proxy.sh'

# Set Timezone - includes keeping the machine to the right time but not sure how?
# WSL Error: System has not been booted with systemd as init system (PID 1). Can't operate.
#          : unless you edit /etc/wsl.conf to enable systemd
sudo timedatectl set-timezone Australia/Melbourne
timedatectl status 

# Set AU Locale
sudo locale-gen "en_AU.UTF-8"
sudo update-locale LANG=en_AU.UTF-8 LANGUAGE=en_AU:en LC_MESSAGES=en_AU.UTF-8 LC_COLLATE= LC_CTYPE= LC_ALL=C
# restart shell to correct variables
eval "$(exec /usr/bin/env -i "${SHELL}" -l -c "export")"
locale

# Ensure git is install and then configure it 
# ${INSTALL_CMD} git
if [ -x /usr/bin/git ] ; then
    git config --global color.ui true
    git config --global user.name "Andrew Webster"
    git config --global user.email "webstean@gmail.com"
    # cached credentials for 4 hours
    git config --global credential.help cache =timeout=14400 
    git config --global advice.detachedHead false
    git config --list
}

# Install Oracle Database Instant Client via permanent OTN link
oracleinstantclientinstall() {
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
    if [ -f /etc/profile.d/instant-oracle.sh ] ; then
        sudo rm /etc/profile.d/instant-oracle.sh 
    fi
    sudo sh -c "echo # Oracle Instant Client Setup >  /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo oracle-instantclient\(\) {        >>  /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo export LD_LIBRARY_PATH=$1  >> /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo export PATH=$1:'\$PATH'    >> /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo }                          >>  /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo if [ -d /opt/oracle/instantclient\* ] \; then >>  /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo   echo \"Oracle Database Client found!\"     >>  /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo   oracle-instantclient              >>  /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo fi                                  >>  /etc/profile.d/instant-oracle.sh"

    return 0
}

MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    oracleinstantclientinstall
fi


# build/development dependencies
if [ -d /usr/local/src ] ; then sudo rm -rf /usr/local/src ; fi
sudo mkdir -p /usr/local/src && sudo chown ${USER} /usr/local/src && chmod 744 /usr/local/src 
sudo apt-get install -y build-essential pkg-config intltool libtool autoconf
# sqllite
sudo apt-get install -y sqlite3 libsqlite3-dev
# create database
# sqlite test.db

# Generate an SSH Certificate
${INSTALL_CMD} openssh-client
cat /dev/zero | ssh-keygen -t rsa -b 4096 -C "webstean@gmail.com" -N '' -f ~/.ssh/id_rsa <<< $'\ny'
# Firewall Rules for SSH Server
ufw allow ssh

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
sudo sh -c 'echo "if ! [ -f \$env ] ; then " >> /etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "   return 0 " >> /etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "fi ">> /etc/profile.d/ssh-agent.sh'
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
sudo sh -c 'echo "# ssh setup" >>/etc/profile.d/ssh-agent.sh'
sudo sh -c 'echo "# # from host ssh-copy-id pi@raspberrypi.local - to enable promptless logon" >>/etc/profile.d/ssh-agent.sh'

## for kubectl - if installed, eg 'kubecl get pods --all-namespaces'
sudo sh -c 'echo "# Note: By default /etc/rancher/k3s/k3s.yaml is only readable by root" > /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "if [ -f /etc/rancher/k3s/k3s.yaml ] ; export KUBECONFIG=/etc/rancher/k3s/k3s.yaml ; fi" >> /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "# Note: By default /var/lib/rancher/k3s/server/token is only readable by root" >> /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "if [ -f /var/lib/rancher/k3s/server/token ] ; export K3S_TOKEN=`cat /var/lib/rancher/k3s/server/token`" >> /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "# Hostname for k3s" >> /etc/profile.d/kubeconfig.sh'
sudo sh -c 'echo "# export K3S_URL=https://somehost.com:6443 " >> /etc/profile.d/kubeconfig.sh'

## get some decent stuff working for all bash users
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

# Enable Linux features for Docker/k3s
if ! (grep "cgroup_enable=memory cgroup_memory=1 swapaccount=1" /boot/cmdline.txt ) ; then
    echo Updating /boot/cmdline with cgroup - doesnt work - needs to be fixed
    sudo bash -c "echo -n 'cgroup_enable=memory cgroup_memory=1 swapaccount=1' >>/boot/cmdline.txt"
    sudo bash -c "sed '${s/$/cgroup_enable=memory cgroup_memory=1 swapaccount=1/}' /boot/cmdline.txt >/boot/cmdline.txt"
fi

## If WSL, install minimal X11
if [[ $(grep -i WSL /proc/sys/kernel/osrelease) ]]; then
    sudo apt-get install xscreensaver
    sudo apt-get install x11-apps
    echo $DISPLAY
    # Start xeyes to show X11 working - hopefully (now just works with WSL 2 plus GUI)
    xeyes &
    # Install browser for sqlite
    sudo apt-get install -y sqlitebrowser
    sqlitebrowser &
    ## Since this WSL set some settings
    if [ -f /etc/wsl.conf ] ; then sudo rm -f /etc/wsl.conf ; fi
    sudo sh -c 'echo [boot]                     >>  /etc/wsl.conf'
    sudo sh -c 'echo systemd=true               >>  /etc/wsl.conf'
    
    sudo sh -c 'echo [automount]                >>  /etc/wsl.conf'
    sudo sh -c 'echo root = \/mnt               >>  /etc/wsl.conf'
    sudo sh -c 'echo options = "metadata"       >>  /etc/wsl.conf'

    sudo sh -c 'echo [interop]                  >>  /etc/wsl.conf'
    sudo sh -c 'echo enabled = true             >>  /etc/wsl.conf'
    sudo sh -c 'echo appendWindowsPath = true   >>  /etc/wsl.conf'

    sudo sh -c 'echo [network]                  >>  /etc/wsl.conf'
    sudo sh -c 'echo generateResolvConf = false >>  /etc/wsl.conf'
    sudo sh -c 'echo generateHosts = false      >>  /etc/wsl.conf'
fi



# Run Oracle XE config if found
#if [ -f /etc/init.d/oracle-xe* ] ; then
#    /etc/init.d/oracle-xe-18c configure
#fi

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

# sound support
# This contains (among other utilities) the alsamixer and amixer utilities.
# amixer is a shell command to change audio settings,
# while alsamixer provides a more intuitive ncurses based interface for audio device configuration.
# should automatically find usb sound card devices
# speaker-test -c 2
sudo apt-get install -y alsa-utils 
# aplay -L

# Install Python
${INSTALL_CMD} python
${INSTALL_CMD} python-dev py-pip build-base 

# Install Node through Node Version Manager (nvm)
# https://github.com/nvm-sh/nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
# The script clones the nvm repository to ~/.nvm, and attempts to add the source lines from the snippet below
# to the correct profile file (~/.bash_profile, ~/.zshrc, ~/.profile, or ~/.bashrc).
source ~/.bashrc
command -v nvm
nvm --version
## install late node
# nvm install 13.10.1 # Specific minor release
# nvm install 14 # Specify major release only
## install latest
nvm install node
## install Active Long Term Support (LTS)
# nvm install --lts
nvm ls

# Install Terraform.
# curl "https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip" -o "terraform.zip" \
#  && unzip terraform.zip && chmod +x terraform \
#  && sudo mv terraform ~/.local/bin && rm terraform.zip

# Docker (it is a lotter better run docker inside WSL, than maintain inside Windows)
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
# Ensure dbus is running:
dbus_status=$(service dbus status)
if [[ $dbus_status = *"is not running"* ]]; then
    sudo service dbus --full-restart
fi
echo $dbus_status

${INSTALL_CMD} docker docker.io
# Turn on Docker Build kit
sudo sh -c 'echo export DOCKER_BUILDKIT="1" >> /etc/profile.d/docker.sh'

# Allow $USER to run docker commands - need to logout before become effective
sudo usermod -aG docker $USER

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


# With the normal Oracle Client, oraenv script sets the ORACLE_HOME, ORACLE_BASE and LD_LIBRARY_PATH variables and
# updates the PATH variable for Oracle
# But, with the Instant Client you only need the LD_LIBRARY_PATH set. And BTW: The Instant Client cannot be patched (reinstall a newer version)

# Eg. $ sqlplus scott/tiger@//myhost.example.com:1521/myservice

# Install AWS CLI (Linux)
cd ~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ~/./aws/install
rm awscliv2.zip

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && az version
# automatic upgrade enabled
az config set auto-upgrade.enable=yes --only-show-errors  # automatic upgrade enabled
# dont prompt
az config set auto-upgrade.prompt=no  --only-show-errors # dont prompt
az bicep install
az version
az bicep version

## need to AAD logon working with
## interactively via browser
# az login

## 

## Install Google Cloud (GCP) CLI
#cd ~ && curl https://sdk.cloud.google.com > install.sh
#chmod +x install.sh
#bash install.sh --disable-prompts
#~/google-cloud-sdk/install.sh --quiet

# install sysstat and enable it
sudo apt-get install sysstat

$ sudo vi /etc/default/sysstat
change ENABLED="false" to ENABLED="true"
save the file
Last, restart the sysstat service:

$ sudo service sysstat restart


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

# apt install pulseaudio

## Oh-My-Posh - Colourful Commandline Prompt
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.omp.*
rm ~/.poshthemes/themes.zip
# oh-my-posh font install "Meslo LGM NF"
# oh-my-posh font install Meslo
oh-my-posh get shell
# eval "$(oh-my-posh init bash)"
eval "$(oh-my-posh init `oh-my-posh get shell`)"
oh-my-posh notice
## themes can be found in ~/.poshthemes/ for example: dracula.omp.json
## oh-my-posh init `oh-my-posh get shell` -c dracula.omp.json
## Eg:-
## eval "$(oh-my-posh init `oh-my-posh get shell` -c dracula.omp.json`)"

## Generate
## https://textkool.com/en/ascii-art-generator
## note: any ` needs to be escaped with \
if [ -f  ~/.logo  ] ; then rm -f ~/.logo ; fi
cat >> ~/.logo <<EOF
                     _                   
     /\             | |                  
    /  \   _ __   __| |_ __ _____      __
   / /\ \ | '_ \ / _\` | '__/ _ \ \ /\ / /
  / ____ \| | | | (_| | | |  __/\ V  V / 
 /_/    \_\_| |_|\__,_|_|  \___| \_/\_/  
                                         
EOF
if [ -f  /etc/profile.d/logo.sh  ] ; then sudo rm -f /etc/profile.d/logo.sh ; fi
sudo sh -c 'echo if [ -f  \~/.logo ] \; then >>  /etc/profile.d/logo.sh'
sudo sh -c 'echo    cat \~/.logo >>  /etc/profile.d/logo.sh'
sudo sh -c 'echo fi >>  /etc/profile.d/logo.sh'
                                       
# apt clean  up
if [ -f /usr/bin/apt ] ; then
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
fi

# yum clean  up
if [ -f /usr/bin/yum ] ; then
    yum clean all && rm -rf /tmp/* /var/tmp/*
fi


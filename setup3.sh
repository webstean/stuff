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
if ! (sudo grep NOPASSWD:ALL /etc/sudoers ) ; then 
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

if [   -d /opt ] ; then sudo rm -rf /opt ; fi 
if [ ! -d /opt ] ; then sudo mkdir -p /opt ; chmod 755 /opt ; fi 
sudo chmod 755 /opt

# Add Microsoft Repos and Applications
if [ -f /usr/bin/apt ] ; then
    # make sure prereqs are installs
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Import the public repository GPG keys (depreciated)
    # Note: Instead of using this command a keyring should be placed directly in the 
    # /etc/apt/trusted.gpg.d/ directory with a descriptive name and either "gpg" or "asc" 
    # as file extension.
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

    # Register the Microsoft Ubuntu repository
    repo=https://packages.microsoft.com/$(lsb_release -s -i)/$(lsb_release -sr)/prod
    # convert to lowercase
    repo=${repo,,}
    echo $repo
    sudo apt-add-repository --yes $repo
    
    # Update the list of products
    sudo apt-get update
    
    # Skip ELA prompt - I hope
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

    # Install Microsoft tools
    sudo apt-get install -y azure-functions-core-tools
    sudo apt-get install -y mssql-tools sqlcmd
    sudo apt-get install -y powershell
    sudo apt-get install -y msopenjdk-17
        
    if [ -f /etc/profile.d/microsoft-powershell.sh ] ; then sudo rm -f /etc/profile.d/microsoft-powershell.sh ; fi
    if (which pwsh) ; then 
        sudo sh -c 'echo   echo \"Powershell \(pwsh\) found!\"     >>  /etc/profile.d/microsoft-powershell.sh'
    fi
    # cleanup
    sudo apt autoremove
fi

# Add Docker repo
if [ -f /usr/bin/apt ] ; then

    # make sure prereqs are installs
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Import the public repository GPG keys (depreciated)
    # Note: Instead of using this command a keyring should be placed directly in the 
    # /etc/apt/trusted.gpg.d/ directory with a descriptive name and either "gpg" or "asc" 
    # as file extension.
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    
    repo="deb [arch=amd64 ] https://download.docker.com/linux/$(lsb_release -is) $(lsb_release -cs) stable" 
    # convert to lowercase
    repo=${repo,,}
    echo $repo
    sudo apt-add-repository --yes $repo
    
    # nsure the Docker installation source is the Docker repository, not the Ubuntu repository. 
    sudo apt-cache policy docker-ce
    
    # Update the list of products
    sudo apt-get update 
    
    # install docker
    sudo apt install docker-ce -y
    sudo systemctl status docker
    
    # Turn on Docker Build kit
    sudo sh -c 'echo export DOCKER_BUILDKIT="1" >> /etc/profile.d/docker.sh'

    # Allow $USER to run docker commands - need to logout before become effective
    sudo usermod -aG docker $USER

    # Ensure dbus is running:
    dbus_status=$(service dbus status)
    if [[ $dbus_status = *"is not running"* ]]; then
        sudo service dbus --full-restart
    fi
    
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
# locale should be C.UTF-8

##sudo locale-gen "C.UTF-8"
##sudo update-locale LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_MESSAGES=C.UTF-8 LC_COLLATE= LC_CTYPE= LC_ALL=C

# Ensure git is install and then configure it 
# ${INSTALL_CMD} git
if [ -x /usr/bin/git ]; then
    git config --global color.ui true
    git config --global user.name "Andrew Webster"
    git config --global user.email "webstean@gmail.com"
    # cached credentials for 2 hours
    git config --global credential.helper 'cache --timeout 7200'
    git config --global advice.detachedHead false
    git config --list
fi

# Install Oracle Database Instant Client via permanent OTN link
oracleinstantclientinstall() {
    # Dependencies for Oracle Client
    # apt-get install -y libaio 
    apt-get install -y unzip
    ## ${INSTALL_CMD} libaio unzip
    # Permanent Link (latest version) - Instant Client - Basic (x86 64 bit) - you need this for anything else to work
    # Note: there is no Instant Client for the ARM processor, Intel/AMD x86 only
    tmpdir=$(mktemp -d)
    wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip -nc --directory-prefix=${tmpdir}
    wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip -nc --directory-prefix=${tmpdir}
    wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-tools-linuxx64.zip -nc --directory-prefix=${tmpdir}

    if [   -d /opt/oracle ] ; then sudo rm -rf /opt/oracle ; fi 
    if [ ! -d /opt/oracle ] ; then sudo mkdir -p /opt/oracle ; sudo chmod 755 /opt/oracle ; fi 
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
    sudo sh -c "echo }                          >> /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo if [ -d /opt/oracle/instantclient\* ] \; then >> /etc/profile.d/instant-oracle.sh"
    sudo sh -c 'echo   echo \"Oracle Database Client \(sqlplus\) found!\"     >>  /etc/profile.d/instant-oracle.sh'
    sudo sh -c "echo   oracle-instantclient              >>  /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo fi                                  >>  /etc/profile.d/instant-oracle.sh"
    sudo sh -c "echo # example: sqlplus scott/tiger@//myhost.example.com:1521/myservice >>  /etc/profile.d/instant-oracle.sh"
 
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

## If WSL2, install minimal X11 and set some WSL specific settings
if [[ $(grep -i WSL2 /proc/sys/kernel/osrelease) ]]; then
    sudo apt-get install -y xscreensaver
    sudo apt-get install -y x11-apps
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
    sudo sh -c 'echo generateResolvConf = true  >>  /etc/wsl.conf'
    sudo sh -c 'echo generateHosts = true       >>  /etc/wsl.conf'
fi

# If java is installed, install maven
if (which java) ; then
    sudo apt install -y maven
    maven
fi

# Run Oracle XE config if found
#if [ -f /etc/init.d/oracle-xe* ] ; then
#    /etc/init.d/oracle-xe-18c configure
#fi

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
if [ -f /etc/profile.d/nodejs.sh ] ; then sudo rm -f /etc/profile.d/nodejs.sh ; fi
if (which node) ; then 
    sudo sh -c 'echo if \(which node\) \; then           >>  /etc/profile.d/nodejs.sh'
    sudo sh -c 'echo   echo \"Node JS \(node\) found -  use nvm to manage!\"  >>  /etc/profile.d/nodejs.sh'
    sudo sh -c 'echo fi >>  /etc/profile.d/nodejs.sh'
fi
    
# Install Terraform.
# curl "https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip" -o "terraform.zip" \
#  && unzip terraform.zip && chmod +x terraform \
#  && sudo mv terraform ~/.local/bin && rm terraform.zip

# Alpine
${INSTALL_CMD} musl-dev libaio-dev libnsl-dev
sudo ldconfig

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
if [ -f  /etc/profile.d/azurecli.sh  ] ; then sudo rm -f /etc/profile.d/azurecli.sh ; fi
sudo sh -c 'echo echo \"Azure CLI \(az\) found!\"     >>  /etc/profile.d/azurecli.sh'
sudo sh -c 'echo # az account show --output table >>  /etc/profile.d/azurecli.sh'
   
# Install GoLang - current user
wget -q -O - https://git.io/vQhTU | bash
if [ -f  /etc/profile.d/golang.sh  ] ; then sudo rm -f /etc/profile.d/golang.sh ; fi
sudo sh -c 'echo if \(which go\) \; then           >>  /etc/profile.d/golang.sh'
sudo sh -c 'echo echo \"Golang \(go\) found!\"     >>  /etc/profile.d/golang.sh'
sudo sh -c 'echo fi                                >>  /etc/profile.d/golang.sh'

## Install Google Cloud (GCP) CLI
#cd ~ && curl https://sdk.cloud.google.com > install.sh
#chmod +x install.sh
#bash install.sh --disable-prompts
#~/google-cloud-sdk/install.sh --quiet

## need to AAD logon working with
## interactively via browser
# az login

## 

# install and config sysstat
sudo apt-get -y install sysstat

$ sudo vi /etc/default/sysstat
change ENABLED="false" to ENABLED="true"
save the file
Last, restart the sysstat service:

sudo systemctl enable sysstat
sudo systemctl start sysstat

# openssl req -x509 \
#     -newkey rsa:2048 \
#     -keyout key.pem \
#     -out cert.pem \
#     -days 36500 \
#     -nodes \
#     -subj "/C=AU/ST=Victoria/L=Melbourne/O=webstean/OU=IT/CN=webstean.com"

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
                                         
 Development Environment
 
EOF
if [ -f  /etc/profile.d/zlogo.sh  ] ; then sudo rm -f /etc/profile.d/zlogo.sh ; fi
sudo sh -c 'echo if [ -f  \~/.logo ] \; then >>  /etc/profile.d/zlogo.sh'
sudo sh -c 'echo    cat \~/.logo >>  /etc/profile.d/zlogo.sh'
sudo sh -c 'echo fi >>  /etc/profile.d/zlogo.sh'
                                       
# apt clean  up
if [ -f /usr/bin/apt ] ; then
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
fi

# yum clean  up
if [ -f /usr/bin/yum ] ; then
    yum clean all && rm -rf /tmp/* /var/tmp/*
fi

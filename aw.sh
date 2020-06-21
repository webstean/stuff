#!/bin/bash
# Install some Reference GIT Repos

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

    # Cleanup
    sudo apt autoremove -y
fi

exit 0


sudo bash -c "echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"

# Install FZF (fuzzy finder on the terminal and used by a Vim plugin).
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/git/fzf
# ~/git/fzf/install --all

# Install ASDF (version manager for non-Dockerized apps).
git clone https://github.com/asdf-vm/asdf.git ~/git/asdf --branch v0.7.8

# Enable asdf to manage various programming runtime versions.
#   Requires: https://asdf-vm.com/#/
source "~/git/asdf/asdf.sh"


# Install Certificates
~/git/asdf/bin/asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git

# Install Node through ASDF.
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs 12.17.0
asdf global nodejs 12.17.0

exit 0

# Install system dependencies for Ruby.
sudo apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev \
  libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev

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

exit 0

# Alpine
if [ -f /sbin/apk ] ; then  
#    sudo apk update
#    sudo apk upgrade
#    sudo apk upgrade --available
     export INSTALL_CMD="sudo apk add --no-cache --force-broken-world"
fi

# Debian, Ubuntu apt
if [ -f /usr/bin/apt ] ; then
#    sudo apt-get update 
#    sudo apt-get -y upgrade
    export INSTALL_CMD="sudo apt-get install -y"
fi

# Centos, RedHat, OraclieLinux yum
if [ -f /usr/bin/yum ] ; then  
#    sudo yum -y update
#    sudo yum -y upgrade
    export INSTALL_CMD="sudo yum install -y"
fi

# Essential packages
$INSTALL_CMD \
  vim-gtk \
  tmux \
  git \
  gpg \
  curl \
  rsync \
  unzip \
  htop \
  shellcheck \
  ripgrep \
  pass \
  python3-pip

# Build System Support 
$INSTALL_CMD vim tzdata openssh-server
$INSTALL_CMD build-essential git wget curl unzip dos2unix htop libcurl3
$INSTALL_CMD libxext-dev
$INSTALL_CMD gdb

# Linux (ALSA) Audio Support
$INSTALL_CMD libasound2-dev libasound2 libasound2-data module-init-tools libsndfile1-dev
sudo modprobe snd-dummy
sudo modprobe snd-aloop
# need more - to hear sound under WSL you need the pulse daemon running (on Windows)

rm -rf ~/git
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
cd ~/git/openssl && make && sudo make install && sudo ldconfig
# Install & Build Libre
cd ~/git/re && make && sudo make install && sudo ldconfig
# Install & Build Librem
cd ~/git/rem && make && sudo make install && sudo ldconfig
# Build baresip
cd ~/git/baresip && make RELEASE=1 && sudo make RELEASE=1 install && sudo ldconfig
# Test Baresip to initialize default config and Exit
# baresip -t -f $HOME/.baresip
# Install Configuration from baresip-docker
# git clone https://github.com/QXIP/baresip-docker.git ~/git/baresip-docker
#cp -R ~/git/baresip-docker $HOME/.baresip
#cp -R ~/git/baresip-docker/.asoundrc $HOME
# Run Baresip set the SIP account
#CMD baresip -d -f $HOME/.baresip && sleep 2 && curl http://127.0.0.1:8000/raw/?Rsip:root:root@127.0.0.1 && sleep 5 && curl http://127.0.0.1:8000/raw/?dbaresip@conference.sip2sip.info && sleep 60 && curl http://127.0.0.1:8000/raw/?bq

# WSL 1
if grep -qE "(Microsoft|WSL)" /proc/version &>/dev/null; then
    if [ "$(umask)" = "0000" ]; then
        umask 0022
    fi
sudo bash -c 'cat << EOF > /etc/profile.d/display.sh
export DISPLAY=:0
EOF'
fi

# WSL 2
if grep -q "microsoft" /proc/version &>/dev/null; then
    # Requires: https://sourceforge.net/projects/vcxsrv/ (or alternative)
sudo bash -c 'cat << EOF > /etc/profile.d/display.sh
export DISPLAY=\$(ip route list | sed -n -e "s/^default.*[[:space:]]\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\).*/\1/p"):0
EOF'
fi

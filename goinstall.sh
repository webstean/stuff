#!/bin/bash
set -e

VERSION="1.14"
GOROOT="/usr/local/go"
# GOPATH="/usr/local/go"
GOPATH="$HOME/go"

if [ ! -z "$1" ]; then
    echo "Unrecognized option: $1"
    exit 1
fi

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

OS="$(uname -s)"
ARCH="$(uname -m)"

case $OS in
    "Linux")
        case $ARCH in
        "x86_64")
            ARCH=amd64
            ;;
        "aarch64")
            ARCH=arm64
            ;;
        "armv6")
            ARCH=armv6l
            ;;
        "armv8")
            ARCH=arm64
            ;;
        .*386.*)
            ARCH=386
            ;;
        esac
        PLATFORM="linux-$ARCH"
    ;;
    "Darwin")
        PLATFORM="darwin-amd64"
    ;;
esac

print_help() {
    echo "Usage: bash goinstall.sh OPTIONS"
    echo -e "\nOPTIONS:"
    echo -e "  --remove\tRemove currently installed version"
    echo -e "  --version\tSpecify a version number to install"
}

if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
    shell_profile="zshrc"
elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
    shell_profile="bashrc"
fi

if [ "$1" == "--remove" ]; then
    rm -rf "$GOROOT"
    rm -rf /etc/profile.d/golang.sh
    echo "Go removed."
    exit 0
elif [ "$1" == "--help" ]; then
    print_help
    exit 0
elif [ "$1" == "--version" ]; then
    if [ -z "$2" ]; then # Check if --version has a second positional parameter
        echo "Please provide a version number for: $1"
    else
        VERSION=$2
    fi
elif [ ! -z "$1" ]; then
    echo "Unrecognized option: $1"
    exit 1
fi

if [ -d "$GOROOT" ]; then
    echo "The Go install directory ($GOROOT) already exists. Exiting."
    echo "Use $0 --remove\tto remove currently installed version"
    exit 1
fi

PACKAGE_NAME="go$VERSION.$PLATFORM.tar.gz"
TEMP_DIRECTORY=$(mktemp -d)

echo "Downloading $PACKAGE_NAME ..."
if hash wget 2>/dev/null; then
    wget https://storage.googleapis.com/golang/$PACKAGE_NAME -O "$TEMP_DIRECTORY/go.tar.gz"
else
    curl -o "$TEMP_DIRECTORY/go.tar.gz" https://storage.googleapis.com/golang/$PACKAGE_NAME
fi

if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
fi

echo "Extracting File..."
mkdir -p "$GOROOT"
tar -C "$GOROOT" --strip-components=1 -xzf "$TEMP_DIRECTORY/go.tar.gz"
{
    echo '# GoLang'
    echo export GOROOT=${GOROOT}
    echo export PATH=${GOROOT}/bin:${PATH}
    echo 'if [ -d \${HOME}/go ] ; then'
    echo '    export GOPATH=${HOME}/go'
    echo '    export PATH=${GOPATH}/bin:${PATH}'
    echo fi
} > '/etc/profile.d/golang.sh'

mkdir -p $GOPATH/{src,pkg,bin}
echo -e "\nGo $VERSION was installed into $GOROOT.\nMake sure to relogin into your shell or run:"
echo -e "\n\tsource $HOME/.${shell_profile}\n\nto update your environment variables."
echo "Tip: Opening a new terminal window usually just works. :)"
rm -f "$TEMP_DIRECTORY/go.tar.gz"

# Install Go Package for Oracle DB connections
# Needs Oracle instant client installed at run time
echo "Installing Godror (Oracle Client) into ${GOPATH}..."
${GOROOT}/bin/go get github.com/godror/godror

# Install Go Methods for SQL Lite
echo "Installing SQL Lite Client into ${GOPATH}..."
${GOROOT}/bin/go get github.com/mattn/go-sqlite3

# Install Go Methods for Azure
echo "Installing Azure SDK for into ${GOPATH}..."
${GOROOT}/bin/go get -u -d github.com/Azure/azure-sdk-for-go/...

# Install Linux Debugger - gdb - VS Code needs delv for Go as the debugger# Install Go Language Debugger (Delve)
# go get needs git installed first
echo "Installing Go Debugger Dlv into ${GOPATH}..."
${GOROOT}/bin/go get github.com/go-delve/delve/cmd/dlv

echo "Installing Go Examples ${HOME}/go/src/github.com/inancgumus/learngo"
${GOROOT}/bin/go get https://github.com/inancgumus/learngo


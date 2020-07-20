#--- Makefile ----

# This how we want to name the binary output
BINARY=gover

# These are the values we want to pass for REPO, HASH, VERSION and BUILDDD
# git tag 1.0.1
# git commit -am "One more change after the tags"
REPO=`git remote get-url --all origin`
HASH=`git rev-parse HEAD`
VERSION=`git describe --tags --always --dirty --match=v* 2> /dev/null || echo v0`
# BUILDD=`git log -1 --format=%cd`
BUILDDATE=`date +%F\(%A\)`

# Ensure the following is setup in the main Go package
#var (
# 	Repo		string
#	Hash		string
#  	Version		string
# 	BuildDate	string
#)

# Setup the -ldflags option for go build here, interpolate the variable values
LDFLAGS=-ldflags "-w -s -X main.Repo=${REPO} -X main.Hash=${HASH} -X main.Version=${VERSION} -X main.BuildDate=${BUILDDATE}"
# Builds the project
build:
	go build ${LDFLAGS} -o ${BINARY}
	echo ${BUILDDATE}
    
# Installs our project: copies binaries
install:
	go install ${LDFLAGS}

# Cleans our project: deletes binaries
clean:
	if [ -f ${BINARY} ] ; then rm ${BINARY} ; fi

.PHONY: clean install
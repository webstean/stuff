#--- Makefile ----

# This how we want to name the binary output
BINARY=gover

# These are the values we want to pass for REPO, HASH, VERSION and BUILDDD
# git tag 1.0.1
# git commit -am "One more change after the tags"
REPO=`git remote get-url --all origin`
HASH=`git rev-parse HEAD`
VERSION=`git describe --abbrev=0 --tags --always --match=v* 2> /dev/null || echo v0`
# BUILDD=`git log -1 --format=%cd`
BUILDDATE=`date +%F\(%A\)`

# Ensure the following is setup in the main Go package
#var (
# 	Repo		string
#	Hash		string
#  	Version		string
# 	BuildDate	string
#)

# Go Platforms
# run the following for a list
# go tool dist list

PLATFORMS1=linux windows
PLATFORM_ARCHITECTURES1=amd64

PLATFORMS2=aix
PLATFORM_ARCHITECTURES2=ppc64

# Setup the -ldflags option for go build here, interpolate the variable values
LDFLAGS=-ldflags "-X main.Repo=${REPO} -X main.Hash=${HASH} -X main.Version=${VERSION} -X main.BuildDate=${BUILDDATE}"

# Build the project - default architecture and platform
build:
	echo ${BUILDDATE}
	go get github.com/sirupsen/logrus
	go get github.com/fsnotify/fsnotify
	go build ${LDFLAGS} -o ${BINARY}

build_all:
	$(foreach GOOS, $(PLATFORMS1),\
	$(foreach GOARCH, $(PLATFORM_ARCHITECTURES1), $(shell export GOOS=$(GOOS); export GOARCH=$(GOARCH); go build -v -o $(BINARY)-$(GOOS)-$(GOARCH))))

	$(foreach GOOS, $(PLATFORMS2),\
	$(foreach GOARCH, $(PLATFORM_ARCHITECTURES2), $(shell export GOOS=$(GOOS); export GOARCH=$(GOARCH); go build -v -o $(BINARY)-$(GOOS)-$(GOARCH))))
	    
# Installs our project: copies binaries
install:
	go install ${LDFLAGS}

# Cleans our project: deletes binaries
clean:
	if [ -f ${BINARY} ] ; then rm ${BINARY} ; fi
	if [ -f ${BINARY}-* ] ; then rm ${BINARY}-* ; fi

.PHONY: check clean install build_all all



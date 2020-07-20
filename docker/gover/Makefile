#--- Makefile ----

# This how we want to name the binary output
BINARY=gover

# These are the values we want to pass for VERSION and BUILD
# git tag 1.0.1
# git commit -am "One more change after the tags"
REPO=`git remote get-url --all origin`
HASH=`git rev-parse HEAD`
VERSION=`git describe --tags`
BUILDD=`git log -1 --format=%cd`

# Ensure the following is setup in the main package
#var (
# 	Repo		string
#	Hash		string
#  	Version		string
# 	BuildDate	string
#)

# Setup the -ldflags option for go build here, interpolate the variable values
LDFLAGS_f1=-ldflags "-w -s -X main.Repo=${REPO} -X main.Build.Hash=${HASH} -X main.Build.Version=${VERSION} -X main.Build.BuildDate=${BUILDD}"

# Builds the project
build:
	echo build ${LDFLAGS_f1} -o ${BINARY}
    
# Installs our project: copies binaries
install:
	go install ${LDFLAGS_f1}

# Cleans our project: deletes binaries
clean:
	if [ -f ${BINARY} ] ; then rm ${BINARY} ; fi

.PHONY: clean install
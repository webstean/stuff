FROM golang:alpine as build-env

WORKDIR /app

ENV GIT_URL="https://github.com/webstean/stuff.git"
ENV GO111MODULE=off

RUN apk update && \
	apk upgrade && \
	apk --no-cache add git unzip ca-certificates && git clone ${GIT_URL} 

RUN cd /app/stuff/docker/gover && go build -ldflags "-X main.GitCommit=$GIT_COMMIT" -o test2



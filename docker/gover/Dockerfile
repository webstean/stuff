FROM golang:alpine as build-env

WORKDIR /app

ENV GIT_URL="https://github.com/webstean/momenton.git"
ENV GO111MODULE=on

RUN apk update && \
	apk upgrade && \
	apk --no-cache add git unzip ca-certificates

RUN git clone ${GIT_URL} && export GIT_COMMIT="$(git rev-list -1 HEAD)"

RUN set && cd /app && go build -ldflags "-X main.GitCommit=$GIT_COMMIT" -o test2



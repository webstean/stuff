# Usage: docker build --tag 'baresip-pulseaudio:latest' .

FROM ubuntu:latest as baresip-build
# FROM alpine:latest as baresip-build

# Ubuntu
ENV INSTALL="apt-get install --yes"
ENV UPDATE="apt-get update --yes"

LABEL maintainer="webstean@gmail.com"

# Set Timezone - on Ubuntu
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#RUN apt-get update && apt-get install -y locale-gen tzdata sudo git 
#RUN apt-get update && dpkg-reconfigure --frontend noninteractive tzdata
# Set Language - on Ubuntu
# ENV LANG=en_AU.UTF-8
ENV LANG=C
ENV LANGUAGE=${LANG}
ENV LC_ALL=${LANG}
#RUN locale-gen ${LANG} && dpkg-reconfigure --frontend noninteractive tzdata

# Set Timezone
ENV TZ=Australia/Melbourne
RUN echo Setting Timezeone ${TZ}
RUN apt-get update && apt-get install --yes tzdata && dpkg-reconfigure --frontend noninteractive tzdata

# Basics
RUN apt-get update && apt-get install --yes sudo git apt-utils 

# Enable sudo for all
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

ENV BHOME /baresip

# Install basic baresip dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install --yes build-essential pkg-config intltool libtool libjson-c-dev 
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install --yes libsndfile1-dev libasound2-dev libsndfile1-dev libspandsp-dev libopus-dev

# gstreamer dependencies
# RUN apt-get update && apt-get install --yes gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-x libgstreamer-plugins-base1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev

# Jack audio dependencies
RUN apt-get update && apt-get install --yes libjack-jackd2-dev

# ALSA & Pulse Audio dependencies
RUN apt-get update && apt-get install --yes alsa-utils libpulse-dev

# Video Dependencies
# RUN apt-get update && apt-get install --yes libavcodec-dev libavutil-dev libcairo2-dev libgtk2.0-dev 

# Clone github repositories 
RUN git clone https://github.com/baresip/re ${BHOME}/re
RUN git clone https://github.com/baresip/rem ${BHOME}/rem
RUN git clone https://github.com/baresip/baresip ${BHOME}/baresip

# Build & Install baresip dependency re
RUN cd ${BHOME}/re && make RELEASE=1 && make RELEASE=1 install
# Build & Install baresip dependency rem
RUN cd ${BHOME}/rem && make && make install

# SSL Support
#RUN git clone https://github.com/openssl/openssl ${BHOME}/openssl
# Build & Install openssl
#RUN cd  ${BHOME}/openssl && ./config && make install
# SSL: Build & Install libzrtp
#RUN git clone https://github.com/juha-h/libzrtp ${BHOME}/libzrtp
#RUN cd  ${BHOME}/libzrtp && ./bootstrap.sh && ./configure CFLAGS="-O0 -g3 -W -Wall -DBUILD_WITH_CFUNC -DBUILD_DEFAULT_CACHE -DBUILD_DEFAULT_TIMER" && make install
# Build & Install baresip - with SSL (which will include ZRTP)
#RUN cd  ${BHOME}/baresip && make && make install && ldconfig

# Create example certificate
#RUN mkdir -p  ${BHOME}/certificate && \
#    openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out  ${BHOME}/certificate/example.crt -keyout /baresip/certificate/example.key \
#    -subj "/C=AU/ST=Victoria/L=Melbourne/O=webstean/OU=IT/CN=webstean.com" && \
#    cat  ${BHOME}/certificate/example.crt  ${BHOME}/certificate/example.key >  ${BHOME}/certificate/example.pem
#end SSL support

# OR

# Build & Install baresip - withOUT SSL
RUN cd ${BHOME}/baresip && make USE_TLS= USE_OPENSSL= && make USE_TLS= USE_OPENSSL= install && ldconfig

RUN ldd /usr/local/bin/baresip
RUN bin/false

FROM ubuntu:latest as baresip-run
# FROM alpine:latest as baresip-run

# AU Localisation
ENV TZ=Australia/Melbourne
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata
ENV LANG="en_AU.UTF-8"
ENV LANGUAGE="en_AU:en" 

ENV BHOME /baresip
WORKDIR /baresip

RUN mkdir -p ${BHOME}/etc && mkdir -p ${BHOME}/certificate && mkdir -p ${BHOME}/modules && mkdir -p ${BHOME}/wav

COPY --from=baresip-build /usr/local/bin/baresip /usr/local/bin/baresip
COPY --from=baresip-build /usr/local/lib/libre.so /usr/local/lib/libre.so
COPY --from=baresip-build /usr/local/lib/libre.a /usr/local/lib/libre.a
COPY --from=baresip-build /usr/local/lib/librem.so /usr/local/lib/librem.so
COPY --from=baresip-build /usr/local/lib/librem.a /usr/local/lib/librem.a
COPY --from=baresip-build /usr/local/lib/baresip /usr/local/lib/baresip
COPY --from=baresip-build /usr/local/share/baresip /usr/local/share/baresip

COPY --from=baresip-build /usr/lib/x86_64-linux-gnu/gstreamer-1.0 /usr/lib/x86_64-linux-gnu/gstreamer-1.0
COPY --from=baresip-build /usr/lib/x86_64-linux-gnu/libgst* /usr/lib/x86_64-linux-gnu/
COPY ./testcall.mp3 /testcall.mp3

COPY --from=baresip-build /baresip/certificate              ${BHOME}/certificate
COPY --from=baresip-build /usr/local/lib/baresip/modules    ${BHOME}/modules
COPY --from=baresip-build /usr/local/share/baresip          ${BHOME}/wav
COPY --from=baresip-build /usr/local/bin/baresip            ${BHOME}
COPY --from=baresip-build /usr/local/lib                    /usr/local/lib

COPY etc/accounts /etc/baresip
COPY etc/config /etc/baresipc
COPY etc/contacts /etc/baresip

# Setup Pulseaudio client -  talks to pulse server running on host
ENV UNAME pacat
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes pulseaudio-utils
# Set up the pulse user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio
COPY pulse-client.conf /etc/pulse/client.conf

# run client
USER $UNAME
ENV HOME /home/pacat
CMD ["pacat", "-vvvv", "/dev/urandom"]

## RUN ldconfig
## Ports for Service (SIP,RTP) and Control (HTTP,TCP)
EXPOSE 5060 5061 10000-10020 8000 5555

COPY ./docker-entrypoint.sh /

RUN ldconfig && apt-get update && apt-get --no-install-recommends -y install libasound2-dev libasound2 libasound2-data libsndfile1-dev gstreamer0.10-alsa alsa-oss alsa-utils module-init-tools libgstreamer1.0-dev  \
    && ldconfig \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && $HOME/dummy.sh

RUN lld /usr/local/bin/baresip

# Default Baresip run command arguments
CMD ["baresip", "-f","/root/.baresip"]

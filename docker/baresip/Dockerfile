# Usage: docker build --tag 'baresip-pulseaudio:latest' .

FROM ubuntu:latest as baresip-build

LABEL maintainer="webstean@gmail.com"

# Localisation
ENV TZ=Australia/Melbourne
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y tzdata sudo git 
ENV LANG="en_AU.UTF-8"
ENV LANGUAGE="en_AU:en" 

# Enable sudo for all
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

WORKDIR /baresip

RUN git clone https://github.com/openssl/openssl 
RUN git clone https://github.com/baresip/re
RUN git clone https://github.com/baresip/rem 
RUN git clone https://github.com/baresip/baresip
RUN git clone https://github.com/juha-h/libzrtp

# Install Build Dependencies
RUN apt-get update && apt-get install -y build-essential pkg-config 
#RUN apt-get update && apt-get install --yes pkg-config alsa-utils libasound2-dev libpulse-dev intltool libtool libsndfile1-dev libjson-c-dev libopus-dev
#RUN apt-get update && apt-get install --yes gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-x 
#RUN apt-get update && apt-get install --yes libgstreamer-plugins-base1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev
#RUN apt-get update && apt-get install --yes libsndfile1-dev libspandsp-dev libgtk2.0-dev libjack-jackd2-dev

# Video Dependencies
# RUN apt-get install --yes libavcodec-dev libavutil-dev libcairo2-dev

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

RUN ls -la /usr/local/bin/

# all as root

# Build & Install libzrtp
RUN cd /baresip/libzrtp && ./bootstrap.sh && ./configure CFLAGS="-O0 -g3 -W -Wall -DBUILD_WITH_CFUNC -DBUILD_DEFAULT_CACHE -DBUILD_DEFAULT_TIMER" && make install
# Build & Install openssl
RUN cd /baresip/openssl && ./config && make install
# Build & Install re
RUN cd /baresip/re && make RELEASE=1 install
# Build & Install rem
RUN cd /baresip/rem && make install
# Build & Install baresip - with SSL
RUN cd /baresip/baresip && make && make install
# Build & Install baresip - withOUT SSL
RUN cd /baresip/baresip && make USE_TLS= USE_OPENSSL= && make USE_TLS= USE_OPENSSL= install
# ldconfig
RUN ldconfig

# Create example certificate
RUN mkdir -p /baresip/certificate && \
    openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /baresip/certificate/example.crt -keyout /baresip/certificate/example.key \
    -subj "/C=AU/ST=Victoria/L=Melbourne/O=webstean/OU=IT/CN=webstean.com" && \
    cat /baresip/certificate/example.crt /baresip/certificate/example.key > /baresip/certificate/example.pem

FROM ubuntu:latest as baresip-run

WORKDIR /baresip

RUN mkdir -p /baresip/etc && mkdir -p /baresip/certificate && mkdir -p /baresip/modules && mkdir -p /baresip/wav

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

COPY --from=baresip-build /baresip/certificate              /baresip/certificate
COPY --from=baresip-build /usr/local/lib/baresip/modules    /baresip/modules
COPY --from=baresip-build /usr/local/share/baresip          /baresip/wav
COPY --from=baresip-build /usr/local/bin/baresip            /baresip
COPY --from=baresip-build /usr/local/lib                    /usr/local/lib

COPY etc/accounts /baresip/etc
COPY etc/config /baresip/etc

## RUN ldconfig
## Ports for Service (SIP,RTP) and Control (HTTP,TCP)
EXPOSE 5060 5061 10000-10020 8000 5555

COPY ./docker-entrypoint.sh /

RUN ldconfig && apt-get update && apt-get --no-install-recommends -y install libasound2-dev libasound2 libasound2-data libsndfile1-dev gstreamer0.10-alsa alsa-oss alsa-utils module-init-tools libgstreamer1.0-dev  \
    && ldconfig \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && $HOME/dummy.sh

# Default Baresip run command arguments
CMD ["baresip", "-f","/root/.baresip"]

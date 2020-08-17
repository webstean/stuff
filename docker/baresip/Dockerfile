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
RUN git clone https://github.com/creytiv/rem 
RUN git clone https://github.com/baresip/baresip
RUN git clone https://github.com/juha-h/libzrtp

# Install Build Dependencies
RUN apt-get update && apt-get install -y build-essential pkg-config 
#RUN apt-get update && apt-get install -y pkg-config alsa-utils libasound2-dev libpulse-dev intltool libtool libsndfile1-dev libjson-c-dev libopus-dev
#RUN apt-get update && apt-get install -y gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-x 
#RUN apt-get update && apt-get install -y libgstreamer-plugins-base1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev
#RUN apt-get update && apt-get install -y libsndfile1-dev libspandsp-dev libgtk2.0-dev libjack-jackd2-dev

# Video Dependencies
# RUN apt-get install -y libavcodec-dev libavutil-dev libcairo2-dev

RUN ls -la /usr/local/bin/

# all as root

# Install & Build libzrtp
RUN locale

#RUN cd /baresip/libzrtp && ./bootstrap.sh && ./configure CFLAGS="-O0 -g3 -W -Wall -DBUILD_WITH_CFUNC -DBUILD_DEFAULT_CACHE -DBUILD_DEFAULT_TIMER" && make install
#RUN false
# Install & Build openssl
RUN cd /baresip/openssl && ./config && make install
# Install & Build re
RUN cd /baresip/re && make RELEASE=1 install
# Install & Build rem
RUN cd /baresip/rem && make install
# Build baresip
RUN cd /baresip/baresip && make RELEASE=1 install-static
# ldconfig
RUN ldconfig

RUN mkdir -p /baresip/certificate && \
    openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /baresip/certificate/example.crt -keyout /baresip/certificate/example.key \
    -subj "/C=AU/ST=Victoria/L=Melbourne/O=webstean/OU=IT/CN=webstean.com" && \
    cat /baresip/certificate/example.crt /baresip/certificate/example.key > /baresip/certificate/example.pem

FROM ubuntu:latest as baresip-run

WORKDIR /baresip

RUN mkdir -p /baresip/etc
RUN mkdir -p /baresip/certificate
RUN mkdir -p /baresip/modules
RUN mkdir -p /baresip/wav

COPY --from=baresip-build /baresip/certificate              /baresip/certificate
COPY --from=baresip-build /usr/local/lib/baresip/modules    /baresip/modules
COPY --from=baresip-build /usr/local/share/baresip          /baresip/wav
COPY --from=baresip-build /usr/local/bin/baresip            /baresip
COPY --from=baresip-build /usr/local/lib                    /usr/local/lib

COPY etc/accounts /baresip/etc
COPY etc/config /baresip/etc

## RUN ldconfig

EXPOSE 5060

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["baresip"]

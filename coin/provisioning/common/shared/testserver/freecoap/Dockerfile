FROM qt_ubuntu_18.04
ARG packages="avahi-daemon autoconf automake libtool make libgnutls28-dev"
RUN apt-get update && apt-get -y install $packages

WORKDIR /root/src
ADD FreeCoAP-*.tar.gz .
RUN mv FreeCoAP-* FreeCoAP
WORKDIR /root/src/FreeCoAP
# Replace the bundled test certificates, which expired on 2026-11-01
COPY certs/ certs/
RUN autoreconf --install && ./configure && make && make install
WORKDIR sample/time_server
RUN make
WORKDIR /

EXPOSE 5685/udp

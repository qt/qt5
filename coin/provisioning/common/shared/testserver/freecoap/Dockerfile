FROM ubuntu:18.04

RUN apt-get update && apt-get -y install git avahi-daemon autoconf automake libtool make libgnutls28-dev

RUN mkdir -p /root/src/

# Get FreeCoAP test server
WORKDIR /root/src
RUN git clone https://github.com/keith-cullen/FreeCoAP.git
WORKDIR /root/src/FreeCoAP
RUN autoreconf --install
RUN ./configure
RUN make
RUN make install
WORKDIR /root/src/FreeCoAP/sample/time_server
RUN make

WORKDIR /

EXPOSE 5685/udp

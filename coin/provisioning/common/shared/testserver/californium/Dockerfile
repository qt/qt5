FROM ubuntu:18.04

RUN apt-get update && apt-get -y install git maven default-jdk avahi-daemon

RUN mkdir -p /root/src/

# Get californium-based CoAP test server
WORKDIR /root/src
RUN git clone https://github.com/selart/californium.git
WORKDIR /root/src/californium
RUN mvn clean install -q -DskipTests

WORKDIR /

EXPOSE 5683/udp 5684/udp

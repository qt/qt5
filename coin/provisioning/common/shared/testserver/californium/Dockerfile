FROM qt_ubuntu_18.04
ARG packages="avahi-daemon maven default-jdk"
RUN apt-get update && apt-get -y install $packages

# Get californium-based CoAP test server
WORKDIR /root/src
ADD californium-*.tar.gz .
RUN mv californium-* californium
WORKDIR /root/src/californium
RUN mvn clean install -q -DskipTests
WORKDIR /

EXPOSE 5683/udp 5684/udp

FROM qt_ubuntu_18.04
ARG packages="avahi-daemon maven default-jdk patch"
RUN apt-get update && apt-get -y install $packages

# Get californium-based CoAP test server
WORKDIR /root/src
ADD californium-3.8.0.tar.gz .
RUN mv californium-* californium
WORKDIR /root/src/californium
ADD qt_changes.patch ./
RUN patch -p1 < qt_changes.patch
ADD californium-m2deps-3.8.0.tar.gz /root
RUN mvn clean install -o -q -DskipTests
WORKDIR /

EXPOSE 5683/udp 5684/udp

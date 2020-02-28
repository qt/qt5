FROM qt_ubuntu_18.04
ARG packages="avahi-daemon xinetd"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 7 7/UDP 13

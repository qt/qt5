FROM qt_ubuntu_18.04
ARG packages="avahi-daemon iptables"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 1357

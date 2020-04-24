FROM qt_ubuntu_16.04
ARG packages="avahi-daemon squid"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 3128-3130

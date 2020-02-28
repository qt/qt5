FROM qt_ubuntu_18.04
ARG packages="avahi-daemon squid"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 3128-3130

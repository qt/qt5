FROM qt_ubuntu_18.04
ARG packages="avahi-daemon dante-server"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 1080-1081

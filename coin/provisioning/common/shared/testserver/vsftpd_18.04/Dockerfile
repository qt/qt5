FROM qt_ubuntu_18.04
ARG packages="avahi-daemon vsftpd"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 20-21

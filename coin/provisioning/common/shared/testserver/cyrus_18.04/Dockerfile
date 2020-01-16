FROM qt_ubuntu_18.04
ARG packages="avahi-daemon cyrus-imapd"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $packages && dpkg -l $packages
EXPOSE 143 993

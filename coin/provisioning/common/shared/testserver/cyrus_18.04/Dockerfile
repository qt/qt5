FROM ubuntu:18.04
ARG packages="cyrus-imapd avahi-daemon"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $packages && dpkg -l $packages
EXPOSE 143 993

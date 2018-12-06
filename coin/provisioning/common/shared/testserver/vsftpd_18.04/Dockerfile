FROM ubuntu:18.04
ARG packages="vsftpd avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 20-21

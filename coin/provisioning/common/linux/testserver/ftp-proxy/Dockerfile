FROM ubuntu:16.04
ARG packages="ftp-proxy avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 2121

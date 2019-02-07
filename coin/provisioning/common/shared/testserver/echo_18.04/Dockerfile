FROM ubuntu:18.04
ARG packages="xinetd avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 7 7/UDP 13

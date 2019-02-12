FROM ubuntu:18.04
ARG packages="iptables avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 1357

FROM ubuntu:18.04
ARG packages="dante-server avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 1080-1081

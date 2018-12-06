FROM ubuntu:18.04
ARG packages="apache2 libcgi-session-perl avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 80 443

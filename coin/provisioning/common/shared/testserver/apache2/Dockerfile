FROM ubuntu:16.04
ARG packages="apache2 libcgi-session-perl wget avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 80 443

# install configurations and test data
RUN wget https://tools.ietf.org/rfc/rfc3252.txt

FROM ubuntu:16.04
ARG packages="gdebi-core wget avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
RUN wget http://ppa.launchpad.net/dajhorn/dante/ubuntu/pool/main/d/dante/dante-server_1.4.1-1_amd64.deb
RUN gdebi -n dante-server_1.4.1-1_amd64.deb
EXPOSE 1080-1081

# install configurations and test data
COPY danted /etc/init.d/
COPY danted-authenticating /etc/init.d/

FROM ubuntu:16.04
ARG packages="vsftpd ftp wget avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 20-21

# install configurations and test data
RUN wget https://tools.ietf.org/rfc/rfc3252.txt

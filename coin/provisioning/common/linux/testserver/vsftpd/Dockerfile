FROM ubuntu:16.04
RUN apt-get update && apt-get install -y vsftpd=3.0.3-3ubuntu2 ftp=0.17-33 wget avahi-daemon
EXPOSE 20-21

# install configurations and test data
RUN wget https://tools.ietf.org/rfc/rfc3252.txt

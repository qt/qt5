FROM qt_ubuntu_16.04
ARG packages="avahi-daemon vsftpd ftp"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 20-21

# install configurations and test data
COPY rfc3252.txt .

FROM qt_ubuntu_16.04
ARG packages="avahi-daemon"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
COPY dante-server_1.4.1-1_amd64.deb .
RUN  apt -y install ./dante-server_1.4.1-1_amd64.deb  \
  && rm -f          ./dante-server_1.4.1-1_amd64.deb
EXPOSE 1080-1081

# install configurations and test data
COPY danted /etc/init.d/
COPY danted-authenticating /etc/init.d/

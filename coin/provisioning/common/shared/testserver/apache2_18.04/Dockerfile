FROM qt_ubuntu_18.04
ARG packages="avahi-daemon apache2 libcgi-session-perl"
RUN apt-get update && apt-get install -y $packages && dpkg -l $packages
EXPOSE 80 443

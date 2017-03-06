# gstreamer 1 for QtMultimedia
# gtk3 style for QtGui/QStyle
# libusb1 for tqtc-boot2qt/qdb
# speech-dispatcher-devel for QtSpeech, otherwise it has no backend on Linux

sudo yum install -y \
    gstreamer1-devel gstreamer1-plugins-base-devel \
    gtk3-devel \
    libusb1-devel \
    speech-dispatcher-devel


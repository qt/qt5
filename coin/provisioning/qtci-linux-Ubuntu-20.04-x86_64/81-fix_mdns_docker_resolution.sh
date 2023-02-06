#!/bin/bash

# The new version of libnss-mdns resolver library automatically rejects all
# hostnames with more than two labels (i.e. subdomains deep), for example
# vsftpd.test-net.qt.local is automatically rejected. The changes here fix
# this, see also https://github.com/lathiat/nss-mdns#etcmdnsallow

cat <<EOT | sudo tee /etc/mdns.allow
.local.
.local
EOT

sudo sed -i '/^hosts:/s/.*/hosts:          files mdns_minimal [NOTFOUND=return] mdns4 dns/'   /etc/nsswitch.conf

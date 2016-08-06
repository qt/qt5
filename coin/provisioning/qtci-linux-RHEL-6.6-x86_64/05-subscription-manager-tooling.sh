# provides: fix for possible bug in the subscription manager
# version: provided by RedHat
# needed for yum to work properly in case there is incorrect data in
# the sslclientkey repository parameter value
sudo rm -f /etc/pki/entitlement/*
sudo subscription-manager refresh

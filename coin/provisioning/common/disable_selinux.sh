# We need to disable selinux while we are overwriting some binaries
# required by it. If this is not done, ICU provisioning will create
# template that is not booting.

sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/g  /etc/selinux/config

# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside
sudo yum install -y python-devel python-virtualenv

# install the EPEL repository which provides python3
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
sudo rpm -Uvh epel-release-latest-6.noarch.rpm
sudo rm -f epel-release-latest-6.noarch.rpm

# install python3
sudo yum install -y python34-devel

# install pip3
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo rm -f get-pip.py
sudo pip3 install virtualenv

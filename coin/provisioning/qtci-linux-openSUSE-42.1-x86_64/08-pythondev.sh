# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside
sudo pkcon -y refresh
sudo pkcon -y install python-devel python-virtualenv

# install python3
sudo pkcon -y install python3 python3-pip python3-virtualenv

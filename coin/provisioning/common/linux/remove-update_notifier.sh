#!/usr/bin/env bash

installPackages+=(update-notifier)

if uname -a |grep -q "Ubuntu" ; then
installPackages+=(update-manager-core)
installPackages+=(update-manager)
installPackages+=(python3-distupgrade)
installPackages+=(python3-update-manager)
installPackages+=(ubuntu-release-upgrader-core)
fi

sudo apt -q -y remove "${installPackages[@]}"

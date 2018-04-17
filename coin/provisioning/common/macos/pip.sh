#!/usr/bin/env bash

function InstallPip {

    python=$1

    # Will install pip utility for python
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    sudo "$python" get-pip.py
    rm get-pip.py
}

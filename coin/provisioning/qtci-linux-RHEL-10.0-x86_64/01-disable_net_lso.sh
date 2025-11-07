#!/bin/sh

sudo ethtool -K ens3 tso off
ethtool -k ens3 | grep tcp-segmentation-offload  # Output: tcp-segmentation-offload: off

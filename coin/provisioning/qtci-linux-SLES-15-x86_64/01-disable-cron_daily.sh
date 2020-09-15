#!/usr/bin/env bash

set -ex

# this script will remove executable rights from cron.daily jobs
sudo chmod -x /etc/cron.daily/*


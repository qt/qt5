#!/bin/sh

# Make sure to shut down the machine cleanly when provisioning is done.

# +1 minute delay to make sure that the setup finishes
# and can clean up before being interrupted by the shutdown

sudo shutdown -h +1

#!/bin/sh

# OS X 10.8 and VMWare tools don't play well together.
# The shutdown command fails, so just shut down the machine
# manually when provisioning is done.

# +1 minute delay to make sure that the setup finishes
# and can clean up before being interrupted by the shutdown

sudo shutdown -h +1

#!/bin/bash
#(c)2018 Alces Flight Ltd. HPC Consulting Build Suite

#Undo cloudinit stuff
#Disable cloudinit on future boots
touch /etc/cloud/cloud-init.disabled

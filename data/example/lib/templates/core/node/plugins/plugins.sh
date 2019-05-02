#!/bin/bash

# Install Flight Manage
yum -y install flight-manage

# Create scripts directory
NODEDIR=/opt/service/nodescripts/<%= node.name %>
mkdir -p $NODEDIR

# Download scripts
curl <%= config.renderedurl %>/flightdirect.bash > $NODEDIR/flightdirect.bash 
curl <%= config.renderedurl %>/nfs.bash > $NODEDIR/nfs.bash 
curl <%= config.renderedurl %>/slurm.bash > $NODEDIR/slurm.bash 

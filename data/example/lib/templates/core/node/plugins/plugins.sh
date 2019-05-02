#!/bin/bash

# Install Flight Manage
yum -y install flight-manage

# Create scripts directory
NODEDIR=/opt/service/nodescripts/<%= node.name %>
mkdir -p $NODEDIR

# Download scripts
curl <%= config.renderedurl %>/flightdirect.sh > $NODEDIR/flightdirect.sh 
curl <%= config.renderedurl %>/nfs.sh > $NODEDIR/nfs.sh 
curl <%= config.renderedurl %>/slurm.sh > $NODEDIR/slurm.sh 

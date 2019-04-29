#!/bin/bash
#FLIGHTdescription: Install Flight Direct
#FLIGHTstages: first

CACHESERVER=<%= nodes.gateway1.config.networks.network1.ip %>
VERSION=2.4.1

<% if (node.config.gateway rescue false) -%>
# Setup cache server
curl -L https://raw.githubusercontent.com/alces-software/flight-direct/master/scripts/bootstrap.sh | bash -s $VERSION

source /etc/profile

flight forge install flight-cache
flight cache snapshot $CACHESERVER
systemctl start flight-cache

# sleep to ensure server comes up
sleep 20
flight forge install flight-syncer

# Setup genders file
cat << EOD > /opt/flight-direct/etc/genders
################################################################################
##
## Alces Clusterware - Genders configuration
## Copyright (c) 2018 Alces Software Ltd
##
################################################################################
<% groups = [] -%>
<% NodeattrInterface.nodes_in_gender('compute').each do |node| -%>
<% groups << NodeattrInterface.genders_for_node(node).first -%>
<% end -%>
<% groups = groups.uniq -%>
<% groups.uniq.each do |group| -%>
<%= NodeattrInterface.hostlist_nodes_in_gender(group) %>    <%= group %>,compute
<% end -%>
EOD

# Generate munge key
mkdir -p /etc/munge
cat << EOD > /etc/munge/munge.key
$(dd if=/dev/urandom bs=1 count=1024)
EOD

# Share genders file
flight sync cache file /opt/flight-direct/etc/genders
flight sync cache file /etc/munge/munge.key

<% end -%>

<% unless (node.config.gateway rescue false) -%>
curl http://$CACHESERVER/flight-direct/bootstrap.sh | bash
source /etc/profile
ROLE=login
<% else %>
ROLE=compute
<% end -%>

flight config set role=$ROLE clustername=<%= config.cluster %>

flight forge install flight-$ROLE

<% if (node.config.gateway rescue false) -%>
# Enable sessions
flight session enable base/gnome

<% end -%>

flight sync add files genders
flight sync add files munge.key
flight sync run-sync

# Disable user gridware
sed -i 's/.*cw_GRIDWARE_allow_users=.*/cw_GRIDWARE_allow_users=false/g' /opt/flight-direct/etc/gridware.rc

# Enable storage types
flight storage enable base/s3

<% end -%>

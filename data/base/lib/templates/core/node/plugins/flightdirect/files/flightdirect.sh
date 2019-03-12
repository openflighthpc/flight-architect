cat << EOF > /var/lib/firstrun/scripts/flightdirect.bash
CACHESERVER=<%= node.plugins.flightdirect.config.flightdirect_cacheserver %>

<% if node.plugins.flightdirect.config.flightdirect_iscache -%>
# Setup cache server
curl -L https://raw.githubusercontent.com/alces-software/flight-direct/master/scripts/bootstrap.sh | bash -s <%= node.plugins.flightdirect.config.flightdirect_version %>

source /etc/profile

flight forge install flight-cache
flight cache snapshot \$CACHESERVER
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

# Share genders file
flight sync cache file /opt/flight-direct/etc/genders

<% end -%>

<% if node.plugins.flightdirect.config.flightdirect_isserver || node.plugins.flightdirect.config.flightdirect_isclient -%>
<% unless node.plugins.flightdirect.config.flightdirect_iscache -%>
curl http://\$CACHESERVER/flight-direct/bootstrap.sh | bash
source /etc/profile
<% end -%>

<% if node.plugins.flightdirect.config.flightdirect_isclient -%>
ROLE=compute
<% elsif node.plugins.flightdirect.config.flightdirect_isserver -%>
ROLE=login
<% end -%>

flight config set role=\$ROLE clustername=<%= config.cluster %>

flight forge install flight-\$ROLE

<% if node.plugins.flightdirect.config.flightdirect_isserver -%>
# Enable sessions
flight session enable base/gnome

<% end -%>

flight sync add files genders
flight sync run-sync

# Disable user gridware
sed -i 's/.*cw_GRIDWARE_allow_users=.*/cw_GRIDWARE_allow_users=false/g' /opt/flight-direct/etc/gridware.rc

# Enable storage types
flight storage enable base/s3

<% end -%>

EOF

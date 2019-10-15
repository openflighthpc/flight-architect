#!/bin/bash
#FLIGHTdescription: Install Flight Environment
#FLIGHTstages: second

yum install -y https://openflighthpc.s3-eu-west-1.amazonaws.com/repos/openflight/x86_64/openflighthpc-release-1-1.noarch.rpm
yum install -y https://alces-flight.s3-eu-west-1.amazonaws.com/repos/alces-flight/x86_64/alces-flight-release-1-1.noarch.rpm

#
# Flight Starter
#
yum -y install flight-starter

#
# Flight Environment
#
yum -y install flight-env flight-desktop

# Set cluster name
/opt/flight/bin/flight config set cluster.name $NAMETEXT

# Allow user SSH login
mkdir -p /users/flight/.ssh/
echo "$USERSSHKEY" >> /users/flight/.ssh/authorized_keys
chmod 600 /users/flight/.ssh/authorized_keys
chown -R flight:flight /users/flight

# Install VTE for srun over terminal
yum install -y vte vte-profile

# Create genders file
cat << EOF > /opt/flight/etc/genders
<% groups.each do |group| -%>
<% next if group.name == 'orphan' -%>
<%= group.hostlist_nodes %>    <%= "#{group.name},#{group.config.role},#{group.answer.secondary_groups},all".split(',').uniq.reject(&:empty?).join(',')  %>
<% end -%>
<% orphan_list.each do |node| -%>
<%= node %>    orphan
<% end -%>
EOF

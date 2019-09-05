#!/bin/bash
#FLIGHTdescription: Install Flight Environment
#FLIGHTstages: second

#
# Prerequisite
#
yum -y install git

#
# Flight Direct 
#
curl https://openflighthpc.s3-eu-west-1.amazonaws.com/repos/openflight/openflight.repo > /etc/yum.repos.d/openflight.repo
yum -y install flight-runway

#
# Flight Starter
#
git clone https://github.com/openflighthpc/flight-starter /tmp/flight-starter
cp -Rv /tmp/flight-starter/dist/* /
rm -rf /tmp/flight-starter

#
# Flight Environment
#
cd /opt/flight/opt
git clone https://github.com/alces-flight/flight-env flight-env
/opt/flight/bin/flintegrate /opt/flight/opt/flight-env

flight set always on

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

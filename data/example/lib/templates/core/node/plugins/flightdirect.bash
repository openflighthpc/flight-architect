#!/bin/bash
#FLIGHTdescription: Install Flight Direct
#FLIGHTstages: second

VERSION=2.1.4

unset RUBYLIB RUBYOPT
unset $(env | grep ^BUNDLE | cut -f1 -d=)

curl -L https://raw.githubusercontent.com/alces-software/flight-direct/master/scripts/bootstrap.sh | bash -s $VERSION
source /etc/profile

unset RUBYLIB RUBYOPT
unset $(env | grep ^BUNDLE | cut -f1 -d=)

<% if (node.config.gateway rescue false) -%>
ROLE=login
<% else -%>
ROLE=compute
<% end -%>

flight config set role=$ROLE clustername=<%= config.cluster %>

flight forge install flight-$ROLE

<% if (node.config.gateway rescue false) -%>
# Enable sessions
flight session enable base/gnome
<% end -%>

# Disable user gridware
sed -i 's/.*cw_GRIDWARE_allow_users=.*/cw_GRIDWARE_allow_users=false/g' /opt/flight-direct/etc/gridware.rc

# Add OpenFlight branding
curl https://openflighthpc-compute.s3.eu-west-2.amazonaws.com/banner/openflight.sh > /opt/flight-direct/scripts/openflight.sh
sed -i 's,scripts/moosebird,scripts/openflight,g' /opt/flight-direct/etc/profile.d/01-banner.sh

# Enable storage types
flight storage enable base/s3

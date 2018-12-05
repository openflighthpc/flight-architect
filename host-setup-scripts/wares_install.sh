#!/bin/bash

DATE=$(date +%Y%m%d)

UNDERWARE_VERSION=0.3.0
METALWARE_VERSION=develop
CLOUDWARE_VERSION=0.1.0.pre3
ADMINWARE_VERSION=2018.2.0
USERWARE_VERSION=feature/simple-group-commands


# Tidy up
echo "Checking for existing installations..."
for i in underware metalware cloudware adminware; do 
  [ -d /opt/$i ] && mv /opt/$i /opt/$DATE-$i
  [ -d /var/lib/$i ] && mv /var/lib/$i /var/lib/$DATE-$i
done


# Underware
curl -sL https://raw.githubusercontent.com/alces-software/underware/master/scripts/bootstrap?installer/ | alces_OS=el7 alces_SOURCE_BRANCH=$UNDERWARE_VERSION /bin/bash
mkdir -p /var/lib/underware/repo/{.git,config,genders}
curl https://raw.githubusercontent.com/ColonelPanicks/mountain-climber-wip/master/underware/repo-to-be-included/config/domain.yaml > /var/lib/underware/repo/config/domain.yaml
curl https://raw.githubusercontent.com/ColonelPanicks/mountain-climber-wip/master/underware/repo-to-be-included/configure.yaml > /var/lib/underware/repo/configure.yaml
curl https://raw.githubusercontent.com/ColonelPanicks/mountain-climber-wip/master/underware/data/templates/genders > /var/lib/underware/repo/genders/default

# Metalware
curl -sL https://raw.githubusercontent.com/alces-software/metalware/master/scripts/bootstrap?installer | alces_OS=el7 alces_SOURCE_BRANCH=$METALWARE_VERSION /bin/bash

# Cloudware
curl -sL https://raw.githubusercontent.com/alces-software/cloudware/master/scripts/bootstrap | alces_OS=el7 alces_SOURCE_BRANCH=$CLOUDWARE_VERSION /bin/bash

# Adminware
cd /opt
git clone https://github.com/alces-software/adminware.git
cd adminware
git checkout $ADMINWARE_VERSION
make setup
cd /opt/adminware/bin
curl https://s3-eu-west-1.amazonaws.com/flightconnector/adminware/resources/sandbox-starter > sandbox-starter

# Userware
echo "checking for existing userware"
[ -d /opt/directory ] && mv /opt/directory /opt/$DATE-directory
[ -d /opt/share ] && mv /opt/share /opt/$DATE-share
[ -d /tmp/userware ] && rm -rf /tmp/userware

git clone https://github.com/alces-software/userware /tmp/userware
cd /tmp/userware
git checkout $USERWARE_VERSION
rsync -auv /tmp/userware/{directory,share} /opt/
cd /opt/directory/cli
make setup
mkdir /opt/directory/etc/
echo "cw_ACCESS_fqdn=$(hostname -f)" > /opt/directory/etc/access.rc
mkdir -p /var/www/html/secure
cd /opt/directory/cli/bin
# Download resources/sandbox-starter from this repo.
curl https://s3-eu-west-1.amazonaws.com/flightconnector/directory/resources/sandbox-starter > sandbox-starter


# Install branding for userware/adminware
mkdir -p /opt/flight/bin
cd /opt/flight/bin
# Download resources/banner from this repo.
curl https://s3-eu-west-1.amazonaws.com/flightconnector/directory/resources/banner > banner
chmod 755 banner

# Finishing messages
cat << EOF
===============================================================

The installation of all of the wares is complete.

There are still some additional things that require setting
up in order to get full functionality:

- IPAPASSWORD=MyIPApassHere into /opt/directory/etc/config
- Creation of clusteradmin user for adminware sandbox
- Creation of ipaadmin user for userware sandbox

===============================================================
EOF

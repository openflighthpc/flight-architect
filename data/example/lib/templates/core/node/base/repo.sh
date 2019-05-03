#!/bin/bash
#FLIGHTdescription: Setup additional repositories
#FLIGHTstage: first

# OpenFlight Repository
curl https://openflighthpc.s3-eu-west-1.amazonaws.com/repos/openflight/openflight.repo > /etc/yum.repos.d/openflight.repo

<% if (node.config.gateway rescue false) -%>
# Setup repo for SLURM RPMs
yum -y install createrepo httpd 
cat << EOF > /etc/httpd/conf.d/repo.conf
<Directory /opt/repo/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from <%= config.networks.network1.network %>/255.255.0.0
</Directory>
Alias /repo /opt/repo
EOF

systemctl enable httpd.service
systemctl restart httpd.service

mkdir -p /opt/repo/flight/packages
cd /opt/repo
createrepo flight
<% end -%>

cat << EOF > /etc/yum.repos.d/flight.repo
[flight]
name=flight
baseurl=http://<%= nodes.gateway1.config.networks.network1.ip %>/repo/flight
description=Flight RPMs and files
enabled=0
skip_if_unavailable=1
gpgcheck=0
priority=10
EOF

yum clean all

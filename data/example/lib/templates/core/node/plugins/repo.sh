#!/bin/bash
#FLIGHTdescription: Setup additional repositories
#FLIGHTstage: first

VERSION=18.08.7

# OpenFlight Repository
curl https://openflighthpc.s3-eu-west-1.amazonaws.com/repos/openflight/openflight.repo > /etc/yum.repos.d/openflight.repo

<% if (node.config.gateway rescue false) -%>
# Setup repo for SLURM RPMs
yum -y install creatrepo httpd 
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

# Build SLURM RPMs
yum -y install wget rpm-build munge munge-devel munge-libs perl-Switch numactl pam-devel perl-ExtUtils-MakeMaker mariadb-devel gcc libc
cd /tmp/
wget https://download.schedmd.com/slurm/slurm-$VERSION.tar.bz2
rpmbuild -ta slurm-$VERSION.tar.bz2

# Put RPMs in place
cp /root/rpmbuild/RPMS/x86_64/slurm-*.rpm /opt/repo/flight/packages/
cd /opt/repo
createrepo flight

<% end -%>

cat << EOF > /etc/yum.repos.d/flight.repo
[flight]
name=flight
baseurl=http://10.10.0.1/repo/flight
description=Flight RPMs and files
enabled=0
skip_if_unavailable=1
gpgcheck=0
priority=10
EOF

yum clean all

#!/bin/bash
#(c)2018 Alces Flight Ltd. HPC Consulting Build Suite

mkdir -p /root/.ssh
chmod 600 /root/.ssh
echo <%= config.publickey %> >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

echo "StrictHostKeyChecking no" >> /root/.ssh/config
chmod 600 /root/.ssh/config

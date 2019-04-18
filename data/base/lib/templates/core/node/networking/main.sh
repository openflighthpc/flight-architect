#!/bin/bash
#(c)2018 Alces Flight Ltd. HPC Consulting Build Suite

## SYSTEM SERVICES 
systemctl disable iptables
systemctl disable NetworkManager

mkdir -p /etc/systemd/system-preset
cat <<EOF > /etc/systemd/system-preset/00-flight-base.preset
disable libvirtd.service
disable NetworkManager.service
EOF

systemctl stop libvirtd
systemctl stop NetworkManager
##

##Basic Networking
echo "HOSTNAME=<%= config.networks.network1.hostname %>" >> /etc/sysconfig/network
echo "<%= config.networks.network1.hostname %>" > /etc/hostname

<% if (config.controllernetworking rescue false) || false -%>
cat << EOF > /etc/resolv.conf
search <%= config.searchdomains %>
nameserver <%= config.internaldns %>
EOF
<% end -%>
##


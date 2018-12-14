<% if (config.gateway rescue false) -%>
##Gateway
yum install -y firewalld
systemctl enable firewalld
systemctl start firewalld

# Ensure network1 interface is using external firewall zone
sed '/^ZONE=/{h;s/=.*/=external/};${x;/^$/{s//ZONE=external/;H};x}' /etc/sysconfig/network-scripts/ifcfg-<%= config.networks.network1.interface %> -i
firewall-cmd --remove-interface <%= config.networks.network1.interface %> --permanent
firewall-cmd --add-interface <%= config.networks.network1.interface %> --zone external --permanent
firewall-cmd --reload

##
<% end -%>

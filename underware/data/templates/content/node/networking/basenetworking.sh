#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%= config.jobid %>
#Cluster: <%= config.cluster %>

systemctl disable NetworkManager
service NetworkManager stop

echo "HOSTNAME=<%= config.networks.pri.hostname %>" >> /etc/sysconfig/network
echo "<%= config.networks.pri.hostname %>" > /etc/hostname

<% if config.dns_type.to_s == 'named' || node.name.to_s != 'local'  %>
<%= if node.name.to_s == 'local' then 'cat << FIRSTRUN > /var/lib/firstrun/scripts/resolv.bash' end %>
cat << EOF > /etc/resolv.conf
search <%= config.search_domains %>
nameserver <%= config.internaldns %>
EOF
<%= if node.name.to_s == 'local' then 'FIRSTRUN' end %>
<% else %>
cat << EOF > /etc/resolv.conf
search <%= config.search_domains %>
nameserver <%= config.externaldns %>
EOF
<% end %>

<% if config.firewall.enabled -%>
systemctl enable firewalld

install_file firewall_main.bash /var/lib/firstrun/scripts/firewall_main.bash
<% else -%>
systemctl disable firewalld
systemctl stop firewalld
<% end -%>

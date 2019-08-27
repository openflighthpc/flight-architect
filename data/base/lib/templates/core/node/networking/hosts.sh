cat << EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

<% nodes.each do |node| -%>
<% node.config.networks.each do |name, network| -%>
<% if network.defined -%>
<%= network.ip %> <%= network.hostname  %> <%= network.short_hostname -%> <%= network.primary ? node.config.networks[name].hostname.split(/\./).first : '' %>
<% end -%>
<% end %>
<% end -%>
EOF

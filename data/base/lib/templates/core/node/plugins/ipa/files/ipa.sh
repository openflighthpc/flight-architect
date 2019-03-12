#!/bin/bash
<% if node.plugins.ipa.config.ipa_serverip != config.networks.pri.ip.to_s -%>

# Update resolv.conf
cat << EOF > /etc/resolv.conf
search <%= config.search_domains %>
nameserver <%= node.plugins.ipa.config.ipa_serverip %>
EOF

# Install packages
yum -y install ipa-client ipa-admintools

# Enroll host (using firstrun script)
cat << EOF > /var/lib/firstrun/scripts/ipaenroll.bash
REALM="<%= config.networks.pri.domain.upcase %>.<%= config.domain.upcase %>"
ipa-client-install --no-ntp --mkhomedir --no-ssh --no-sshd --force-join --realm="\$REALM" --server="<%= node.plugins.ipa.config.ipa_servername %>.<%= config.networks.pri.domain %>.<%= config.domain %>" -w "<%= node.plugins.ipa.config.ipa_insecurepassword %>" --domain="<%= config.networks.pri.domain %>.<%=config.domain %>" --unattended --hostname='<%= config.networks.pri.hostname.downcase %>'
EOF
<% end -%>

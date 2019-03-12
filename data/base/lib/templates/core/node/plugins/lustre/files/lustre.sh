yum -y install kernel-devel
<% if (node.plugins.lustre.config.lustre_isserver rescue false) -%>
yum -y --enablerepo lustre-el7-server --enablerepo e2fsprogs-el7 update
yum -y --enablerepo lustre-el7-server --enablerepo e2fsprogs-el7 install lustre kmod-lustre-osd-ldiskfs

cat << EOF > /etc/modprobe.d/lustre.conf
options lnet networks=<%= node.plugins.lustre.config.lustre_networks %>
options ost oss_num_threads=96
options mdt mds_num_threads=96
EOF

<% elsif (node.plugins.lustre.config.lustre_isclient rescue false) -%>

yum -y --enablerepo lustre-el7-client update
yum -y --enablerepo lustre-el7-client install lustre-client

cat << EOF > /etc/modprobe.d/lustre.conf
options lnet networks=<%= node.plugins.lustre.config.lustre_networks %>
EOF

MOUNTS=`cat << EOF
<% node.plugins.lustre.config.lustre_mounts.each do | mount, path | -%>
<%= path.server %>:<%= path.export %>    <%= mount %>    lustre    <%= if defined?(path.options) then path.options else 'defaults,_netdev' end -%>    0 0
<% end -%>
EOF`

echo "$MOUNTS" >> /etc/fstab

<% node.plugins.lustre.config.lustre_mounts.each do | mount, path | -%>
<% if path.defined -%>
mkdir -p <%= mount %>
<% end -%>
<% end -%>

<% end -%>

<% if config.networks.ib.defined -%>
# Infiniband/Lustre hang fix
cat << EOF > /etc/systemd/system/lustre.service
[Unit]
Description=Stop Lustre

[Service]
Type=oneshot
RemainAfterExit=true
ExecStop=/usr/local/sbin/stop-lustre

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /usr/local/sbin/stop-lustre
#!/bin/bash

/usr/bin/umount -f -a -t lustre
/usr/sbin/lustre_rmmod
EOF
chmod +x /usr/local/sbin/stop-lustre
systemctl daemon-reload
systemctl enable lustre --now
<% end -%>

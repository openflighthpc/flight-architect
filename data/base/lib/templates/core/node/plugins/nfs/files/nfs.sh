yum -y install nfs-utils

<% if (node.plugins.nfs.config.nfs_isserver rescue false) -%>
# Create export directories
<% node.plugins.nfs.config.nfs_exports.each do | path, opts | -%>
mkdir -p <%= path %>
<% end -%>

# Increase nfsd thread count
sed -ie "s/^#\RPCNFSDCOUNT.*$/\RPCNFSDCOUNT=32/g" /etc/sysconfig/nfs

EXPORTOPTS="<%= config.networks.pri.network %>/<%= config.networks.pri.netmask %>(rw,no_root_squash,sync)"

EXPORTS=`cat << EOF
<% node.plugins.nfs.config.nfs_exports.each do | path, opts | -%>
<%= path %>   <%= if defined?(opts.options) then opts.options else "#{config.networks.pri.network}/#{config.networks.pri.netmask}(rw,no_root_squash,sync)" end %>
<% end -%>
EOF`

echo "$EXPORTS" > /etc/exports

<% end -%>
<% if (!node.plugins.nis.config.nis_isserver rescue true) -%>

MOUNTS=`cat << EOF
<% node.plugins.nfs.config.nfs_mounts.each do | mount, path | -%>
<% if path.defined -%>
<%= path.server %>:<%= path.export %>    <%= mount %>    nfs    <%= if defined?(path.options) then path.options else 'intr,rsize=32768,wsize=32768,vers=3,_netdev' end -%>    0 0
<% end -%>
<% end -%>
EOF`

echo "$MOUNTS" >> /etc/fstab

<% node.plugins.nfs.config.nfs_mounts.each do | mount, path | -%>
<% if path.defined -%>
mkdir -p <%= mount %>
<% end -%>
<% end -%>

<% end -%>

systemctl enable nfs
systemctl restart nfs

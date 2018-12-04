#!/bin/bash
#(c)2018 Alces Flight Ltd. HPC Consulting Build Suite

info () {
  echo "INFO - $*"
}

export -f info

<% if (config.debug rescue false) -%>
info "Setting root password"
echo 'root:<%=config.root_password%>' | chpasswd -e
<% end -%>

info "Running base"
curl <%= config.renderedurl %>/base/main.sh  | /bin/bash -x

info "Running cloudimage"
curl <%= config.renderedurl %>/cloudimage/main.sh  | /bin/bash -x

info "Running networking"
curl <%= config.renderedurl %>/networking/main.sh  | /bin/bash -x
curl <%= config.renderedurl %>/networking/networking.sh  | /bin/bash -x
curl <%= config.renderedurl %>/networking/hosts.sh  | /bin/bash -x

info "Configuration complete - rebooting"
shutdown -r now

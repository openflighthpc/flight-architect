#!/bin/bash
info () {
  echo "INFO - $*"
}

export -f info

<% if (config.debug rescue false) -%>
info "Setting root password"
echo 'root:<%=config.root_password%>' | chpasswd -e
<% end -%>

info "Running base"
curl <%= config.renderedurl %>/core/base/main.sh  | /bin/bash -x

info "Running cloudimage"
curl <%= config.renderedurl %>/platform/cloudimage/main.sh  | /bin/bash -x

info "Running networking"
curl <%= config.renderedurl %>/core/networking/main.sh  | /bin/bash -x
curl <%= config.renderedurl %>/core/networking/networking.sh  | /bin/bash -x
curl <%= config.renderedurl %>/core/networking/gateway.sh  | /bin/bash -x
curl <%= config.renderedurl %>/core/networking/hosts.sh  | /bin/bash -x

info "Configuring repo"
curl <%= config.renderedurl %>/core/base/repo.sh  | /bin/bash -x

info "Configuring plugins"
curl <%= config.renderedurl %>/plugins/plugins.sh | /bin/bash -x

info "Configuration complete - rebooting"
shutdown -r +1 &

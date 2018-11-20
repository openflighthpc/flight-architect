# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.


$dev_path='/tmp/underware'
$script = <<SCRIPT
# Login as root and change to project dir.
echo 'sudo su -' > /home/vagrant/.bashrc
echo 'cd #{$dev_path}' >> /root/.bashrc

export alces_OS=el7
curl -sL http://git.io/underware-installer | /bin/bash

echo "pathmunge /opt/underware/opt/ruby/bin" > /etc/profile.d/underware-ruby.sh
. /etc/profile

cd #{$dev_path}
bundle install

yum install -y vim tree
SCRIPT


Vagrant.configure(2) do |config|
  config.vm.box = 'centos/7'
  config.vm.network "private_network", type: 'dhcp'
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder '.', $dev_path
  config.vm.provision 'shell', inline: $script

  # config.vm.provider :virtualbox do |vb|
  #   vb.gui = true
  # end
end

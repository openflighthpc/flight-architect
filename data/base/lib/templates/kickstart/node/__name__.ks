#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
# vim: set filetype=kickstart :

#MISC
text
reboot
skipx
install

#SECURITY
firewall --enabled
firstboot --disable
selinux --disabled

#AUTH
auth  --useshadow  --enablemd5
#GENERATE with openssl passwd -1 $PASSWD
rootpw --iscrypted <%= config.root_password %>

#LOCALIZATION
keyboard uk
lang en_GB
timezone  Europe/London

#REPOS
url --url=<%= node.config.yumrepo_buildurl %>

#DISK
%include /tmp/disk.part

#PRESCRIPT
%pre
echo '{ "node": "<%= node.name %>", "message": "Formatting disk" }' |ncat -u <%= config.build_server_ip %> 24680
set -x -v
exec 1>/tmp/ks-pre.log 2>&1

DISKFILE=/tmp/disk.part
bootloaderappend="<%= config.kernelappendoptions %>"
cat > $DISKFILE << EOF
<%= config.disksetup %>
EOF
%end

#PRE-INSTALL (after disk format, before package install)
%pre-install
echo '{ "node": "<%= node.name %>", "message": "Installing packages" }' |ncat -u <%= config.build_server_ip %> 24680
%end

#PACKAGES
%packages --ignoremissing

vim
emacs
xauth
xhost
xdpyinfo
xterm
xclock
tigervnc-server
ntpdate
vconfig
bridge-utils
patch
tcl-devel
gettext
wget
nmap-ncat

%end

#POSTSCRIPTS
%post --nochroot
set -x -v
exec 1>/mnt/sysimage/root/ks-post-nochroot.log 2>&1

ntpdate 0.centos.pool.ntp.org

%end
%post
set -x -v
exec 1>/root/ks-post.log 2>&1

# Example of using rendered Metalware file; this file itself also uses other
# rendered files.
echo '{ "node": "<%= node.name %>", "message": "Running post installation scripts" }' |ncat -u <%= config.build_server_ip %> 24680
curl <%= node.config.nodescripturl %> | /bin/bash -x | tee /tmp/mainscript-default-output

echo '{ "node": "<%= node.name %>", "message": "Build complete", "built": "true" }' |ncat -u <%= config.build_server_ip %> 24680
%end

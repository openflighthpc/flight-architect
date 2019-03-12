SLURMCONF=`cat << EOF
ClusterName=<%= config.domain %>
ControlMachine=<%= node.plugins.slurm.config.slurm_servername %>
SlurmUser=nobody
SlurmctldPort=6817
SlurmdPort=6818
AuthType=auth/munge
StateSaveLocation=/var/spool/slurm.state
SlurmdSpoolDir=/var/spool/slurmd.spool
SwitchType=switch/none
MpiDefault=none
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid
ProctrackType=proctrack/pgid
ReturnToService=1
SlurmctldTimeout=300
SlurmdTimeout=300
InactiveLimit=0
MinJobAge=300
KillWait=30
Waittime=0
SchedulerType=sched/backfill
SelectType=select/linear
FastSchedule=1
SlurmctldDebug=3
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdDebug=3
SlurmdLogFile=/var/log/slurm/slurmd.log
JobCompType=jobcomp/none
AccountingStorageLoc=/var/log/slurm/accounting
AccountingStorageType=accounting_storage/slurmdbd
JobAcctGatherType=jobacct_gather/linux
AccountingStorageHost=<%= node.plugins.slurm.config.slurm_servername %>
NodeName=<%= node.plugins.slurm.config.slurm_nodelist %> State=UNKNOWN
PartitionName=all Nodes=ALL Default=YES MaxTime=UNLIMITED
EOF
`

yum -y -e0 install munge munge-devel munge-libs perl-Switch numactl
yum --enablerepo alces -y -e 0 --nogpgcheck install slurm slurm-devel slurm-perlapi slurm-torque slurm-slurmd slurm-example-configs slurm-libpmi
<% if (node.plugins.slurm.config.slurm_isserver rescue false) -%>
yum -y -e0 install mariadb mariadb-test mariadb-libs mariadb-embedded mariadb-embedded-devel mariadb-devel mariadb-bench
yum --enablerepo alces -y --nogpgcheck install slurm-slurmctld slurm-slurmdbd
systemctl enable mariadb
systemctl enable slurmdbd
systemctl start mariadb

# Setup DB account and permissions
mysql -uroot -e "create user 'slurm'@'localhost' identified by '';"
mysql -uroot -e "grant all on slurm_acct_db.* TO 'slurm'@'localhost';"
mysql -uroot -e "CREATE DATABASE slurm_acct_db;"

# Create spool directory
mkdir -p /var/spool/slurm.state
chown nobody:nobody /var/spool/slurm.state

# Configure slurmdbd
cat << EOF > /etc/slurm/slurmdbd.conf
# Archive info
#ArchiveJobs=yes
#ArchiveDir="/tmp"
#ArchiveSteps=yes
#ArchiveScript=
#JobPurge=12
#StepPurge=1
#
# Authentication info
AuthType=auth/munge
#AuthInfo=/var/run/munge/munge.socket.2
#
# slurmDBD info
DbdAddr=localhost
DbdHost=localhost
#DbdPort=7031
SlurmUser=nobody
#MessageTimeout=300
DebugLevel=4
#DefaultQOS=normal,standby
LogFile=/var/log/slurm/slurmdbd.log
PidFile=/var/run/slurmdbd.pid
#PluginDir=/usr/lib/slurm
#PrivateData=accounts,users,usage,jobs
#TrackWCKey=yes#
# Database info
StorageType=accounting_storage/mysql
#StorageHost=localhost
#StoragePort=1234
StoragePass=""
StorageUser=slurm
#StorageLoc=slurm_acct_db
EOF

systemctl start slurmdbd
<% end -%>

echo '<%= node.plugins.slurm.config.slurm_mungekey %>' > /etc/munge/munge.key
chmod 400 /etc/munge/munge.key
chown munge /etc/munge/munge.key

systemctl enable munge
systemctl start munge

mkdir /var/log/slurm
chown nobody /var/log/slurm

echo "$SLURMCONF" > /etc/slurm/slurm.conf

<% if (node.plugins.slurm.config.slurm_isserver rescue false) -%>
# Configure cluster and users
sacctmgr -i add cluster <%= config.domain %>
sacctmgr -i add account siteadmin Description="Site admin users"
sacctmgr -i create user name=alces-cluster DefaultAccount=siteadmin
sacctmgr -i modify user alces-cluster set adminlevel=admin
sacctmgr -i modify user siteuser set adminlevel=operator

systemctl enable slurmctld
systemctl start slurmctld
<% else -%>
systemctl enable slurmd
systemctl start slurmd
<% end -%>

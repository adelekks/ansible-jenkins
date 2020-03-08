#!/bin/bash
############################################################################
###### Script to Update OS baseline for base on Linux system:
###### By Kenny A on 06/17/2014
############################################################################
#set -x
scp_x="scp -q -o StrictHostKeyChecking=no -o BatchMode=yes -o PasswordAuthentication=no"
ssh_x="ssh -q -o StrictHostKeyChecking=no -o BatchMode=yes -o PasswordAuthentication=no"
puser=puppet
phost=ftizsldpptm01
ex_logic=/etc/puppet/ftdc_environments/manifests/ex_logic_node.pp
# Purpose: Display pause prompt
# $1-> Message (optional)
function pause(){
local message="$@"
[ -z $message ] && message="Press [Enter] key to continue..."
read -p "$message" readEnterKey
}

# Purpose - Display a menu on screen
function show_menu(){
echo "		`date`"
echo "----------------------------------------------------------------------"
echo " 			Main Menu"
echo "----------------------------------------------------------------------"
echo "1. Increase swap space on Exalogic"
echo "2. Configure LVM for Exalogic"
echo "3. Make a backup of /home,/opt,/var and /usr dirs for Exalogic"
echo "4. Mount new file system and add it to fstab for Exalogic"
echo "5. Restore backup /home,/opt,/var and /usr dirs from tar for Exalogic"
echo "6. Setup yum repo for base OS baseline"
echo "7. Add Puppet clent to Puppet Master for Exalogic"
echo "8. Setup Puppet agent for base OS baseline"
echo "9. Disable The Iptables Firewall"
echo "10. Enable The Iptables Firewall"
echo "11. exit"
}

# Purpose - Display header message
# $1 - message
function write_header(){
local h="$@"
echo "---------------------------------------------------------------"
echo " ${h}"
echo "---------------------------------------------------------------"
}

##### Increase swap space on Exalogic
function swap_lvm(){
local h="$@"
write_header ' Increase swap space on Exalogic for base OS baseline '
read -p "Enter HostName: " sn
read -p "Enter Swap size: " size
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
Swap new size: $size
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
for i in $sn
  do
   echo $i
   $ssh_x $i 'sudo
/usr/sbin/lvextend -L+$sizeG /dev/VolGroup00/LogVol01
/sbin/mkswap /dev/VolGroup00/LogVol01
/sbin/swapon /dev/VolGroup00/LogVol01
/sbin/swapon -s'
done
echo "Reboot the system to see new swap add!!!"
pause
}

##### File System LVM layout for base OS base line
function gv_lvm(){
local h="$@"
write_header ' File System LVM layout for base OS base line '
read -p "Enter HostName: " sn
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
2G home VolGroup00
1G opt VolGroup00
4G tmp VolGroup00
8G usr VolGroup00
2G /usr/users VolGroup00
4G var VolGroup00
2G /var/core VolGroup00
10G oem VolGroup00
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
for i in $sn
  do
   echo $i
   $ssh_x -tty $i 'sudo
/usr/sbin/lvs |grep homelv >/dev/null
     if [ $? -eq 0 ]; then
        echo "LVM has been configure on the host skipping this step!!!"
else
/usr/sbin/lvcreate -L 2G -n homelv VolGroup00
/usr/sbin/lvcreate -L 1G -n optlv VolGroup00
/usr/sbin/lvcreate -L 4G -n tmplv VolGroup00
/usr/sbin/lvcreate -L 8G -n usrlv VolGroup00
/usr/sbin/lvcreate -L 2G -n userslv VolGroup00
/usr/sbin/lvcreate -L 4G -n varlv VolGroup00
/usr/sbin/lvcreate -L 2G -n corelv VolGroup00
/usr/sbin/lvcreate -L 10G -n oemlv VolGroup00
/sbin/mkfs.ext3 /dev/VolGroup00/homelv
/sbin/mkfs.ext3 /dev/VolGroup00/optlv
/sbin/mkfs.ext3 /dev/VolGroup00/tmplv
/sbin/mkfs.ext3 /dev/VolGroup00/usrlv
/sbin/mkfs.ext3 /dev/VolGroup00/userslv
/sbin/mkfs.ext3 /dev/VolGroup00/varlv
/sbin/mkfs.ext3 /dev/VolGroup00/corelv
/sbin/mkfs.ext3 /dev/VolGroup00/oemlv
fi'
done
pause
}

##### Make a backup of /home,/opt,/var and /usr dirs:
function backup_dir(){
local h="$@"
write_header ' Make a backup of /home,/opt,/var and /usr dirs: '
read -p "Enter HostName: " sn
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
mkdir /root/move/
tar -zcvpf /root/move/home.tar.gz /home
tar -zcvpf /root/move/opt.tar.gz /opt
tar -zcvpf /root/move/usr.tar.gz /usr
tar -zcvpf /root/move/var.tar.gz /var
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
for i in $sn
  do
   echo $i
   $ssh_x -tty $i 'sudo
ls -ld /root/move/* >/dev/null
     if [ $? -eq 0 ]; then
        echo "Home,opt,usr and var has been backup on the host skipping this step!!!"
else
/bin/mkdir /root/move/
/bin/tar -zcvpf /root/move/home.tar.gz /home
/bin/tar -zcvpf /root/move/opt.tar.gz /opt
/bin/tar -zcvpf /root/move/usr.tar.gz /usr
/bin/tar -zcvpf /root/move/var.tar.gz /var
rm -rf /home/*
rm -rf /opt
rm -rf /var/*
fi'
done
pause
}

##### Mount new file system
function mnt_file(){
local h="$@"
write_header ' Mount new file system and add it to fstab '
read -p "Enter HostName: " sn
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
mkdir /home
mkdir /opt
mkdir /tmp
mkdir /usr
mkdir /usr/users
mkdir /var
mkdir /var/core
mkdir /oem
update fstab
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
for i in $sn
  do
   echo $i
   $ssh_x -tty $i 'sudo
grep 'homelv' /etc/fstab >/dev/null
     if [ $? -eq 0 ]; then
        echo "fstab has been updated on the host skipping this step!!!"
else
cat << EOF >> /etc/fstab
/dev/mapper/VolGroup00-homelv /home             ext3    defaults        1 2
/dev/mapper/VolGroup00-optlv /opt               ext3    defaults        1 2
/dev/mapper/VolGroup00-tmplv /tmp               ext3    defaults        1 2
/dev/mapper/VolGroup00-usrlv /usr               ext3    defaults        1 2
/dev/mapper/VolGroup00-userslv /usr/users       ext3    defaults        1 2
/dev/mapper/VolGroup00-varlv /var               ext3    defaults        1 2
/dev/mapper/VolGroup00-corelv /var/core         ext3    defaults        1 2
/dev/mapper/VolGroup00-oemlv /oem               ext3    defaults        1 2
EOF
/bin/mount -a && /bin/mkdir -p /home /opt /tmp /usr/users /var/core /oem && /bin/mount -a
fi'
done
pause
}

##### Restore backup /home,/opt,/var and /usr dirs from tar
function restore_dir(){
local h="$@"
write_header ' Restore backup /home,/opt,/var and /usr dirs from tar '
read -p "Enter HostName: " sn
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
tar -zxvf /root/move/home.tar.gz
tar -zxvf /root/move/opt.tar.gz
tar -zxvf /root/move/usr.tar.gz
tar -zxvf /root/move/var.tar.gz
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
for i in $sn
  do
   echo $i
   $ssh_x -tty $i "sudo
cd /
tar -zxvf /root/move/home.tar.gz
tar -zxvf /root/move/opt.tar.gz
tar -zxvf /root/move/usr.tar.gz
tar -zxvf /root/move/var.tar.gz"
done
pause
}

#####
#echo "puppet@cmi" >/tmp/hidden
hidden="puppet@cmi"

##### Setup yum repo for base OS base line
function oel5_repo(){
local h="$@"
write_header ' Setup yum repo for base OS baseline '
read -p "Enter HostName: " sn
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
Yum Repo will be setup on $sn
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
for i in $sn
  do
   echo $i
   $ssh_x -tty $i 'sudo
grep "146.91.6.19" /etc/resolv.conf >/dev/null
     if [ $? -eq 0 ]; then
        echo " DNS has been configure on the host skipping this step!!!"
else
cat << EOF > /etc/resolv.conf
search ftdc.base.com ssdc.base.com cidc.base.com redc.base.com base.com
nameserver 146.91.6.19
nameserver 143.222.220.14
nameserver 143.222.220.20
EOF

cat << EOF > /etc/yum.repo.d/oel5.repo
[Server]
name=Server
baseurl=http://ftizsldppts01.ftdc.base.com/oel5.9/Server
enabled=1
gpgcheck=0
gpgkey=http://ftizsldppts01.ftdc.base.com/oel5.9/RPM-GPG-KEY-oracle

[Oracle-EBS]
name=Oracle-EBS
baseurl=http://ftizsldppts01.ftdc.base.com/oracle-ebs
enabled=1
gpgcheck=0
gpgkey=http://ftizsldppts01.ftdc.base.com/oel5.9/RPM-GPG-KEY-oracle

[Puppet-oel5]
name=Puppet-oel5 local repository
baseurl=http://ftizsldppts01/puppet-oel5
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
enabled=1
EOF

yum groupinstall core -y
nstall glibc-devel libaio libstdc++-devel pdksh unixODBC csh nfs-utils.x86_64 portmap sendmail.x86_64 gnupg mailx dos2unix redhat-lsb openmotif openmotif22 compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel xterm.x86_64 xorg-x11-xauth.x86_64 xorg-x11-utils.x86_64 -y
fi'
done
pause
}

##### Setup Puppet for base OS base line
function puppet_agent(){
local h="$@"
write_header ' Setup Puppet agent for base OS base line '
read -p "Enter HostName: " sn
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
Puppet agent will be install and configure on $sn
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
for i in $sn
  do
   echo $i
   $ssh_x -tty $i "sudo
ls -ld /etc/puppet >/dev/null
     if [ $? -eq 0 ]; then
        echo " Puppet has been installed and configure on the host skipping this step!!!"
else
yum  install puppet facter ruby ruby-libs -y
cat << EOF > /etc/puppet/puppet.conf
 [main]
    # The Puppet log directory.
    # The default value is '$vardir/log'.
    logdir = /var/log/puppet
    vardir=/var/lib/puppet
    # Where Puppet PID files are kept.
    # The default value is '$vardir/run'.
    rundir = /var/run/puppet

    # Where SSL certificates are kept.
    # The default value is '$confdir/ssl'.
    ssldir = $vardir/ssl
    factpath=$vardir/lib/facter
    templatedir=$confdir/templates

[agent]
    # The file in which puppetd stores a list of the classes
    # associated with the retrieved configuratiion.  Can be loaded in
    # the separate ``puppet`` executable using the ``--loadclasses``
    # option.
    # The default value is '$confdir/classes.txt'.
    classfile = $vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '$confdir/localconfig'.
    localconfig = $vardir/localconfig
    server=ftizsldppts01.ftdc.base.com
    pluginsync = true
    # These are needed when the puppetmaster is run by passenger
    # and can safely be removed if webrick is used.
    ssl_client_header = SSL_CLIENT_S_DN
    ssl_client_verify_header = SSL_CLIENT_VERIFY
EOF

puppet agent --test --waitforcert 0
puppet agent -t
service puppet start
chkconfig puppet on
fi"
done
pause
}

##### Disable The Iptables Firewall for base OS baseline
function fire_dis(){
local h="$@"
write_header ' Disable Iptables Firewall for base OS baseline '
read -p "Enter HostName: " sn
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
This will Disable Iptables Firewall will be setup on $sn
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
for i in $sn
  do
   echo $i
   $ssh_x -tty $i 'sudo
/etc/init.d/iptables save
/etc/init.d/iptables stop
chkconfig iptables off'
done
pause
}

##### Enable The Iptables Firewall for base OS baseline
function fire_en(){
local h="$@"
write_header ' Enable Iptables Firewall for base OS baseline '
read -p "Enter HostName: " sn
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
This will Enable Iptables Firewall will be setup on $sn
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
for i in $sn
  do
   echo $i
   $ssh_x -tty $i 'sudo
/etc/init.d/iptables start
chkconfig iptables on'
done
pause
}

##### Add Puppet clent to Puppet Master for base OS baseline
function puppet_mas(){
local h="$@"
write_header ' Add Puppet clent to Puppet Master for base OS baseline '
read -p "Enter Puppet clent full HostName: " sn
echo "***********************************************************"
echo "*** Please verify system info before you continue      ****"
echo "***********************************************************"
echo "***********************************************************
Hostname: $sn
This will update Puppet Master for $sn
***********************************************************"
read -p " press y to continue this Configuretion or press enter to exit: "
echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]
          then
              exit 1
        fi
yum install expect -y
for i in $sn
  do
   echo $i
/usr/bin/expect<<EOD
log_user 0
spawn    ssh $puser@$phost 'grep "$i" $ex_logic >/dev/null
     if [ \$? -eq 0 ]; then
        echo " Puppet has been added on Puppet Master skipping this step!!!"
else
cat << EOF >>$ex_logic
node '$i.base.com' {
     include exa_baseline
     include exa_nis
}
EOF
#[ $? -eq 0 ] && echo "$i has been added to Puppet Master!!!" || echo "Failed to add $i to Puppet Master!!!"
fi'
expect "password:"
send "$hidden\n"
log_user 1
expect eof
EOD
#rm /tmp/hidden
done
pause
}

##### Main ####
# Purpose - Get input via the keyboard and make a decision using case..esac
function read_input(){
local c
read -p "Enter your choice [ 1 - 11 ] " c
case $c in
1) swap_lvm ;;
2) gv_lvm ;;
3) backup_dir ;;
4) mnt_file ;;
5) restore_dir ;;
6) oel5_repo ;;
7) puppet_mas ;;
8) puppet_agent ;;
9) fire_dis ;;
10) fire_en ;;
11) echo "Bye!"; exit  ;;
*)
echo 'Please select between 1 to 11 choice only.'
pause
esac
}

# ignore CTRL+C, CTRL+Z and quit singles using the trap
trap '' SIGINT SIGQUIT SIGTSTP

# main logic
while true
do
clear
show_menu # display memu
read_input # wait for user input
done

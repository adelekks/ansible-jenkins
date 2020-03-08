#!/bin/bash 
#set -x
cat << EOF > /tmp/script.sh
#!/bin/bash
second_disk=`lsblk | grep "xvd" | grep -v "xvda" |awk '{print $1}'`
second_disk_list=`lsblk | grep "xvd" | grep -v "xvda" |awk '{print $1}' |wc -l`
user=`whoami`
if [ \${second_disk_list} == 0 ]
then
    echo "*************************************************************"
    echo "Please attach the second disk from swagger UI, exitting"
    echo "*************************************************************"
    exit 1
elif [ ! -d /home/\$user/filesystem ]
then
    echo "/home is not mounted,executing script"
    
    sudo mkdir -pv /tmp/fsbackup
#    sudo /bin/tar -zcvpf /tmp/fsbackup/home.tar.gz /home
    sudo /bin/tar -zcvpf /tmp/fsbackup/opt.tar.gz /opt
    sudo /bin/tar -zcvpf /tmp/fsbackup/var.tar.gz /var
    sudo /bin/tar -zcvpf /tmp/fsbackup/user.tar.gz /usr
    sudo rm -rf /opt
    sudo rm -rf /var
   
    if [ `lsblk | grep "xvd" | grep -v "xvda" |awk '{print \$1}' | wc -l` == 1 ]
    then

       #second_disk=`lsblk | grep "xvd" | grep -v "xvda" |awk '{print $1}'`
       cd /tmp
       sudo mount -a
#       tar -zxvf /tmp/fsbackup/home.tar.gz /
       mkdir -p /home/\$user/filesystem
       sudo tar -zxvf /tmp/fsbackup/usr.tar.gz -C /home/\$user/filesystem
       sudo tar -zxvf /tmp/fsbackup/opt.tar.gz -C /home/\$user/filesystem
       sudo tar -zxvf /tmp/fsbackup/var.tar.gz -C /home/\$user/filesystem 
       sudo ln -s /home/\$user/filesystem/var /var
       sudo ln -s /home/\$user/filesystem/opt /opt
       sudo ln -s /home/\$user/filesystem/opt /usr
    fi
fi
EOF
sudo sh /tmp/script.sh

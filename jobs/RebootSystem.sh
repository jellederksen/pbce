#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Reboot the remote host

jobname='RebootSystem'

reboot() {
#hdd='/dev/sdb /dev/sdc'
#for i in $hdd; do
#echo "n
#p
#1
#
#
#t
#8e
#w
#"|fdisk $i;
#done
	#/sbin/shutdown -r +1
#hdd='/dev/sdb1 /dev/sdc1'
#for i in $hdd; do
#	pvcreate $i
#	if [[ $i == /dev/sdc1 ]]; then
#		vgcreate logm_data $i
#		lvcreate -L "$(dmesg | grep "$(echo $i | awk -F[/1] '{print $3}')" | egrep 'GiB|TiB' | awk -F[/.] '{print $4}')" -n data logm_data
#	else
#		vgcreate logm_opt $i
#		lvcreate -L "$(dmesg | grep "$(echo $i | awk -F[/1] '{print $3}')" | egrep 'GiB|TiB' | awk -F[/.] '{print $4}')"G -n opt logm_opt
#	fi
#done
#lvscan | egrep 'logm_data|logm_opt'

#lvscan | egrep 'logm_data|logm_opt'

#lvremove -f "$(lvscan | grep '/dev/logm_data/data' | awk -F\' '{print $2}')"
#lvcreate -l "$(vgdisplay "logm_data" | grep 'Free  PE' | awk '{print $5}')"  -n data logm_data

#fsystem='/dev/mapper/logm_data-data /dev/mapper/logm_opt-opt'
#for i in $fsystem; do
#	mkfs.ext4 $i
#done
#sed -i 's|/dev/mapper/vg00-lvopt|#/dev/mapper/vg00-lvopt|g' /etc/fstab
#echo "/dev/mapper/logm_opt-opt  /opt            ext4    defaults        0 0" >> /etc/fstab
#echo "/dev/mapper/logm_data-data        /data            ext4    defaults        0 0" >> /etc/fstab
#cd /root
#tar -cvf opt_backup.tar /opt
#sed -i 's|/dev/mapper/logm_data-data        /opt            ext4    defaults        0 0|/dev/mapper/logm_data-data        /data            ext4    defaults        0 0|g' /etc/fstab
#grep 'vg00-lvopt' /etc/fstab
#/sbin/shutdown -r +1
#mount | egrep 'data|opt'
#mv /root/opt_backup.tar /
#cd /
#tar -xvf opt_backup.tar
#rm /opt_backup.tar
#df -h /opt
#df -h /data
#sed -i 's/server 145.222.16.132/server 172.16.88.4/g' /etc/ntp.conf
#sed -i 's/server 145.222.16.148/server 172.16.88.20/g' /etc/ntp.conf
#systemctl enable ntpd.service
#service ntpd start
#/sbin/shutdown -r +1
#hostname
#lshal | grep system.hardware.uuid | tr '[A-Z]' '[a-z]'
#dmidecode | grep UUID | tr '[A-Z]' '[a-z]'
/sbin/shutdown -r +1
#yum -y update
#systemctl disable chronyd.service
#systemctl enable ntpd.service
}

main() {
	check_root
	check_os
	reboot
	exit 0
}

main "${@}"

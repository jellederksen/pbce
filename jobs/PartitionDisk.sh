#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Partintion empty disk

jobname='PartitionDisk'

partitions_db='/proc/partitions'
null='/dev/null'

check_disk() {
	for i in "${hdd[@]}"; do
		if grep "${i}[0-9]" "$partitions_db" > "${null}" 2>&1; then
			echo "disk ${i} contains partitions"
			exit 99
		fi
	done
}

partition_disk() {
	for i in "${hdd[@]}"; do
echo "n
p
1


t
8e
w
"|fdisk "/dev/${i}";
	done
}

main() {
	check_root
	check_os
	check_disk
	partition_disk
	exit 0
}

main "${@}"

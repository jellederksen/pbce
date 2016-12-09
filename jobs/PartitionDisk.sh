#!/bin/bash
#
#Pbce job for adding users to a Linux system
#
#Version 0.1
#
#Copyright (c) 2016 Jelle Derksen jelle@epsilix.nl
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
#
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

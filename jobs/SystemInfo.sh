#!/bin/bash
#
#Display system information
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
#Gather information from a remote system in the form of arrays and
#variables you can use in the pbce host.conf file. You can use this
#script as an information extraction script.

jobname='SystemInfo'
debian_vers='/etc/debian_version'
redhat_vers='/etc/redhat-release'
passwd_file='/etc/passwd'

os_info() {
	#Print hostname variable
	echo "hostname='$(hostname -s)'"
	#Print OS and hardware type variable
	/bin/uname -a | while read os a b c d e f g h i j hw k; do
		echo "os_type='${os}'"
		echo "hw_type='${hw}'"
	done
	if [[ -f ${debian_vers} ]]; then
		echo "os_vers='$(< ${debian_vers})'"
	elif [[ -f ${redhat_vers} ]]; then
		echo "os_vers='$(< ${redhat_vers})'"
	else
		echo "os_vers=''"
	fi
}

net_info() {
	i='0'
	#Print networking info on system in array
	/sbin/ip -o -4 addr show | while read x if y ip z; do
		echo "net_if[${i}]='${if},${ip%%/[0-9]*},$(cdr_mask "${ip##*/}"),${ip##*/}'"
		(( i++ ))
	done
	i='0'
	#Print routes on system in array
	/sbin/ip route show | grep 'via' | while read net a gw b dev c; do
		echo "routing_table[${i}]='${net},${gw},${dev}'"
		(( i++ ))
	done
}

user_info() {
	OLD_IFS="${IFS}"
	IFS=':'
	i='0'
	while read user x uid gid full_name home_dir shell; do
		echo "user[${i}]='${user},${uid},${gid},${full_name},${home_dir},${shell}'"
		(( i++ ))
	done <"${passwd_file}"
	i='0'
	while read user a b c d home_dir e; do
		if [[ -f ${home_dir}/.ssh/authorized_keys ]]; then
			while read line; do
				echo "user_pubkey[${i}]='${user},${line}'"
				(( i++ ))
			done <"${home_dir}/.ssh/authorized_keys"
		fi
	done <"${passwd_file}"
	IFS="${OLD_IFS}"
}

daemon_info() {
	echo demo
}

main() {
	check_root
	check_os
	os_info
	net_info
	user_info
	exit 0
}

main "${@}"

#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
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
	OLD_IFS="$IFS"
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

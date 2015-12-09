#!/bin/bash
#
#Add Users On Host
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#All users in the array "$users[@]" will be added to the host this
#script is executed on. You can execute this script on multiple hosts
#by executing this script with the ssre.sh script. The correct syntax
#for the "$users[@]" variable can be seen in the example. Please mind
#the quotes arround the full_name part. You will need the quotes when
#using a space between the first and last name.
#
#Example add user accounts
#users[0]="group_name,full_name,'home_directory',prefered_shell,account_name"
#users[1]="jelle,'Jelle Derksen',/home/jelle,/bin/ksh,jelle"
#
#Example exclude host from script
#exclude_hosts[0]='foo.bar.com'
#exclude_hosts[1]='192.168.0.1'

#Script settings change to suit your needs.
users[0]="jelle,'Jelle Derksen',/home/jelle,/bin/ksh,jelle"
exclude_hosts[0]=''

#Do not edit below this point.
if [[ ! "$USER" = 'root' ]]; then
	echo 'need root privileges'
	exit 1
fi

if [[ ! "$(uname)" = 'Linux' ]]; then
	echo 'OS not Linux.'
	exit 1
fi

for host in "${exclude_hosts[@]}"; do
	if [[ "$host" = "$(hostname)" ]]; then
		exit 0
	elif [[ "$host" = "$(ip addr show | grep -F -o "$host")" ]]; then
		exit 0
	fi
done

for user in "${users[@]}"; do
	g="$(echo $user | awk -F, '{print $1}')"
	n="$(echo $user | awk -F, '{print $2}')"
	h="$(echo $user | awk -F, '{print $3}')"
	s="$(echo $user | awk -F, '{print $4}')"
	a="$(echo $user | awk -F, '{print $5}')"
	if [[ -z "$g" || -z "$n" || -z "$h" || -z "$s" || -z "$a" ]]; then
		echo "$user variable incorrect."
		exit 2
	fi
	if id "$account" > /dev/null 2>&1; then
		echo "$account already on $(hostname)."
		continue
	fi
	if useradd -g "$g" -c "$n" -d "$h" -s "$s" "$a"; then
		echo "$account added on host $(hostname)."
	else
		echo "Failed to add $account on host $(hostname)."
		exit 3
	fi
done

echo "All accounts added on host $(hostname)."
exit 0

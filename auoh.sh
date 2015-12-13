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
#Example: exclude host from script.
#exclude_hosts[0]='foo.bar.com'
#exclude_hosts[1]='192.168.0.1'
#
#Example: exclude element on host from script.
#exclude_element_on_host='foo.bar.com,users,1'
#exclude_element_on_host='192.16.0.3,users,0'
#
#Example: add user accounts.
#users[0]="group_name,full_name,'home_directory',prefered_shell,account_name"
#users[1]="jelle,'Jelle Derksen',/home/jelle,/bin/ksh,jelle"

#Script settings change to suit your needs.
exclude_host[0]=''
exclude_element_on_host[0]=''
user[0]="jelle,'Jelle Derksen',/home/jelle,/bin/ksh,jelle"

#Do not edit below this point.
#Script checks.
if [[ ! "$USER" = 'root' ]]; then
	echo 'need root privileges'
	exit 1
fi

if [[ ! "$(uname)" = 'Linux' ]]; then
	echo 'OS not Linux.'
	exit 2
fi

if [[ -n "$exclude_host" ]]; then
	for x in "${exclude_host[@]}"; do
		h="$(echo "$x" | awk -F, '{print $1}')"
		if [[ "$h" = "$(hostname)" ]]; then
			exit 0
		elif [[ "$h" = "$(ip addr show | grep -F -o "$h")" ]]; then
			exit 0
		fi
	done
fi

if [[ -n "$exclude_element_on_host" ]]; then
	for x in "${exclude_element_on_host[@]}"; do
		h="$(echo "$x" | awk -F, '{print $1}')"
		a="$(echo "$x" | awk -F, '{print $2}')"
		e="$(echo "$x" | awk -F, '{print $3}')"
		if [[ -z "$h" || -z "$a" || -z "$e" ]]; then
			echo "$x variable incorrect"
			exit 3
		fi
		if [[ "$(hostname)" = "$h" ]]; then
			unset "${a}[${e}]"
		elif [[ "$h" = "$(ip addr show | grep -F -o "$h")" ]]; then
			unset "${a}[${e}]"
		fi
	done
fi

#Main code.
for u in "${user[@]}"; do
	g="$(echo $u | awk -F, '{print $1}')"
	n="$(echo $u | awk -F, '{print $2}')"
	#Remove quotes around the user's full name.
	eval n="$n"
	h="$(echo $u | awk -F, '{print $3}')"
	s="$(echo $u | awk -F, '{print $4}')"
	a="$(echo $u | awk -F, '{print $5}')"
	if [[ -z "$g" || -z "$n" || -z "$h" || -z "$s" || -z "$a" ]]; then
		echo "$u variable incorrect."
		exit 4
	fi
	if id "$a" > /dev/null 2>&1; then
		echo "$a already on $(hostname)."
		continue
	fi
	if useradd -g "$g" -c "$n" -d "$h" -s "$s" "$a"; then
		echo "$a added on host $(hostname)."
	else
		echo "Failed to add $a on host $(hostname)."
		exit 5
	fi
done

echo "All accounts added on host $(hostname)."
exit 0

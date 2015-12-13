#!/bin/bash
#
#Add User Ssh Public-key
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#All public-keys in the "${user_pubkey[@]}" array will be added to the users
#authorized_keys file on the host this script is executed on. You can execute
#this script on multiple hosts by executing this script with the ssre.sh
#script. The correct syntax for the "$user_pubkey[@]" array can be seen in
#the example. Please mind the quotes around the public-key part.
#
#Example: exclude host from script.
#exclude_hosts[0]='foo.bar.com'
#exclude_hosts[1]='192.168.0.1'
#
#Example: exclude element on host from script.
#exclude_element_on_host='foo.bar.com,users,1'
#exclude_element_on_host='192.16.0.3,users,0'
#
#Example: add public-key to users authorized_keys file.
#user_pubkey[0]="user_name,'ssh_public_key','ssh_public_key'"

#Script settings change to suit your needs.
exclude_host[0]=''
exclude_element_on_host[0]=''
user_pubkey[0]=""

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
			echo "$x variable incorrect."
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
for x in "${user_pubkey[@]}"; do
	u="$(echo "$x" | awk -F, '{print $1}')"
	k="$(echo "$x" | awk -F, '{print $2}')"
	#Remove quotes arround public-key.
	eval k="$k"
	h="$(grep "$u" /etc/passwd | awk -F: '{print $6}')"
	g="$(grep "$u" /etc/passwd | awk -F: '{print $4}')"
	if [[ -z "$u" || -z "$k" || -z "$h" || -z "$g" ]]; then
		echo "$x variable incorrect."
		exit 4
	fi
	if ! id "$u" > /dev/null 2>&1; then
		echo "User $u does not exist."
		continue
	fi
	if [[ ! -d "${h}" ]]; then
		echo "$u has no home directory."
		exit 5
	elif [[ ! -d "${h}/.ssh" ]]; then
		mkdir "${h}/.ssh"
		echo "#${u}'s SSH public-key" > "${h}/.ssh/authorized_keys"
		echo "$k" >> "${h}/.ssh/authorized_keys"
		chown -R "$u":"$g" "${h}/.ssh"
	else
		if grep -F "$k" "${h}/.ssh/authorized_keys" > \
		/dev/null 2>&1; then
			echo "Key for $u already in authorized_keys file."
			continue
		fi
		echo "#${u}'s SSH public-key" >> "${h}/.ssh/authorized_keys"
		echo "$k" >> "${h}/.ssh/authorized_keys"
		chown "$u":"$g" "${h}/.ssh/authorized_keys"
	fi
done

echo "All keys are added to $(hostname)."
exit 0

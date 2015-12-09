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
user_pubkey[0]="jelle,'ssh-dss AAAAB3NzaC1kc3MAAACBALZ7V+ZDVLq6hdDHHYTIOI7GxuyLcu7hsFk2yTjLDM5LDSyB5VWQ8LCMM3MDlBwka9d9vfGHwXpiRQC9keU6DWfm/y13Ai3JP3Jlg2uxwKULhpfgYK0cBjiCjk3Xu6K+s8/5JLis+tegcyNL8EUyBu1R+CjtsIaxuM4MmsMb/nw3AAAAFQDWO88a1NTWXGRUKZbOtsLWBW19uwAAAIBZL/6qomdviXE5jPqSXt4Eag64p+KgpqOd4vKD1B4MMWWVJFpM/BchsUb7K7/mowYJdmxqPgSXxkpoYX/+ko1pMN+OiZPPuuVSHP/3URiZ3v87yEfVO4HE95Yfakn0rQAxb97TKmA9RGNlT2wr0BUZ/IT7k7Z1w/IbbInWgYYcUgAAAIAkRSpEblFosE+LNycXQOeMIsC0j9ckSSOY9/97c/TifRxP45isbqJJMdi9Gvj/k4U5VcG1v+c/AIL7WuB01kf6C+IZdQlYHmSe/5V+J+1jgR+OpSSmHrnU6m4wyeT1s6C0+ngA0oBpqYTzMKFD0y2XgOkVO/0QqkADi8s5UTCx0A== jelled@thinkpad'"

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
for x in "${user[@]}"; do
	u="$(echo "$x" | awk -F, '{print $1}')"
	k="$(echo "$x" | awk -F, '{print $2}')"
	h="$(grep "$x" /etc/passwd | awk -F: '{print $6}')"
	g="$(grep "$x" /etc/passwd | awk -F: '{print $4}')"
	if [[ -z "$u" || -z "$k" || -z "$h" || -z "$g" ]]; then
		echo "$x variable incorrect."
		exit 4
	fi
	if ! id "$u" > /dev/null 2>&1; then
		echo "User $u does not exist."
		continue
	fi
	if [[ ! -d "${u}" ]]
		echo "$u has no home directory."
		exit 5
	elif [[ ! -d "${u}/.ssh" ]]; then
		mkdir "${u}/.ssh"
		echo "$k" > "${u}/.ssh/authorized_keys"
		chown -R "$u":"$g" "${u}/.ssh"
	else
		echo "$k" >> "${u}/.ssh/authorized_keys"
		chown "$u":"$g" "${u}/.ssh/authorized_keys"
	fi
done

echo "All keys are added to $(hostname)"
exit 0

#!/bin/bash
#
#Install Packages With Yum
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Install all packages in the yum_package array on the system this script is
#executed on. You can execute this script on multiple hosts with the use of
#the ssre.sh script. Selecting a package for installation is as simple as
#adding a element to the yum_package array.
#
#Example: exclude host from script.
#exclude_hosts[0]='foo.bar.com'
#exclude_hosts[1]='192.168.0.1'
#
#Example: exclude element on host from script.
#exclude_element_on_host='foo.bar.com,users,1'
#exclude_element_on_host='192.16.0.3,users,0'
#
#Example: array with change you want to make.
#yum_package[0]='vim'

#Script settings change to suit your needs.
exclude_host[0]=''
exclude_element_on_host[0]=''
yum_package[0]=''

#Do not edit below this point.
#Script checks.
if [[ ! "$USER" = 'root' ]]; then
	echo 'Need root privileges.'
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
if [[ -n "$yum_package" && -x "$(which yum)" ]]; then
	for x in "${yum_package[@]}"; do
		if yum -y install "$x" > /dev/null 2>&1; then
			echo "Installed package $x."
			continue
		else
			echo "Failed to install package $x."
			exit 4
		fi
	done
else
	echo "No package to install or yum missing"
	exit 5
fi

echo "Done installing packages on $(hostname)."
exit 0

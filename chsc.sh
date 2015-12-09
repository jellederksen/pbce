#!/bin/bash
#
#Change Sysctl On Host
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Change sysctl setting on the host this script is executed on. You can execute
#this script on multiple hosts with the use of the ssre.sh script. Please add
#all sysctl settings you want to change to the "${sysctl_setting[@]}" array.
#
#Example: change or add sysctl settings.
#sysctl_setting[0]='net.ipv4.conf.all.forwarding = 0'
#sysctl_setting[1]='net.ipv4.conf.all.forwarding = 1'
#
#Example: exclude host from script.
#exclude_hosts[0]='foo.bar.com'
#exclude_hosts[1]='192.168.0.1'
#
#Example: exclude element on host from script.
#exclude_element_on_host='foo.bar.com,users,1'
#exclude_element_on_host='192.16.0.3,users,0'

#Script settings change to suit your needs.
sysctl_setting[0]=''
exclude_hosts[0]=''
sysctl_conf='/etc/sysctl.conf'

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

if [[ -n "$exclude_hosts" ]]; then
	for x in "${exclude_hosts[@]}"; do
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

if [[ ! -f "$sysctl_conf" ]]; then
        echo "sysctl $sysctl_conf missing"
        exit 2
fi

#Main code.
for s in "${sysctl_setting[@]}"; do
	conf="$(< "$sysctl_conf" grep "${s%% = [0-1]}")"
	if [[ "$conf" = "$s" ]]; then
		echo "sysctl setting $s correct in $sysctl_conf"
	elif [[ -z "$conf" ]]; then
		echo "$s" >> "$sysctl_conf"
	else
		if ! sed -i "s/$conf/$s/" "$sysctl_conf"; then
			echo "failed to change $sysctl_conf"
			exit 3
		else
			echo "$sysctl_conf changed"
		fi
	fi
	live="$(sysctl "${s%% = [0-1]}")"
	if [[ "$live" = "$s" ]]; then
		echo "sysctl setting $s correct state active"
	else
		s="$(echo "$s" | sed 's/ //g')"
		if sysctl "$s"; then
			echo "activated $s"
		else
			echo "failed to activate $s"
			exit 4
		fi
	fi
done

exit 0

#!/bin/bash
#
#Add Users On Host
#
#All users in the array "$users[@]" will be added to the host this
#script is executed on. You can execute this script on multiple hosts
#by executing this script with the ssre.sh script. The correct syntax
#for the "$users[@]" variable can be seen in the example. Please mind
#the quotes arround the full_name part. You will need the quotes when
#using a space between the first and last name.
#
#Copyright 2016 Jelle Derksen
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl

#Example
#'group_name,full_name,home_directory,prefered_shell,account_name'

users[0]="jelle,'Jelle Derksen',/home/jelle,/bin/ksh,jelle"

for user in "${users[@]}"; do
	g="$(echo $user | awk -F, '{print $1}')"
	n="$(echo $user | awk -F, '{print $2}')"
	h="$(echo $user | awk -F, '{print $3}')"
	s="$(echo $user | awk -F, '{print $4}')"
	a="$(echo $user | awk -F, '{print $5}')"
	if [[ -z $g || -z $n || -z $h || -z $s || -z $a ]]; then
		echo "$user variable incorrect."
		exit 1
	fi
	if id "$account" > /dev/null 2>&1; then
		echo "$account already on $(hostname)."
		continue
	fi
	if useradd -g "$g" -c "$n" -d "$h" -s "$s" "$a"; then
		echo "$account added on host $(hostname)."
	else
		echo "Failed to add $account on host $(hostname)."
		exit 2
	fi
done

echo "All accounts added on host $(hostname)."
exit 0

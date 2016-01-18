#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#All users in the array "$users[@]" will be added to the host this
#script is executed on. The correct syntax for the "$users[@]" 
#variable can be seen in the example. Please mind the quotes arround
#the full_name part. You will need the quotes when using a space
#between the first and last name.
#
#Example: add user accounts.
#users[0]="group_name,full_name,'home_directory',prefered_shell,account_name"
#users[1]="jelle,'Jelle Derksen',/home/jelle,/bin/ksh,jelle"

jobname='AddUsers'
jobgroup=''
jobdepends=''

add_users() {
	for u in "${users[@]}"; do
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
}

main() {
	check_root
	check_os
	add_users
	exit 0
}

main "$@"

#!/bin/bash
#Add User Ssh Public-key
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#All public-keys in the "${user_pubkey[@]}" array will be added to the users
#authorized_keys file on the host this script is executed on. The correct syntax
#for the "$user_pubkey[@]" array can be found in the example. Please mind the 
#quotes around the public-key part.
#
#Example: add public-key to users authorized_keys file.
#user_pubkey[0]="user_name,'ssh_public_key','ssh_public_key'"

jobname='AddUserSshPublickey'
jobgroup='ssh'
jobdepends='AddUsersToHost'

add_pubkey() {
	for x in "${user_pubkey[@]}"; do
		echo debugdebug
		u="$(echo "$x" | awk -F, '{print $1}')"
		k="$(echo "$x" | awk -F, '{print $2}')"
		#Remove quotes arround public-key.
		eval k="$k"
		h="$(grep "$u" /etc/passwd | awk -F: '{print $6}')"
		g="$(grep "$u" /etc/passwd | awk -F: '{print $4}')"
		if [[ -z "$u" || -z "$k" || -z "$h" || -z "$g" ]]; then
			echo "$x variable incorrect."
			exit 101
		fi
		if ! id "$u" > /dev/null 2>&1; then
			echo "User $u does not exist."
			continue
		fi
		if [[ ! -d "${h}" ]]; then
			echo "$u has no home directory."
			exit 102
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
}

main() {
	check_root
	check_os
	add_pubkey
	echo "All keys are added to $(hostname)."
	exit 0
}

main "$@"

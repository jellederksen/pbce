#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelle@jellederksen.nl
#Website www.jellederksen.nl
#
#All public-keys in the user_pubkey array will be added to the users
#authorized_keys file on the host this script is executed on. The correct
#syntax for the user_pubkey array can be found in the example. Please
#mind the quotes around the public-key part. Add the user_pubkey array to
#the host config file in de pbce hosts directory.
#
#Example user_pubkey array:
#user_pubkey[0]="user_name,'ssh_public_key','ssh_public_key'"

jobname='AddPubkey'
me="${jobname}"

add_pubkey() {
	for x in "${user_pubkey[@]}"; do
		u="$(echo "${x}" | cut -f 1 -d ',')"
		k="$(echo "${x}" | cut -f 1 -d ',' --complement)"
		#Remove quotes arround public-key
		eval k="${k}"
		h="$(grep "${u}" /etc/passwd | cut -f 6 -d ':')"
		g="$(grep "${u}" /etc/passwd | cut -f 4 -d ':')"
		if [[ -z ${u} || -z ${k} || -z ${h} || -z ${g} ]]; then
			echo "${me}: ${x} variable incorrect" >&2
			exit 1
		fi
		if ! id "${u}" > /dev/null 2>&1; then
			echo "${me}: user ${u} does not exist"
			continue
		fi
		if [[ ! -d ${h} ]]; then
			echo "${me}: ${u} has no home directory" >&2
			exit 2
		elif [[ ! -d ${h}/.ssh ]]; then
			mkdir "${h}/.ssh"
			echo "#${u}'s SSH public-key" > \
			"${h}/.ssh/authorized_keys"
			echo "${k}" >> "${h}/.ssh/authorized_keys"
			chown -R "${u}:${g}" "${h}/.ssh"
		else
			if grep -F "${k}" "${h}/.ssh/authorized_keys" > \
			/dev/null 2>&1; then
				echo "${me}: ${u} already in authorized_keys"
				continue
			fi
			echo "#${u}'s SSH public-key" >> \
			"${h}/.ssh/authorized_keys"
			echo "${k}" >> "${h}/.ssh/authorized_keys"
			chown "${u}:${g}" "${h}/.ssh/authorized_keys"
		fi
	done
	echo "${me}: all keys are added to $(hostname)"
}

main() {
	check_root
	check_os
	add_pubkey
	exit 0
}

main "${@}"

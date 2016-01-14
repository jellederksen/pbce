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
user_pubkey[0]="jelle,'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC69jLsHeedqMknh6DDl5JqPVI9iUSGoxCzuEzPnGXh0wIsz4BaqZn2dM0597TwYFRupBnVnc9yXH0jZiPy94LWH77DA2hRlgRKUHprCjlAzS9l0E8zUj1Z2JAlBvIfOfvZO78X8HCpPnu32hH6by5hM7yfV51szpHwdsRou/22lG4QyYzE/5OkX+ynIrL7bsINgf4vmG9uNG+0df7S7f1pan69dSMoDPmm1ooCWOu5TN4cqUTbAI/G5octGJploH9TAgvmzE1GdPfax2D41kAEz3U+7zD5BiifXKpv2F+pk/kNa3HGiRgH9zaKx8p1Zy0zgctW1CLHYcwKPAVwjBXV jelled@anjelier'"


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
	exclude_host
	exclude_element
	add_pubkey
	echo "All keys are added to $(hostname)."
	exit 0
}

main "$@"
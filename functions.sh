#Functions for pbce scripts
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl

check_root() {
	if [[ ! "$USER" = 'root' ]]; then
		echo 'need root privileges'
		exit 1
	fi
}

check_os() {
	if [[ ! "$(uname)" = 'Linux' ]]; then
		echo 'OS not Linux.'
		exit 2
	fi
}

exclude_host() {
	if [[ -z "$exclude_host" ]]; then
		return 0
	fi
	for x in "${exclude_host[@]}"; do
		h="$(echo "$x" | awk -F, '{print $1}')"
		if [[ "$h" = "$(hostname)" ]]; then
			exit 0
		elif [[ "$h" = "$(ip addr show | grep -F -o "$h")" ]]; then
			exit 0
		fi
	done
}

exclude_element() {
	if [[ "$exclude_element_on_host" ]]; then
		return 0
	fi
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
}

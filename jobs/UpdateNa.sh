#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Update the application NA on the remote system this script is executed on.

jobname='UpdateNa'

unstall_na='/opt/na/bin/ipm-uninstall'
install_na='/usershare/na/installation_91/na-9.1.3.1-2.bin'
config_na='/usershare/na/installation_91/1-nac-91-large-redundancy-kpn-acceptance-15min-temp.ini'

update_na() {
	if [[ ! -f ${unstall_na} || ! -f ${install_na} || ! -f ${config_na} ]]; then
		echo "missing NO files on $(hostname)"
		exit 1
	fi
	if "${unstall_na}"; then
		echo "Na uninstalled on $(hostname)"
	else
		echo "failed to uninstall NA on $(hostname)"
		exit 2
	fi
	if "${install_na}" "${config_na}"; then
		echo "new version of NA installed on $(hostname)"
		if chkconfig na off; then
			echo "Na init script turned off on $(hostname)"
		else
			echo "failed to turn off NA init script $(hostname)"
			exit 3
		fi
		exit 0
	else
		echo "failed to install new version of NA on $(hostname)"
		exit 4
	fi
}

main() {
	check_root
	check_os
	update_na
	exit 0
}

main "${@}"

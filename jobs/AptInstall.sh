#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelle@jellederksen.nl
#Website www.jellederksen.nl
#
#Install all packages in the apt_package array on the system this script is
#executed on. Selecting a package for installation is as simple as adding a
#element to the "${apt_package[@]}" array.
#
#Example: array with change you want to make.
#apt_package[0]='vim'

jobname='AptInstall'

apt_install() {
	if [[ -n ${apt_package} && -x $(which apt-get) ]]; then
		for x in "${apt_package[@]}"; do
			if apt-get -y install "${x}" > /dev/null 2>&1; then
				echo "${me}: installed package ${x}"
				continue
			else
				echo "${me}: failed to install package ${x}"
				exit 4
			fi
		done
	else
		echo "${me}: package to install or apt-get missing"
		exit 5
	fi
	echo "${me}: packages installed on $(hostname)"
}

main() {
	check_root
	check_os
	apt_install
	exit 0
}

main "${@}"

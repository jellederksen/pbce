#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Install all packages in the yum_package array on the system this script is
#executed on. Selecting a package for installation is as simple as adding a
#element to the "${yum_package array[@]}" array.
#
#Example: array with change you want to make.
#yum_package[0]='vim'

yum_install() {
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
}

main() {
	check_root
	check_os
	yum_install
	exit 0
}

main "$@"

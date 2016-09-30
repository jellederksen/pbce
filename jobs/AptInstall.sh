#!/bin/bash
#
#Install packages with apt-get
#
#Version 0.1
#
#Copyright (c) 2016 Jelle Derksen jelle@epsilix.nl
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
#
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

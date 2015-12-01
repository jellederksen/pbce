!/bin/bash
#
#ssh execute script remote
#
#Execute a local script on multiple systems with the use of ssh.
#You can specify the script you want to execute on the remote system
#as the first option of this script. You don't have to login with
#the root user directly. The user does require the use of sudo.
#
#
#Copyright 2015 Jelle Derksen
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl

#Example
# root # ./ssre.sh <script_you_want_to_execute.sh>

ssh_user='systemadmin'
remote_hosts[0]='192.168.0.1'
remote_hosts[1]='192.168.0.2'
remote_hosts[2]='192.168.0.3'
remote_hosts[3]='192.168.0.4'
remote_hosts[4]='192.168.0.5'

if [ ! -r "$1" ]; then
        echo "Please enter the script name you want to execute"
        exit 1
else
        base64_script="$(base64 -w0 "$1")"
fi

for remote_host in "${remote_hosts[@]}"; do
	echo "ssh to $remote_host and executing script $1"
	ssh -o StrictHostKeyChecking=no "$ssh_user@$remote_host" \
"echo $base64_script | base64 -d | sudo bash"
	if [ ! "$?" -eq 0 ]; then
		echo "someting went wrong on the host $slacrr_host"
		exit 1
	fi
done

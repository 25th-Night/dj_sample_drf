#!/bin/bash

USERNAME=""
PASSWORD=""
MANUAL="Usage: $0 [-u username -p password]"

while getopts "u:p:" option
do
	case $option in
		u)
			USERNAME=$OPTARG
			;;
		p)
			PASSWORD=$OPTARG
			;;
		*)
			echo $MANUAL
			exit 1
			;;
	esac
done

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]
then
	echo "username and password are required"
	echo $MANUAL
	exit 1
fi

echo "add user"
useradd -s /bin/bash -d /home/$USERNAME -m $USERNAME

echo "set password"
echo "$USERNAME:$PASSWORD" | chpasswd

echo "set sudo"
usermod -aG sudo $USERNAME
echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME

echo "done"
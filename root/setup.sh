#!/bin/bash
echo "Welcome to your new system please answer some questions:"
# set -ex
# _readvar msg varname
_readvar() {
	while [[ ${!2} == "" ]]
	do
		echo -n $1
		read $2
	done
}

_adduser() {
	echo "Adding user $NEWUSER"
	useradd -m -g wheel $1
}

_add_authorized_key() {
	AUTHORIZED_KEYS_FILE="/home/$NEWUSER/.ssh/authorized_keys"
	SSHDIR="$(dirname $AUTHORIZED_KEYS_FILE)"
	echo "Adding authorized_key to user $NEWUSER"
	mkdir -p $SSHDIR
	chmod 0700 $SSHDIR
	echo $1 >>$AUTHORIZED_KEYS_FILE
	chmod 0600 $AUTHORIZED_KEYS_FILE
	chown -R $NEWUSER:$NEWUSER $SSHDIR
}

_secure_ssh() {
	sed -i -e 's/# \(.*system-remote-login\)/\1/ ; /pam_permit.so/d' /etc/pam.d/sshd
	sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/ ; /ForceCommand \/root\/setup.sh/d' /etc/ssh/sshd_config
}

_collapse_self() {
	rm -f $(readlink -f $0)
}

_protect_root() {
	sed -i -e 's/root::/root:!:' /etc/passwd
}

_readvar "What username do you want to login with? " NEWUSER
_readvar "Please paste the contents of your ssh pub key i.e. \$HOME/.ssh/id_rsa.pub " AUTHORIZED_KEY
_adduser $NEWUSER &&
_add_authorized_key $AUTHORIZED_KEY &&
_secure_ssh &&
_collapse_self

echo "That it, now login with your new user $NEWUSER"


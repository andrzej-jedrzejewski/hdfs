#!/bin/sh

if [ $# != 1 ] && [ $# != 3 ];
then
	echo ""
	echo "Script to assign the ACLs to the directories (and their sub directories) specified in the passed in .lst file"
	echo "Usage: $0 acl_file [keytab_file] [kerberos_principal]"
	echo ""
	exit 1
fi

aclFile=$1
keytabfile=$2
principal=$3

if [ $# == 3 ];
then
	kinit -kt $keytabfile $principal
fi

while IFS=' ' read directory acl
do
	if [ -n "$directory" ] && [ -n "$acl" ];
	then
		hdfs dfs -setfacl --set $acl $directory
		if [ $? != 0 ]
		then
			echo ""
			echo "Failed to assign ACL ${acl} to directory ${directory}. Exiting" 1>&2
			exit 1
		fi
	fi
done < $aclFile
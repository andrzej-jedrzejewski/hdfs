#!/bin/sh

if [ $# != 1 ] && [ $# != 3 ];
then
	echo ""
	echo "Script to get the current ACLs on the directories specified in the passed in .lst file, and output them to a file"
	echo "Usage: $0 acl_file [keytab_file] [kerberos_principal]"
	echo ""
	exit 1
fi

aclFile=$1
keytabfile=$2
principal=$3

previousAclFile="ACLs-$(date +'%Y-%m-%dT%H:%M:%S').lst"

if [ -f $previousAclFile ];
then
   echo "File $previousAclFile already exists. Exiting" 1>&2
   exit 1
fi

if [ $# == 3 ];
then
	kinit -kt $keytabfile $principal
fi

while IFS=' ' read directory acl
do
	acl=$(hdfs dfs -getfacl $directory | grep "^[^#]" | tr '\n' ',')
	echo "${directory} ${acl}" >> $previousAclFile
	if [ $? != 0 ]
	then
		echo ""
		echo "Failed to get ACL for directory ${directory}. Exiting" 1>&2
		exit 1
	fi
done < $aclFile
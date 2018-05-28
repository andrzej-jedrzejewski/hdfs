#set -x
#!/bin/sh
#
# Create the directory structure and metadata inside HDFS.
#
# Expects two parameters:
#	1: Filename containing directory structure and optional metadata filenames. This file should contain the name of a directory and an optional name of a metadata file name.  This metadata file is used to provide Cloudera Navigator with information describing the directory that has been created.
#	2: Delete flag used to remove directories before they are created.
#

if [ $# == 0 ] ; then
    echo "Usage: $0 filename_of_directories [ delete_flag (y/n) ] "
    exit 1;
fi

logFile="$0.log"
directoryList=$1
deleteDirectory=$2

metadataDirectory="metadata/"
navigatorDirectoryMetadataFilename=".navigator"
umaskDefault="022" 

hdfsDfsCmd="hdfs dfs -D fs.permissions.umask-mode=$umaskDefault "
createDirectoryCmd=$hdfsDfsCmd"-mkdir -p "
putFileCmd=$hdfsDfsCmd"-put -p "
listFilesCmd=$hdfsDfsCmd"-ls "
deleteDirectoryCmd=$hdfsDfsCmd"-rm -r -f "

while IFS="," read directory metadataFile 
do
	if [ $deleteDirectory == "y" ]
	then
		$deleteDirectoryCmd $directory
		if [ $? != 0 ] 
		then 
			echo "Failed to delete HDFS directory: $directory. Exiting" >> $logFile
			exit 1
		fi
	fi

 	# Create each directory in HDFS	
	$createDirectoryCmd $directory
	if [ $? != 0 ] 
	then 
		echo "Failed to create HDFS directory: $directory" >> $logFile
	fi

	# If a metadata filename is included alongside the directory name, deposit this into HDFS.	
	if [ ! -z "$metadataFile" ]
	then
		$putFileCmd $metadataDirectory$metadataFile $directory/$navigatorDirectoryMetadataFilename
	else
		# Otherwise, look for a filename with the same name as the directory structure.
		metadataFile=`echo $directory | sed 's/\///g'`

		if [ -s "$metadataDirectory$metadataFile" ]
		then
			$putFileCmd $metadataDirectory$metadataFile $directory/$navigatorDirectoryMetadataFilename
		fi
	fi

	if [ $? != 0 ] 
	then 
		echo "Failed to ingest metadatafile: $metadataFile" >> $logFile
	fi

	metadataFile=""

done < $directoryList

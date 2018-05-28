#set -x
#!/bin/sh
#
# Create a blank Cloudera Navigator metadata file for every directory name in the specified file.  The metadata filename will be the same as the directory name, excluding "/" characters.  For example, /etl/common directory will result in a metadata file of etlcommon being created.

if [ "$#" -ne 1 ] ; then
    echo "Usage: $0 file-containing-directories"
    exit 1;
fi

logFile="$0.log"
directoryList=$1

metadataDirectory="metadata/"
metadataTemplateDirectory=$metadataDirectory"template/"
navigatorDirectoryMetadataFilename=".navigator"
blankMetadataFile="blankmetadatafile"

while IFS="," read directory 
do
	metadataFile=`echo $directory | sed 's/\///g'`

	cp $metadataTemplateDirectory$blankMetadataFile $metadataDirectory$metadataFile

done < $directoryList

#!/bin/bash

WA_SRC="/storage/self/primary/WhatsApp/Media/"
WA_CLONE_BCK="/storage/0000-0000/.WhatsAppMediaClone/"
WA_SORTED_BCK="/storage/0000-0000/WhatsAppMedia/"

echo "Backing up WA Media folder on SD card"
# cp won't preserve timestamps with the -p flag
adb shell "cp -rn --preserve=t ${WA_SRC}* ${WA_CLONE_BCK}"

# add .nomedia to cloned folders 
#adb shell "find ${WA_CLONE_BCK} -type d -not -path \"${WA_CLONE_BCK}WhatsApp Voice Notes/*\" -not -path \"${WA_CLONE_BCK}\" -exec sh -c 'echo touch "$@" /.nomedia' {} +"

# echo "Storing backup file list"
adb shell "find ${WA_SRC} -type f | sort" > /tmp/WA_SRC_OLD

echo "Please follow in order:"
echo ""
echo "	(1) From WhatsApp, delete the media of a specific contact (Can be done from WA Storage Options for bulk actions)"
echo "	(2) Type the folder name to group the media into (Likely the name of the contact)"
echo "	(3) Press ENTER"
read

# echo "Storing updated file list"
adb shell "find ${WA_SRC} -type f | sort" > /tmp/WA_SRC_NEW

# mapfile -t 	## map output file list to a new array 
# diff -U 0 	## print only diffing lines witout previous or following ones
# tail -n +4 	## strip off diff header
# grep -v '^@' 	## skip lines starting with @ 
# grep -e '^-' 	## include only lines starting with -
# cut -c 2- 	## strip off the first character of the line
mapfile -t DELETED < <(diff -U 0 /tmp/WA_SRC_OLD /tmp/WA_SRC_NEW | tail -n +4 | grep -v '^@' | grep -e '^-' | cut -c 2-)

# echo "Creating destination folder"
adb shell "mkdir $WA_SORTED_BCK${REPLY} &>/dev/null" # if folder is present will silently fail
adb shell "touch $WA_SORTED_BCK${REPLY}/.nomedia"

if [ ${#DELETED[@]} -gt 0 ]; then
	echo "Moving ${#DELETED[@]} files in folder ${REPLY}"

	for file in "${DELETED[@]}"
	do
		RELPATH=$(echo $file | cut -d'/' -f7-)
		DIRS=$(dirname "${RELPATH}")

		echo ${RELPATH}
		
		# Ensure to have all subdirs
		adb shell "mkdir -p \"$WA_SORTED_BCK${REPLY}/${DIRS}\""

		# ORIG_MTIME=$(adb shell "stat -c %y '${WA_CLONE_BCK}${RELPATH}'") 

		adb shell "mv \"${WA_CLONE_BCK}${RELPATH}\" \"$WA_SORTED_BCK${REPLY}/${RELPATH}\""

		# MOVED_MTIME=$(adb shell "stat -c %y \"$WA_SORTED_BCK${REPLY}/${RELPATH}\"")

		# if [ "$ORIG_MTIME" != "$MOVED_MTIME" ]; then
		# 	echo "Updating time \"$ORIG_MTIME\" to \"${REPLY}/${RELPATH}\""
		# 	adb shell "touch -d \"$ORIG_MTIME\" \"$WA_SORTED_BCK${REPLY}/${RELPATH}\""
		# fi 

	done
	echo "Done"
else
	echo "Looks like no file has been deleted from the WA source folder."
	echo "This can happen if you chose from WhatsApp not to remove all the copies of the media you're backing up, which has been forwarded within different contacts."
fi

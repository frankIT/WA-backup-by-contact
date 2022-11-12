# WA Backup by contact
Allows to make a copy, grouped by contact, of the media folder of WhatsApp.

- It works via adb, so it runs on your system, not on the phone.
- It is supposed to backup from the internal memory to the SD card on the phone, but you can change it to whatever path.
- It actually makes a hidden clone of the entire Whatsapp Media folder, then moves only the cherry picked files to the grouped backup folder.

You are supposed to run the script first, 
wait for it to ask you the name of the folder to group the media in, and
then delete from within WhatsApp the media you want to backup before press ENTER.


It will then diffs the first folder clone with the current WA media folder, catching the deleted files names to group them in the named folder.

# wd
<b>*What Disk - Ubuntu Server 18.04*</b>
*(Mount USB storage device available to the system)*

Description:

<b>Why?</b>
Found mounting USB disk drives too often on ubuntu servers is quite a tidious task ...
	
 - Needed a way to mount devices with a very simple command.
 - Only USB flash drives are mounted.  In my case, I have ZFS pools and other devices on the servers that do not want touched.
	
<b>What?</b>
	
Simple bash script to mount any and all available USB drive partitions by invoking a simple command <wd>.
  
 - Program enumerates available USB disk partitions and mountpoints.
      - Program will seek and mount ONLY USB flash drives.
      - It can easily be expanded or change to other disk types (not tested).
 - <b>Mountpoint:</b> Set to /media/$LABEL.  Program will create a folder called $LABEL if it does not exist.
     - If there is no label the program will attempt to use USB$NAME (USB + Partition logical block name)
     - e.g. /media/USBsdb1
 - <b>Filesystem:</b> Program will mount the drive using the given filesystem of the partition.
 - <b>Logs:</b> Added logging and conf file as I was initially planning on having it run as a daemon with more functionality, but realized it was unnecessary.

	
# How do I use the script?

1. Label your USB disk partitions as you want to be mounted by the system.
2. Install script at /usr/local/bin (for convinience)
3. Run command:
	- wd -a [add: 	mount partitions of USB disks connected to the system]
	- wd -c [check:	check what USB drives are available in the system]

-----
*Written and tested on ubuntu server 18.04, but it should work for similar debian distros.*

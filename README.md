# wd
What Disk (What USB Disk partitions are available and mount them to the system) - Ubuntu Server 18.04

Description:

<b>Why?</b>
Found mounting USB disk drives too often on ubuntu servers is quite a tidious task ...
	
Took the time to write this simple script that takes care of my needs, sharing in case someone else feels it can be of use.  There is a flag to ensure only USB flash drives are mounted; this as I have ZFS pools on the servers that do not want touched.
	
<b>What?</b>
	
Simple bash script to mount any and all available USB drive partitions by invoking a simple command <wd>.
  
1. Program enumerates available USB disk partitions and mountpoints.
      - Program will seek and mount ONLY USB flash drives.
      - It can easily be expanded or change to other disk types (not tested).
3. <b>Mountpoint:</b> Set to /media/$LABEL.  Program will create a folder called $LABEL if it does not exist.
     - If there is no label the program will attempt to use USB$NAME (USB + Partition logical block name)
     - e.g. /media/USBsdb1
4. <b>Filesystem:</b> Program will mount the drive using the given filesystem of the partition.
5. <b>Logs:</b> Added logging and conf file as I was initially planning on having it run as a daemon with more functionality, but realized it was unnecessary.

	
<b>How do I use the script?</b>

1. Label your USB disk partitions as you want to be mounted by the system.
2. Install script at /usr/local/bin (for convinience)
3. Run command:
	- wd -a [add: 	mount partitions of USB disks connected to the system]
	- wd -c [check:	check what USB drives are available in the system]

-----
I wrote this for ubuntu server 18.04.  It should work with similar distros.

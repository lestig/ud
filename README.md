# wd
What Disk (What USB Disk - Mounts USB disk drive Ubuntu Server

Description:

	Why?
	Mounting USB disk drives becomes a tidious task when you have more than one linux server, so I found ...
	
	I am currently working on AI Deep learning models and have to move sensitive information via USB flash disks and set backups on external HDD drives daily, so took the time to write this simple script that takes care of my needs perfectly.   Sharing in case someone else feels it can be of use.
	
	There is a flag to ensure only USB flash drives are mounted.  This as I have ZFS pools on the servers that do not want touched.
	
	What?
	Simple bash script to mount USB drives semi-automatically by invoking a simple command <wd>.
	1. Label your USB disk partition as you want to be mounted by the system.
	2. If there is no label the program will attempt to use USB$NAME (USB + Partition logical block name)
	3. Program will mount the drive using the filesystem format of the partition
	4. Mountpoint is set to /media/$LABEL.  Program will create a folder called $LABEL if it does not exist.
	5. Program will seek and mount ONLY USB flash drives.  It can easily be expanded or change to other disk types (not tested).
	6. Added logging and conf file as I was initially planning on making it a daemon with more functionality, but realized it was overkill for my needs.
	
	How?
	1. Label your USB disk partition as you want to be mounted by the system.
	2. Install script at /usr/local/bin (for convinience)
	3. Run command:
			wd -a [add: 	mount partitions of USB disks connected to the system]
			wd -c [check:	check what USB drives are available in the system]

I wrote this for ubuntu server 18.04.  It should work with similar distros.

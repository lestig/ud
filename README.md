# ud
<b>*USB Drive - Ubuntu Server 18.04*</b>
*(Mount USB storage devices available to the system)*

Description:

<b>Why?</b>
Mounting USB disk drives often in Linux; Ubuntu servers in my case, it is quite a tedious task ...
	
 - Needed a quick and simple command to mount only USB storage devices.
 - Ensure critical storage (e.g. ZFS pools) and other devices on the servers are not touched.
	
<b>What?</b>
	
Simple bash script to mount any and all available USB drive partitions by invoking a simple command <wd>.
  
 - The program enumerates available USB disk partitions and mountpoints.
      - The program will look for and mount ONLY USB storage devices.
      - It can easily be expanded to mount other disk types (not tested).
 - <b>Mountpoint:</b> 
     - <i>ud</i> will use the LABEL of the partition if it exists.
     	- Mountpoin is set to /media/$LABEL.  (It can be set to any other folder if needed).
     	- A folder named $LABEL (disk's label) is created if it does not exist.
     - If the partition does not have a label, the program will attempt to use USB$NAME (USB + Partition logical block name)
     	- e.g. /media/USBsdb1
 - <b>Filesystem:</b> 
 	- <i>ud</i> will mount the drive using the given filesystem of the partition.
	
 - <b>Logs:</b> Added logging and conf file as I was initially planning on having it run as a daemon with more functionality, but realized it was unnecessary.

	
# How do I use the script?

1. Label your USB disk partitions as you want to be mounted by the system.
2. Install script at /usr/local/bin (for convenience)
3. Run command:
	- wd -a [add: 	mount partitions of USB disks connected to the system]
	- wd -c [check:	check what USB drives are available in the system]

-----
*Written and tested on Ubuntu Server 18.04; it should work for similar Debian distros. *

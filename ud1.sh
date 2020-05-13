
#!/bin/bash
#<ud>: It mounts external USB disks ONLY.   This to ensure no issues no issues with ZFS disc storage
# 4/15/2020 – v1.0 Creating script to quickly mount drives Initializing
# 4/16/2020 – v2.0 Automating everything... find drives, logic paths and mount as appropriate   
# 4/22/2020 - v2.1 Finalized and commited log capabilties and conf file for flexibility | add feature set
# 4/22/2020 - Keeping prompts, no plans to make daemon (not needed).  /etc/ud/ud.conf to change VERBOSE in syslog.
# 4/29/2020 - v2.2 Adding flag to make minimum mounting size an option.  dSIZE (MB)

main ()
{
  #Main structure
      set -e  # exit if a command fails
      #exec > /dev/null 2>&1
  
  # Logs
      # Log a string via syslog.
    log()
    {
    if [ $1 != debug ] || expr "$VERBOSE" : "[yY]" > /dev/null; then
	    logger -p user.$1 -t "ud[$$]" -- "$2"
    fi
    }

  # Definition and Nomenclature
      # variables 
      SCFER=$1  #Captures argument e.g. -a (Add), -r (Remove), c (Check)
      lecom="lsblk -o TRAN,TYPE,NAME,VENDOR,FSTYPE,LABEL,MOUNTPOINT,SIZE -n -P"
      
      red=$'\e[1;31m'
      grn=$'\e[1;32m'
      yel=$'\e[1;33m'
      blu=$'\e[1;34m'
      mag=$'\e[1;35m'
      cyn=$'\e[1;36m'
      wht=$'\e[1;37m'
      blk=$'\e[30m'
      dgrn=$'\e[32m'
      bold=$'\e[1m'
      end=$'\e[0m'

      dSIZE=25 #MB
      DOT2="${wht}•${end}"
      DOT1="${blk}•${end}"
      zUSB="usb"

      # Nomenclature: (_pt = pointer) (_a=array)
      main_a=()     #Array: Output of lsblk columns.  Each line is stored as an element in the array 
      sub_a=()      #Array: Parsed commands (columns) from each lsblk line
      neud_pt_a=()  #Array: Pointers to UID disk and attributes.  Store main and sub arrays index if a new USB disk is detected.

  # Enumerate
      log debug "enumerating list of devices and mountpoints available in system"
        # Each word in the line is an element in the array '"'
        IFS='"' read -r -d '' -a main_a < <( $lecom && printf '\0' )
        # folders in path /media/*
        mntpoints
        # Matrix variable masks and definitions - loading from file
        setmatrix   # it needs matrix_Vx.conf file in place to start.
  
  # Argument Selection
      args

#printf "\n%s" "" "... Completed succesfully" ""
log info "($1) completed succesfully"
}

args()
{
    case $SCFER in
      a | -a) 
          # Mount (Add) partitions
          DOT1="${grn}•${end}"
          eMAIN
        ;;

      c | -c) 
          # Mount (Add) partitions
          printf "\n%s\n" " *** USB Disk Drives in System *** "
          DOT1="${blk}•${end}"    # Reset DOT to default 
          eMAIN 
        ;;

      i)
        #Instructions
        instructions
        ;;   

      -r)
          # Umount (Remove) partitions
          clear
          eMAIN
        ;;   

      *)
        # Mount based on explicit input | Menu
        clear
        DOT1="${blu}|•${end}"
        eMAIN
        ;;
    esac
}


ActiVe()
{
    TRAN=${main_a[$l]}          #TRAN index (usb, sata, nvme)
    TYPE=${main_a[(($l+2))]}    #TYPE index (disk, part)
    NAME=${main_a[(($l+4))]}    #NAME index (/dev/name)
    VENDOR=${main_a[(($l+6))]}  #VENDOR index (ATA, WD, Sandisk, etc.)
    FSTYPE=${main_a[(($l+8))]}  #FSTYPE index (ntfs, zfs_member, ext4, etc.)
    LABEL=${main_a[(($l+10))]}  #LABEL index 
    MTYPE=${main_a[(($l+12))]}  #MOUNTTYPE index (/dev/<folder>)
    SIZE=${main_a[(($l+14))]}   #SIZE index (xxM, xxG, xxT)

    # Check if device is an USB Disk Drive 
    if [[ $TRAN == $zUSB ]] && [[ $TYPE == *"disk"* ]]; then
    #Assigns DISK name (e.g. sdm) & Device Manufacturer VENDOR
    lNAME=$NAME
    lVENDOR=${VENDOR%% *}
    d=0;
    log debug "found $zUSB devices and enumerated lsblk columns successfully"
    fi
}
eMAIN()
{
    for l in "${!main_a[@]}"; do
    #Set variables and check if device is an USB Disk Drive
    ActiVe

        # Check if NAME is a partition of lNAME (e.g sdm1, sdm2 -> sdm)
        # FER:This next conditional below is TRUE when loop is at **TRAN's value**.
        # FER: $l-1 will be the word "TRAN".  Loop is at the (begining + 1) of the lsblk line.
        # FER: Meaning $NAME=${main_a[$((l+4))]}.
        # FER: Example, if $NAME=629=sdn1 that means 628="NAME" or ${main_a[628]}=NAME -> (l+3)
        # FER: and that means: $TRAN=629-4=625=(l+1) and "TRAN"=624=(l+0).
        # FER: Variables ------
        # FER:   a= and b= | Counter that matches rows in matrix.conf.  Populates those lines
        # FER:   M=        | Flag that informs if a partition can be mounted.  M="no" means the partition cannot be mounted
        # FER:   e=        | e is the variable displayed in menu selection (It can be changed for control).
        # FER:   f=        | f is the counter that provides information to e.  
        # FER:${blk}•${end}| DOT 
        # FER:   

        if [[ $NAME =~ $lNAME ]] && [[ ! -z $lNAME ]] && [[ $TYPE == "part" ]]; then
            
            #Use matrix configuration file to capture system information
            if [[ $d == 0 ]] && [[ ! -z $lVENDOR ]]; then   

                ((++d));((++f))
                #M="${blk}dv${end}" # FER:::delete as it seems it nevers gets here
                a=0;b=1;e=$f
                logstatus   #Captures Storage Device Name

            fi

            ((++f))
            a=2;b=3;e=$f
            exitc   # Checks exit conditions - (e.g. invalid size, partition mounted already)
            logstatus   #Captures Partition Information

        fi
    done
    
    echo    # Gives a space once commands is completed.
    # Mounts specific partitions based on input
    if [[ ! $SCFER == "c" ]]; then lechoice; fi
}
exitc()
{
    # Is the partition mounted?
    if [[ -z $MTYPE ]]; then 
        #4
        ISMOUNTED="NOT_Mounted"
        b=4  #Setting b=4 (Loop through Parition Mount section in matrix as well)
        log debug "found usb $lVENDOR drive with valid $NAME paritition"
        DOT2="${wht}•${end}"; DOT1="${blu}|•${end}"; #M="${blk}ok${end}"

    else 

        #4
        ISMOUNTED="Mounted"
        b=4
        e=$f
        #((--f));e="${blk}•${end}" #Resets count by -1 and hides option (Menu display)
        DOT2="${grn}•${end}"; DOT1="${blk}|•${end}"; #M="${blk}no${end}"
    fi

    # Is Size < dSIZEMB?
    if [[ $SIZE =~ "M" ]] && [[ ${SIZE%%M*} -lt $dSIZE ]]; then 

        #5
        b=5;#M="${blk}no${end}" #M="no".  Not mounting the partition.  Setting b=5 (Loop through whole matrix)
        e=$f
        #((--f));e=${blk}•${end} #Resets count by -1 and hides option (Menu display)
        DOT1="${blk}•${end}"
        log err "cannot mount $NAME partition.  Size $SIZE is under dSIZE ($dSIZE) MB"      
    fi
}
logstatus()
{
    for ((i = $a ; i <= $b ; i++)); do
        arr=$(eval printf "%s' '" ${aux_a[i]})
        [[ $SCFER =~ "c" ]] && printf "${fux_a[i]}" $arr || parr=$( printf "${fux_a[i]}" $arr) \
        sub_a+=("$parr")
    done 
}


lechoice()
{
    # Parses command based on input and send to mountp() for execution

        #Command format: 
        #   1.) / (With nothing else): Presents a multiple choice menu based on <Mount_index>
        #   2.) /<Mount_index>       : Mounts a partition or set of partitions from Storage device based on <MI>
            
                y=1
                x=2
                # Now wait for user input
                while true; do

                    #Menu options
                    tput cup $y $x
                    if [[ -z $SCFER ]]; then printf "%s\n" "${grn} ** Mounting Partitions **     ${end}"
                    elif [[ $SCFER == "-r" ]]; then printf "%s\n" "${red} ** Un-mounting Partitions **${end}"; fi
                    printf "%s" "${sub_a[@]}"; echo

                    # Get command
                    printf '\e[K'
                    read -e -r -p "Your choice ${blu}|•${end} " choice  
                    #printf '\e[A\e[K'
                    # Check that user's choice is a valid number
                    if [[ $choice == "-r" ]]; then
                        SCFER="-r"
                        continue
                    elif [[ -z $choice ]]; then
                        SCFER=""
                        continue
                    elif [[ $choice = +([[:digit:]]) ]]; then
                        # Force the number to be interpreted in radix 10
                        ((choice=10#$choice))
                        # Check that choice is a valid choice
                        conditions
                        ((choice>f)) && printf "Invalid choice.  Choose a number from 1 to $e \n" || break
                    else
                    printf "Invalid choice. \n"
                    #break
                    fi
                    
                done
        
        # Mounting selection
        [[ -z $SCFER ]] && echo "Sending to emount" && eMOUNT ||\
        [[ $SCFER =~ "-r" ]] && echo "Sending to eREMO" && eREMO # ** Umount Disk

}
conditions()
{
    # Special command - execution (as needed):
            
            # Not working for some reason....
            if ((choice==93)); then
            printf "Creating matrix layout file: ${wht}_2Matrix.txt${end}\n"
                for i in "${!aux_a[@]}"; do
                printf "${fux_a[i]}" $(eval printf "%s' '" ${aux_a[i]}) >> _2Matrix.txt
                done
            exit 0

            #Prints Sub_a list with index
            elif ((choice==90)); then
            printf "\n%s\n" " ** USB Storage **"
            for i in "${!sub_a[@]}"; do printf "%s%s\n" "$i" "${sub_a[i]}"; done
            #printf "%s\n" "${sub_a[@]}" |sed -e :a -e "/$/=; /\n$/N; s/\n/:/; ta"
            exit 0

            #Prints All (Main_a) to file
            elif ((choice==91)); then
            printf "\n%s\n" " ** Main full list **"
            printf "%s\n" "${main_a[@]}" |sed -e :a -e "/=$/N; s/=\n/:/; ta" > mainlist.txt
            #printf "%s\n" "${main_a[@]}" |sed -e :a -e "/=$/=; /=$/N; s/=\n/:/; ta"
            exit 0

            elif ((choice==92)); then
            echo "e=$e | and f=$f"
            exit 0
            fi
}
eMOUNT()
{
    #Check if choice matches a valid option
    # First sed captures the line containing (#:), Second sed limits to the last three characters  
    a=$( printf "%s\n" "${sub_a[@]}" |sed "/$choice:/!d"  |sed "s/.*\(...\)/\1/" )
    
        # Sets l to base 0 (TRAN) for the current selection, so variables names can be used
        [[ ${main_a[((a-1))]} =~ "VENDOR=" ]] && ((l=a-6)) || ((l=a-4))
        ActiVe  # Enumerate with current l

        # Check if partition is already mounted
        if [[ ! -z $MTYPE ]]; then 
            #Partition is mounted ... do nothing
            printf "\n %s" "/dev/$NAME is already mounted on $MTYPE" ""
            log info "mountpoint $MTYPE is mounted already with /dev/$NAME :: Device [$lVENDOR] :: $FSTYPE"
            exit 0
        fi     
        
        # Validate if choice is mounting a device or particular partition
        if [[ ! -z $VENDOR ]]; then
            # loop through numbers until you hit an a-1 with a different name?
            # loop through NAME until it changes...
            echo "choose partition"
            exit 0
        else
            eLABEL  # Asign LABEL if needed and create media/<LABEL> mountpoint if it does not exist
        fi  
    
# Mount partition
    # Re-ensuring we are not touching ZFS drives
    if [[ $FSTYPE == "zfs_member" ]]; then
        echo "ZFS Member, not mounting"; log err "ZFS Member, not mounting"
    else
    
    DEVNAME=/dev/$NAME  
    printf "\n%s" "mount -t $FSTYPE $DEVNAME /media/$LABEL"; echo 
    log info "executing command: mount -t $FSTYPE $DEVNAME /media/$LABEL"

    # Execute mount command
    sudo mount -t $FSTYPE $DEVNAME /media/$LABEL
    fi          
}
eLABEL()
{
    if [[ -z $LABEL ]]; then 
        printf "\n%s" "$lVENDOR $NAME does not have a LABEL: Using USB$NAME "
        log info "$lVENDOR: Partition $NAME does not have a label. Attempting to use USB$NAME"
        LABEL=USB$NAME

            if [[ ! ${monty_a[@]} =~ $LABEL ]]; then
                printf "\n%s" "mkdir /media/$LABEL"
                log info "Creating /media/$LABEL mountpoint"          
                mkdir /media/$LABEL
                
            fi
    fi 
}


eREMO()
{
    #Check if choice matches a valid option
    # First sed captures the line containing (#:), Second sed limits to the last three characters  
    a=$( printf "%s\n" "${sub_a[@]}" |sed "/$choice:/!d"  |sed "s/.*\(...\)/\1/" )
    
    # Sets l to base 0 (TRAN) for the current selection, so variables names can be used
    [[ ${main_a[((a-1))]} =~ "VENDOR=" ]] && ((l=a-6)) || ((l=a-4))
    ActiVe  # Enumerate with current l

    # Validate if choice is mounting a device or particular partition
    if [[ ! -z $VENDOR ]]; then
        # loop through numbers until you hit an a-1 with a different name?
        # loop through NAME until it changes...
        echo "choose partition"
        exit 0
    
    else
    # Umount Partitions
    # Check if partition is already mounted
      
        if [[ -z $MTYPE ]]; then 
            # Prompt Partition is unmounted Already
            DEVNAME=/dev/$NAME 
            printf "%s \n" "$MTYPE is un-mounted. [$DEVNAME]  "; echo 
            log info "Partition is already un-mounted :  $FSTYPE $DEVNAME /media/$LABEL"
             
        else
            # Re-ensuring we are not touching ZFS drives
            if [[ $FSTYPE == "zfs_member" ]]; then echo "ZFS Member - umount cancelled"; log err "ZFS Member, umount cancelled"
            else
                #Partition is mounted ... Un-mount
                printf "\n %s " "" " Removing: $MTYPE :: /dev/$NAME :: Device [$lVENDOR] " ""
                sudo umount $MTYPE
                log info "umount $MTYPE /dev/$NAME :: Device [$lVENDOR] :: $FSTYPE"
            fi
        fi
    fi
}


mntpoints()
{
    shopt -s extglob nullglob
    basedir=/media
    # Add folders to array
    monty_a=( "$basedir"/*/ )
    # Remove leading basedir:
    monty_a=( "${monty_a[@]#"$basedir/"}" )
    # Remove trailing backslash
    monty_a=( "${monty_a[@]%/}" )
    log debug "enumerated mountpoints successfully"
}


instructions()
{
    echo " "
    echo "<ud> Command : ver 2.2 : Path=($0)"
    echo "Incorrect Syntax ($1) "
    echo " "
    echo " Usage: ud -[arg]"
    echo " "
    echo "Arguments [arg]:# "
    echo " a | -a  : Mounts USB drives with valid partitions"
    echo " c | -c  : Check if there are USB Storage devices connected to the system"
    echo " -r      : unmount USB Storage drives"
    echo " "
    echo "(Example:)"
    echo " ud -a: It mounts all unmounted USB Storage device parititions in the system"; echo
    log err "incorrect syntax ($1).  Exiting."
    exit 1
}


setmatrix()
{
    zfile=~/my_savanna/matrix_v3.conf

    # Set Menu lines (Set matrix variables):
    awk -F\, '{ for (i=2;i<=NF;i+=2) $i="" } 1' $zfile > 1f   #Format (Odd columns)
    awk '{$1=$1};1' ~/my_savanna/1f > 1pf_form.conf; rm 1f
    awk -F\, '{ for (i=1;i<=NF;i+=2) $i="" } 1' $zfile > 2a   #variables (Even columns)
    awk '{$1=$1};1' ~/my_savanna/2a > 2pf_args.conf; rm 2a

    mapfile -t fux_a < 1pf_form.conf
    mapfile -t aux_a < 2pf_args.conf
}

main "$@"; exit
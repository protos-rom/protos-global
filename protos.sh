#!/system/bin/sh
#####################################################
#####################################################
#####################################################
########### PROTOS SYSTEM - GLOBAL SCRIPT ###########
#####################################################
#####################################################
#####################################################
# Protos ROM is part of Protos
# PTUI is part of Protos
# Protos Toolbox is part of Protos
# (C) 2013, Protos
# Original script by Firat Dundar (FD1999)
# Last updated by Firat Dundar 2013.05.02. 13:20
#####################################################
# Here we define values to call them later          #
#####################################################
ptsd=/sdcard/Protos
config=/data/protos/globalconfig.pts
# PTS Tweaks
ver_pts=0.3
# Protos System
ver=0.1
# Protos Toolbox
ver_tbox=0.1

#####################################################
# This is the error function in case we get errors  #
#####################################################

error () {
  echo "Error: $1"
	log "Error: $1"
	exit
}

#####################################################
# This is the logging function and will be used when#
# it is enabled in the configuration file           #
#####################################################

log () {
	. $config
	log-file-size
	if [ "$logging" = "1" ]
	then
		echo "Protos: $1" >> /data/protos/log.pts
	fi
}

log-file-size () {
	filesz=`du -k "/data/protos/log.pts" | cut -f1`
	
	if (($filesz>1024))
	then
		log "Reached limit of log file"
		if [ -e /sdcard/log.pts ]
		then
			if [ -e /sdcard/log.pts1 ]
			then
				rm /sdcard/log.pts
				mv /sdcard/log.pts1 /sdcard/log.pts
				cp /data/protos/log.pts /sdcard/log.pts1
			else
				cp /data/protos/log.pts /sdcard/log.pts1
			fi
		else
			cp /data/protos/log.pts /sdcard/log.pts
		fi
		rm /data/protos/log.pts
		log "Moved log file to sdcard"
		touch /data/protos/log.pts
		log "Created log file"
	fi
}
	
	
	
	
#####################################################
# This is the function for the Protos PCSuite       #
#####################################################

ppcs-load () {
	log "Connected to PC"
	stagefright -a -o $ptsd/ppcs/connected.mp3
}

#####################################################
# Here we start with the main features              #
#####################################################

#####################################################
# Battery Calibrator                  	     	  	    #
#####################################################

calibrate () {
	log "(calibrate) Started"
	echo " "
	echo "How to use the battery calibrator"
	echo "First discharge your battery fully"
	echo "Now fully charge it without interrupts"
	echo "As soon as you done that, you press [ENTER]"
	echo "and this script will calibrate your battery"
	echo "Before pressing [ENTER], please unplug"
	echo "the charger."
	echo " "
	echo "Press [ENTER]..."
	read TEMLSB
	if [ -e /data/system/batterystats.bin ]
	then
		log "(calibrate) Found batterystats"
		echo " "
		echo "Calibrate battery now?(y/n)"
		read YN
		ynfix
		if [ "$YN" = "y" ]
		then
			echo "  * Calibrating..."
			log "(calibrate) Calibrating..."
			sleep 1
			rm /data/system/batterystats.bin
			sleep 1
			echo "Reboot now?(y/n)"
			read YN
			ynfix
			log "(calibrate) Calibrate: $YN"
			if [ "$YN" = "y" ]
			then
				reboot
			else
				exit 0
			fi
		else
			log "(calibrate) Aborted"
			exit 0
		fi
	else
		log "(calibrate) Already calibrated"
		echo "The battery is already calibrated"
		echo "Please reboot your phone in order to"
		echo "calibrate the battery"
		exit 0
	fi
}

#####################################################
# GPSFixer               									             #
#####################################################

gpsfix () {
	echo " "
	log "(gpsfix) Started"
	echo "  GPSFixer"
	echo " "
	echo "  1  =  Europe"
	echo "  2  =  Germany"
	echo "  3  =  Asia"
	echo "  4  =  North-America"
	# RESERVED
}
#####################################################
# Settings function for changing the configuration  #
#####################################################

settings () {
	log "(settings) Started"
	echo " "
	echo "Welcome!"
	echo "  1  =  Change name"
	echo "  2  =  Change screen size"
	echo "  3  =  Disable/Enable PTS Tweaks"
	echo "  4  =  Disable/Enable Logging"
	echo "  5  =  Reset data"
	echo " "
	read CH
	if [ "$CH" = "1" ]
	then
		echo "Please enter your name:"
		read NAME
		sed -i "s/^name=.*/name=$NAME/" $config
		echo "Done"
		log "(settings) Changed name"
		exit 0
	fi
	if [ "$CH" = "2" ]
	then
		echo "Please enter the screen size:"
		read SIZE
		sed -i "s/^size=.*/size=$SIZE/" $config
		echo "Done"
		log "(settings) Changed size"
		exit 0
	fi
	if [ "$CH" = "3" ]
	then
		echo "Enable PTS Tweaks?(y/n)"
		read YN
		ynfix
		if [ "$YN" = "y" ]
		then
			sed -i "s/^pts_tweaks=.*/pts_tweaks=1/" $config
			echo "Done"
		else
			sed -i "s/^pts_tweaks=.*/pts_tweaks=0/" $config
			echo "Done"
		fi
		log "(settings) Changed PTS Tweaks"
		exit 0
	fi
	if [ "$CH" = "4" ]
	then
		echo "Enable logging?(y/n)"
		read YN
		ynfix
		if [ "$YN" = "y" ]
		then
			sed -i "s/^logging=.*/logging=1/" $config
			echo "Done"
		else
			sed -i "s/^logging=.*/logging=0/" $config
			echo "Done"
		fi
		log "(settings) Changed logging"
		exit 0
	fi
	if [ "$CH" = "5" ]
	then
		log "(settings) Reset data"
		echo "Reset data?(y/n)"
		read YN
		ynfix
		if [ "$YN" = "y" ]
		then
			echo "Deleting..."
			rm /data/protos/globalconfig.pts
			rm /data/protos/log.pts
			if [ -e /data/protos/wmgcy.pts ]
			then
				rm /data/protos/wmgcy.pts
			fi
			echo "Done!"
		fi
		exit 0
	fi
}


	
#####################################################
# Protos Toolbox        							#
#####################################################

toolbox () {
	log "(toolbox) Started"
	echo "Protos Toolbox $ver_tbox"
	echo " "
	echo "Available:"
	echo "backup [--data, --system, --all]"
	echo "erase"
	echo "flash"
	echo " "
	echo "Usage:"
	echo "protos t <argument>"
	echo " "
	echo "Example:"
	echo "protos t backup --data"
	log "(toolbox) Ended"
}

toolbox_erase () {
	log "(toolbox) Erase"
	echo " "
	echo "Please select a partition you want to erase"
	echo " "
	echo "  1  =  Recovery"
	read CH
	if [ "$CH" = "1" ]
	then
		log "(toolbox) Erase recovery"
		makesure "erase recovery"
		if [ "$YN" = "y" ]
		then
			log "(toolbox) Erasing recovery"
			echo "Erasing..."
			exec 1>/dev/null 2>&1 && erase_image recovery && exec 1>/dev/tty 2>&1
			log "(toolbox) Done"
			echo "Done!"
			exit
		else
			exit
		fi
	else
		error "Invalid choice!"
	fi
}

toolbox_flash () {
	log "(toolbox) Flash"
	echo " "
	echo "Please select a partition to flash to:"
	echo " "
	echo "  1  =  Recovery"
	read CH
	if [ "$CH" = "1" ]
	then
		log "(toolbox) Flash recovery"
		echo "Please define the path to your image file:"
		read imgfile
		log "(toolbox) Imgfile: $imgfile"
		if [ -e $imgfile ]
		then
			makesure "flash to recovery"
			if [ "$YN" = "y" ]
			then
				log "(toolbox) Flashing to recovery..."
				echo "Flashing $imgfile to recovery..."
				exec 1>/dev/null 2>&1 && flash_image recovery $imgfile && exec 1>/dev/tty 2>&1
				echo "Done!"
				log "(toolbox) Done"
				exit
			else
				exit
			fi
		else
			error "Couldn't find the image file!"
		fi
	else
		error "Invalid choice!"
	fi
}

makesure () {
	echo "Are you sure you want to $1 ?"
	read YN
	ynfix
}

#####################################################
# Root verifier	    								#
#####################################################

root-verify () {
	id=`id`; id=`echo ${id#*=}`; id=`echo ${id%%\(*}`; id=`echo ${id%%gid*}`
	if test "$id" != "0" && test "$id" != "root"; then
		echo " You are not running this script as root."
		echo " Please execute 'su' and then run this script again."
		exit 1
	fi
}

#####################################################
# PTSTweaks                                         #
#####################################################

pts-tweaks () {
	log "PTSTweaks $ver_pts started"
	. $config
	if [ "$pts_tweaks" = "1" ]
	then
		# PTS Tweaks - RESERVED
		log "(ptstweaks) Sysctl tweaks"
		sysctl -w fs.file-max=165164
		echo "200" > /proc/sys/vm/dirty_expire_centisecs
		echo "500" > /proc/sys/vm/dirty_writeback_centisecs
		echo "90" > /proc/sys/vm/dirty_ratio
		echo "10" > /proc/sys/vm/vfs_cache_pressure
		echo "4096" > /proc/sys/vm/min_free_kbytes
		log "(ptstweaks) WMGCY Bootmanager"
		log "(ptstweaks) Check if enabled"
		if [ -e /data/protos/wmgcy.pts ]
		then
			. /data/protos/wmgcy.pts
			if [ "$enabled" = "1" ]
			then
				log "WMGCY enabled"
				echo " "
				echo "  WMGCY"
				echo "  1  =  Normal"
				echo "  2  =  Fastboot mode"
				echo "  3  =  Recovery mode"
				echo "  4  =  Hot reboot"
				read CH
				if [ "$CH" = "1"  ]
				then
					log "Normal boot"
				fi
				if [ "$CH" = "2" ]
				then
					log "Fastboot mode!!"
					reboot fastboot
				fi
				if [ "$CH" = "3" ]
				then
					log "Recovery mode!!"
					reboot recovery
				fi
				if [ "$CH" = "4" ]
				then
					log "Hot reboot!!"
					killall system_server
				fi
			else
				log "WMGCY not enabled"
			fi
		else
			log "WMGCY not enabled"
		fi
	else
		log "PTSTweaks is not enabled"
	fi
	log "(ptstweaks) Applying tweaks"
	setprop net.tcp.buffersize.default 4096,87380,256960,4096,16384,256960
	setprop net.tcp.buffersize.wifi 4096,87380,256960,4096,16384,256960
	setprop net.tcp.buffersize.umts 4096,87380,256960,4096,16384,256960
	setprop net.tcp.buffersize.gprs 4096,87380,256960,4096,16384,256960
	setprop net.tcp.buffersize.edge 4096,87380,256960,4096,16384,256960
	echo "1280,2560,5120,7680,12800,20480" > /sys/module/lowmemorykiller/parameters/minfree;
	echo "0,1,3,5,7,15" > /sys/module/lowmemorykiller/parameters/adj;
	echo "40" > /proc/sys/vm/swappiness
	if [ -e /sys/devices/virtual/bdi/179:0/read_ahead_kb ]; then
			echo "2048" > /sys/devices/virtual/bdi/179:0/read_ahead_kb;
	fi;
	if [ -e /sys/block/mmcblk0/queue/scheduler ]; then
		echo "sio" > /sys/block/mmcblk0/queue/scheduler
	fi;
	if [ -e /sys/block/mmcblk1/queue/scheduler ]; then
		echo "sio" > /sys/block/mmcblk1/queue/scheduler
	fi;

	if [ -e /sys/block/stl10/queue/scheduler ]; then
		echo "sio" > /sys/block/stl10/queue/scheduler
	fi;

	if [ -e /sys/block/stl11/queue/scheduler ]; then
		echo "sio" > /sys/block/stl11/queue/scheduler
	fi;

	if [ -e /sys/block/stl9/queue/scheduler ]; then
		echo "sio" > /sys/block/stl9/queue/scheduler
	fi;
	if [ -e /proc/sys/vm/page-cluster ]; then
			echo "3" > /proc/sys/vm/page-cluster;
			echo "10" > /proc/sys/vm/vfs_cache_pressure;
			echo "2000" > /proc/sys/vm/dirty_writeback_centisecs;
			echo "1000" > /proc/sys/vm/dirty_expire_centisecs;
			echo "90" > /proc/sys/vm/dirty_ratio;
			echo "4096" > /proc/sys/vm/min_free_kbytes;
			echo "10" > /proc/sys/fs/lease-break-time;
			echo "0" > /proc/sys/vm/panic_on_oom;
			echo "85" > /proc/sys/vm/dirty_background_ratio;
			echo "0" > /proc/sys/vm/oom_kill_allocating_task;
	fi;
	if [ -e sys/class/touch/switch/set_touchscreen ]; then
			echo "7035" > /sys/class/touch/switch/set_touchscreen;
			echo "8002" > /sys/class/touch/switch/set_touchscreen;
			echo "11000" > /sys/class/touch/switch/set_touchscreen;
			echo "13060" > /sys/class/touch/switch/set_touchscreen;
			echo "14005" > /sys/class/touch/switch/set_touchscreen;
	fi;
	rm -f /data/local/*.apk
	rm -f /data/local/tmp/*.apk
	rm -f /data/log/*.log
	if [ -e /data/tmp ]
	then
		rm -r /data/tmp/*
	fi
	rm -f /cache/*.apk
	rm -f /cache/*.tmp
	rm -f /cache/recovery/*.*
	rm -f /data/system/dropbox/*.txt
	rm -f /data/backup/pending/*.tmp
	if [ -e /data/tombstones ]
	then
		rm -r /data/tombstones/*
		chmod 000 /data/tombstones/
	fi
	rm -f /data/dalvik-cache/*.apk
	rm -f /data/dalvik-cache/*.tmp
	log "(ptstweaks) Finished"
}
#####################################################
########### DEV FUNCTIONS - DON'T MODIFY! ###########
#####################################################
# WMGCY Enabled/Disabler                            #
#####################################################

wmgcy-dev () {
	log "(wmgcy) Settings started"
	if [ -e /data/protos/wmgcy.pts ]
	then
		. /data/protos/wmgcy.pts
		if [ "$enabled" = "1" ]
		then
			echo "enabled=0" > /data/protos/wmgcy.pts
			echo "Disabled"
			log "(wmgcy) Disabled"
		fi
		if [ "$enabled" = "0" ]
		then
			echo "enabled=1" > /data/protos/wmgcy.pts
			log "(wmgcy) Enabled"
			echo "Enabled"
		fi
	else
		echo "enabled=1" > /data/protos/wmgcy.pts
		echo "Enabled"
		log "(wmgcy) Enabled"
	fi
	log "(wmgcy) Ended"
}

#####################################################
# Help function with available arguments            #
#####################################################

help () {
	log "(help) Started"
	echo "Protos System $ver"
	echo " "
	echo "Available:"
	echo "help [ -e ], configure, ehelp"
	echo "settings, toolbox, calibrate"
	echo "gpsfix"
	echo " "
	echo "Usage:"
	echo "protos <argument>"
	log "(help) Done"
	exit
}

ehelp () {
	log "(ehelp) Started"
	echo "Protos System $ver"
	echo " "
	echo "Available:"
	echo "help: Show help page"
	echo "  -e: Show extended help page"
	echo " "
	echo "configure: Configure Protos"
	echo " "
	echo "ehelp: Show extended help page"
	echo " "
	echo "settings: Change configuration"
	echo " "
	echo "toolbox: Start Protos Toolbox"
	echo " "
	echo "calibrate: Battery Calibrator"
	echo " "
	echo "gpsfix: GPSFixer"
	echo " "
	echo "Usage:"
	echo "protos <argument>"
	echo " "
	echo "Example:"
	echo "protos help -e"
	echo "This show the extended help page"
	log "(ehelp) Done"
	exit
}


#####################################################
# YNFixer                                           #
#####################################################

ynfix () {
	if [ "$YN" = "Y" ]
	then
		YN=y
	fi
	if [ "$YN" = "N" ]
	then
		YN=n
	fi
	if [ "$YN" = "Yes" ]
	then
		YN=y
	fi
	if [ "$YN" = "yes" ]
	then
		YN=y
	fi
	if [ "$YN" = "No" ]
	then
		YN=n
	fi
	if [ "$YN" = "no" ]
	then
		YN=n
	fi
}


#####################################################
# Configure function                                #
#####################################################

configure-header () {
	clear
	echo "Welcome to Protos"
	echo "  Please wait"
	echo " "
}

configure () {
	configure-header
	# First validate Protos
	# protos-validate -- DISABLED FOR NOW
	if [ -e $config ]
	then
		echo "Configuration file already exists."
		echo "Overwrite?(y/n)"
		read YN
		ynfix
		if [ "$YN" = "y" ]
		then
			echo "Deleting..."
			rm $config
			echo "Done!"
			configure-header
		else
			exit 0
		fi
	fi
	echo " "
	echo "Please enter your first name:"
	read NAME
	echo "Please enter the screen size in pixels (i.e. 1280x720):"
	read SIZE
	echo "Do you want to enable PTSTweaks?(y/n)"
	read PTS
	echo "Do you want to enable logging system?(y/n)"
	read LOG
	clear
	echo " "
	echo "  * Creating configuration file"
	touch $config
	echo "  * Sourcing configuration file"
	. $config
	echo "  * Writing to configuration file"
	echo "name=$NAME" >> $config
	echo "size=$SIZE" >> $config
	if [ "$PTS" = "Y" ]
	then
		PTS=1
	else
		if [ "$PTS" = "y" ]
		then
			PTS=1
		else
			PTS=0
		fi
	fi
	echo "pts_tweaks=$PTS" >> $config
	if [ "$LOG" = "Y" ]
	then
		LOG=1
	else
		if [ "$LOG" = "y" ]
		then
			LOG=1
		else
			LOG=0
		fi
	fi
	echo "logging=$LOG" >> $config
	echo "  * Creating logging file"
	if [ -e /data/protos/log.pts ]
	then
		rm /data/protos/log.pts
	fi
	touch /data/protos/log.pts
	echo "  * Writing to log file"
	log "Name: $NAME"
	log "Size: $SIZE"
	log "PTS Tweaks: $PTS"
	log "Logging: $LOG"
	log "Finished configuration"
	log " "
	echo "  * Finishing..."
	sleep 2
	help
}


#####################################################
# Check for the config file                         #
#####################################################

# First check if user is running script as root
root-verify

if [ -e $config ]
then
	. $config
	# Do this because of compatibility issues
	if [ "$1" = "help" ]
	then
		if [ "$2" = "-e" ]
		then
			ehelp
		else
			help
		fi
	fi
	if [ "$1" = "t" ]
	then
		if [ "$2" = "backup" ]
		then
			if [ "$3" = "--data" ]
			then
				toolbox_backup_data
			else
				if [ "$3" = "--system" ]
				then
					toolbox_backup_system
				else
					if [ "$3" = "--all" ]
					then
						toolbox_backup_all
					else
						toolbox
					fi
				fi
			fi
		fi
		if [ "$2" = "erase" ]
		then
			toolbox_erase
		fi
		if [ "$2" = "flash" ]
		then
			toolbox_flash
		fi
	fi
			
	# The config file exists
	# Start function
	# First check if the argument isn't empty
	# If it is, goto help function
	if [ "$1" = "" ]
	then
		help
	else
		# Else run argument
		$1
	fi
else
	# Config file doesn't exist, starting configure function
	configure
fi

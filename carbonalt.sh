#!/bin/bash
##### HEADER BEGINS #####
#
#
#	carbon
#   v20130521a
#   - While loop using tput cup to position the cursor instead of clearing the screen.
#	v20121027a (10.8 Fork)
#	- Testing begins for using with Mountain Lion.
#	- Added mountain lion to list of supported OS versions to begin to allow testing.
#	- Passed myLOGGER "$0 $- $@" to add the full command into the logs.
#	- Added a printed output to request all logs and a description of any success or failure.
#	v20120531
#	- $SOURCELIST was breaking when filenames contained spaces. Added temporary storage for IFS, 
#		and switched IFS=$(echo -en "\n\b"). This should allow for spaces in names. CLI testing
#		shows that it will work.
#	v20120527
#	- Changed disk image creation from type SPARSE to SPARSEBUNDLE to allow for creation on
#		fat32 formatted drives.
#	v20120516
#	- Resumed use of runtime () to calculate scriptRUNTIME. This combined with the
#		use of an array with ditto provides proper while looping feedback.
#		Prior to this, script was backgrounding multiple instances of ditto and exiting
#		before all data was copied.
#	- Added a new log file for ditto background process. $clog=carbon.copy.log
#	- Changed myTARGET test. If function is unable to create the directory, an error
#		is reported that the drive is read-only.
#	- Function isCOMPLETE generated an error in the calculation to determine if the copy
#		is complete or not. percentCOMPLETE was scaled to a precision of 2, causing the if
#		statement to always show that the copy exited early. Changed scale of precision to 0.
#		This resolves the error since bc is required for any float calculations. if is
#		changed to look for -ge 99 instead of -gt 99.
#	- Realized that in a prior revision, I removed refresh. This also removed allocation of
#		$source and $target. Added this back in just after running checkDIR.
#	- dittoERROR has been added into the final report just after isCOMPLETE. This should 
#		report any error messages.
#   v20120506
#   - Removed refresh rate options as they are never used.
#   - Created mySCALE function for code reuse.
#   - Removed older entries from embeded changelog.
#   v20120505
#   - Added -t option to myLOGGER calls. Allows message to be displayed on screen and 
#       saved to a log file.
#   v20120425
#   - Trying to redirect stdout/err to function myERROR.
#	v20120424
#	- In last testing, refresh rate of 30 seconds seemed to be too long. With the new for
#		loop, we are waiting on the information loop to transferring new files. Ditto
#		no longer has a constant stream of data. Changed default refresh to 10 seconds, 
#		may also try 5.
#	- Changed the test on the while loop to [ -n $i ], so that we are testing to see if 
#		$i contains data. This may work or may break use of ditto, as it possibly could
#		fail to pass back to the parent for loop.
#	- Since the while loop no longer tests runtime, we are commenting out. Runtime and 
#		all calls to it will be removed in future versions.
#	- Verified that $SECONDS can be passed to myTime function and provide proper results.
#	v20120421a
#	- Remove ;;s from line 719 wich was causing the script to error.
#	- Resolved array usage with ditto.
#	- Resolved array stepping with for loop.
#	- Elapsed time is now based on bash default variable $SECONDS
#
#	- TODO: Still need a valid method for the while loop (runtime of ditto is no longer good)
#			Need an adjusted method of reporting time elapsed.
#			Need to ensure the disk image function properly resets the target.
#			myLOGGER may not be functioning in the loops.
#	v20120415a
#	- Removed needlessly duplicated code in the section following getopts.
#	- New functions. 
#	- myLOGGER provides a method for appending log messages to a log file, splitting between
#		the regular log file and the error log file.
#	- Reattempting to split output of ditto to two log files.
#	V20120403A
#	- Completed first version of for loop management for Volumes folder. Folder should be
#		skipped during data transfer.
#	- Cleanup
#	- New code for reporting location should be simpler and hopefully faster as well as
#		actually work. Fingers crossed.
#	v20120402a
#	- Adding a for loop around the while loop to get rid of the Volumes folder deletion.
#	v20120324a
#	- Renaming script. Why? Because I want to. Also because carbon can autocomplete with a tab.
#	- Also reexamining versioning.
#
##################################### COPYRIGHT #########################################
#   Created 21 05, 2011 by H. R. Krewson
#   Copyright 2011 H. R. Krewson
#   
#   Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file 
#   except in compliance with the License. You may obtain a copy of the License at
#   
#      http://www.apache.org/licenses/LICENSE-2.0
#      
#   Unless required by applicable law or agreed to in writing, software distributed under the License 
#   is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express 
#   or implied. See the License for the specific language governing permissions and limitations under 
#   the License.
#
################################ TECHNICAL INFORMATION ####################################
#   In order to determine Approximate Amout of time it will take 
#   to copy data this script bases its calculation on some assumptions.
#   In Controlled setting, copying data via ditto:
#       USB transfer of 4.99GB took 2:21 m (1GB per 28s, 35MB/s, .02857142857s/MB)
#			Corrupted transfer estimate is 3* or 1GB per 84s, 11.9MB/s, .08403361345s/MB)
#       FW4 transfer of 4.99GB took 2:15 m (1GB per 27s, 37MB/s, .02702702703s/MB)
#			Corrupted transfer estimate is 3* or 1GB 81s, 12.35MB/s, .08100445525/MB
#       FW8 transfer of 4.99GB took 1:35 m (1GB per 19s, 52.5MB/s, .01904761905s/MB)
#			Corrupted transfer estimate is 3* or 1GB per 57s, 17.5MB/s, .05714285714s/MB 
#		TB  transfer of 9GB took approx 1:33 m (1GB per 10.3s, 96MB/s, .01041666667s/MB)
#			Corrupted transfer estimate is 3* or 1GB per 30.9s, 32.36MB/s, .03090234858s/MB
#
##### HEADER ENDS #####

###################################### GLOBAL VARIABLES ######################################
version="20130527b"                                             
width=$(tput cols)                                             #Determine width of window
refresh=10                                                     #Set default refresh
copiedRAW=0                                                    #Set the initial amount of data copied
debugON=0
sysREQ=(5 6 7 8)
SYSTEM=$(sw_vers -productVersion | awk -F. '{print $2}')
copiedTEMP=0
log=~/Library/Logs/carbon.current.log
clog=/Library/Logs/carbon.copy.log
elog=/Library/Logs/carbon.error.log
stamp=$(date +"%D %T")
today=$(date +"%m_%d_%Y")
####################################### SET DEBUG TRUE #######################################
# Enables debug mode in bash for this script and writes all debug related output to a file
#on the current user's desktop. File is labled 'DEBUG' with today's date.
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
exec 2>~/Desktop/DEBUG$today
set -x
########################################### FUNCTIONS ###########################################
myHelp ()
    {
		echo ""
        echo "Usage: `basename $0` [ <options> ] source destination"
        echo "Requires Mac OS X 10.5.x or newer."
        echo ""
        echo "       Data transfer <options> are any of:"
        echo "       -h              print full usage"
        echo ""
        echo "       -u              transfer is over USB," 
        echo "                       script will base times on average real"
        echo "                       world USB transfer rates"
        echo ""
        echo "       -4              transfer is over Firewire 400,"
        echo "                       script will base times on average real" 
        echo "                       world FW transfer rates"
        echo ""
        echo "       -8              transfer is over Firewire 800,"
        echo "                       script will base times on average real" 
        echo "                       world FW transfer rates"
        echo ""
        echo "       -t              transfer is over thunderbolt,"
        echo "                       script will base times on average real"
        echo "                       world  Thunderbolt transfer rates"
        echo ""
        echo "       -e              transfer is over ethernet,"
        echo "                       script will base times on average real"
        echo "                       world  Thunderbolt transfer rates"
        echo ""
        echo "       -v              prints the version number."
        echo ""
        echo "       -d              create a sparse disk image to copy to."
        echo "                       destination should not have the .dmg extension"
        echo "                       destination should include the location in"
        echo "                       which the dmg should be saved"
        echo "                       example: /Volumes/Backup/backup/"
        echo "                       creates: /Volumes/Backup/backup.dmg"
        echo ""
        echo ""
        echo "       source and destination are passed to ditto"
        echo ""
        echo "       ditto will run and output to a file located in:"
        echo "       /Library/Logs/"
        echo ""
        echo ""
		echo ""
    myLOGGER "Printed help message."
    }

myLOGGER ()
	{
	if [[ $1 == "-t" ]]; then
	   shift
	   echo "$*"
    fi
	if [[ $( echo $1 | egrep -w '(error\\b|error:)' ) ]]; then
        logfile=$elog
        lastERROR="$1"
    else
        logfile=$log
    fi   
	stamp=$(date +"[%m/%d/%y %H:%M:%S]")
	echo $stamp "$1" >>$logfile
	}

targTEST ()
    {
    #Function verifies we are not creating a new location in the /Volumes director
    tarTEST=$(echo $target | awk -F/ '{print $(NF-2)}')
    if [[ "$tarTEST" = "Volumes" ]]; then
        myLOGGER -t "myTARGET error: Cannot create a new location in directory /Volumes."
        exit
    fi
    }
    	
myTARGET ()
	{
    if [[ -d "$target" ]]; then
        myLOGGER "Target directory exists. $target"
    else
    	targTEST
        sudo mkdir "$target"
        if [[ -d "$target" ]]; then
        	myLOGGER "Created target directory: $target"
        else
        	myLOGGER -t "myTARGET error: Destination is read-only, cannot continue."
        	exit
        fi
    fi

    sizeInitial=$(df "$target" | awk '!/Used/ {print $3}')
    myLOGGER "Calculated size of data in $target."
	}
	
diskSpace ()
    {
    myLOGGER "---------------Function diskSpace--------------"
    clear                                                                             
    ##### CHECK SOURCE #####
    pathString "$source" source                                                             #Ensure path has a trailing /
    pathString "$target" target                                                             #Ensure path has a trailing /
    myLOGGER -t "Calculating size of data to be copied using command du. This will take some time, please be patient."
    sizeRAW=$(du -sPx "$source" | awk '{print $1}')                                         #sizeRAW is used for calculations
    myLOGGER "Calculated size of data in source folder. $sizeRAW"    
    ##### END CHECK SOURCE #####  
    ##### CHECK TARGET #####   
    if [ $mydmg -eq 1 ]; then
    	myLOGGER "Function call to myDMG."
    	myDMG
    	
    else
    	myLOGGER "Function call to myTARGET."
    	myTARGET
    fi
    ##### END CHECK TARGET #####    
    ##### HUMAN READABLE SIZE OF SOURCE #####
    mySCALE $sizeRAW
    sizeHUMAN=$(echo "scale=2; ($sizeRAW*512)/$sdiv" | bc)$sunit                            #Calculate size
    ##### END HUMAN READABLE SIZE #####
    myLOGGER "---------------End Function diskSpace--------------"
    }

mySCALE ()
    {
        if [ $1 -lt 1757813 ]; then                                                       #Is size below MB threshhold 
        sdiv=1000000 sunit=M                                                                #Size is in MB
    	myLOGGER "Size calculation in MB."
    else
        sdiv=1000000000 sunit=G                                                             #Size is in GB
    	myLOGGER "Size calculation in GB."
    fi
    }
    
myVersion ()                                                    						#Function to provide version of carbon
    {
    myLOGGER -t "carbon $version"
    exit
    }
    
myTime ()                                                       						#Calculate times from decimal values
    {
    myLOGGER "--------------Function myTime.--------------"
    time=$(echo "scale=4; $1/60/60" | bc)
    myLOGGER "Calculate $time ."
    timeHours=$(echo ${time%.*})
    if [[ $timeHours -gt 0 ]]; then
        echo ""
        myLOGGER "Time is in hours minutes and seconds. $timeHours"
    else
        timeHours=0
        myLOGGER "Time is in minutes and seconds."
    fi
    timeMinutes=$(echo "scale=0; (${time#*.}*60/10000)" | bc)
    timeMinutesP=$(echo "scale=0; (${time#*.}*60/10000)" | bc)
    timeSeconds=$(echo "scale=0; (${timeMinutesP#*.}*60/100)" | bc)
    myLOGGER "------------End Function myTime-------------"
    }

pathString ()
    {
        #  pathString checks to see if there is a trailing / character in the path arguments
        #+ if there is not, one is added. 
    if	[[ $1 != */ ]]; then
        eval "$2='$1'/"
    else
        eval "$2='$1'"
    fi
    }
    
checkDIR ()
	{
		# checkDIR looks for a file in the directory plus is run from. If a file named '0'
		#+ is found, the script attempts to remove it prior to continuing.
	if [ -e ./0 ]; then
		myLOGGER "Zero byte file located, removing."
		sudo rm ./0
	fi
	}
	
dittoERR ()
	{
	#Function to check carbon.error.log for error messages from ditto and report ().
	#Start by putting the default IFS into temporary storage and setting a new IFS.
	#Create the error list by using cat to pipe output of the log file into egrep
	#+ using -w to tell egrep to search for separate words only.
	IFSOLD=$IFS
	IFS=$'\n'
	dittoERROR=(`cat $clog | egrep -w '(error\\b|Read-only|Device not configured|No space left|No such file)'`)
	case $dittoERROR in
	   "error") echo $dittoERROR;;
	   *"Read-only"*) echo $dittoERROR; echo "ditto error: Device is read only. Reformat the drive and try again.";;
	   *"Device not configured"*) echo $dittoERROR; echo "ditto error: Drive may have unmounted. Try a different cable.";;
	   *"No space left"*) echo $dittoERROR; echo "ditto error: Drive has run out of available disk space.";;
    esac	
	IFS=$IFSOLD
	}
	
mySYSCHECK ()
	{
	sysCUR=$(sw_vers -productVersion | awk -F. '{print $2}' | tr -d '\n')
	case $sysCUR in
		3) SYSTEM=Panther;;
		4) SYSTEM=Tiger;;
		5) SYSTEM=Leopard;;
		6) SYSTEM="Snow Leopard";;
		7) SYSTEM=Lion;;
		8) SYSTEM="Mountain Lion";;
	esac
	myLOGGER "Currently running on MacOS X $(sw_vers -productVersion) $SYSTEM"
	}

myVERSREQ ()
	{
	if [[ "$sysCUR" != "${sysREQ[0]}" ]] && [[ "$sysCUR" != "${sysREQ[1]}" ]] && [[ "$sysCUR" != "${sysREQ[2]}" ]] && [[ "$sysCUR" != "${sysREQ[3]}" ]]; then
		echo "This script requires 10.6 or newer"
		echo "Current system is 10."$sysCUR
		exit
	else
		echo ""
	fi

	}
	

myDMG ()
	{
	targTEST
	#dmgsize converts sizeRAW into human readable GB, removes decimal, and adds 1GB for clearance.
	dmgsize=$(echo $sizeRAW | awk '{print ($1 * 512) / 1000000000}' | awk '{printf "%.0f\n", $1}' | awk '{print ($1 + 1)}')
	#dmgname equals the final section of $target, ie: /Volumes/Backup/backup would become dmgname=backup
	dmgname=$(echo $target | awk -F/ '{print $(NF-1)}')
	cdtarget=$(dirname $target)
	cd $cdtarget
	#Create the disk image
	myLOGGER -t "Creating a disk image of $dmgsize GB labeled $dmgname"
	hdiutil create -volname $dmgname -size $dmgsize -type SPARSEBUNDLE -fs HFS+ $dmgname
	hdiutil mount $dmgname.sparseimage
	target="/Volumes/$dmgname/"
	sizeInitial=$(df "$target" | awk '!/Used/ {print $3}')
    myLOGGER "Calculated size of data in $target."
	}
	
isCOMPLETE ()
    {
    percentCOMPLETE=$(echo "scale=0; ($copiedRAW/$sizeRAW)*100" | bc)
        
    if [[ $percentCOMPLETE -ge 99 ]]; then
    	echo "Data copy completed successfully."
    	dittoERR
    else
    	echo "Data copy exited early"
    	$percentCOMPLETE"% of data was copied"
    	dittoERR
    fi
    }
    
runtime ()
    {
    scriptRUNTIME=$(ps -ceo uid,pid,etime | grep $! | awk '{print $3}')
    }

clearMESSAGES ()
    {
    #Make a backup of the chat database file just in case
    cp ~/Library/Messages/chat.db ~/Library/Messages/chat.db.backup
    
    #Use sed to delete the offending text. The paired double quotes tell the -i option that there is no file extension.
    sed -i "" '/File\:\/\/\//d' ~/Library/Messages/chat.db
    }
##################################################################################################
touch "$log"                                  				#Create a log file if it does not exist
touch "$elog"						   									

checkDIR													   		#Check current directory for 0

source="$2"
target="$3"
echo $source $target

############################################# GETOPTS #############################################
## Based on getopts tutorial found at http://wiki.bash-hackers.org/howto/getopts_tutorial
## Base use of getopts: while getopts "OPTSTRING" VARNAME;
## Check for no opts: if ( ! getopts "OPTSTRING" VARNAME ); Placed just prior to while getopts call
# Check for valid -options being set. If no -options are specified, return usage to the user.
if ( ! getopts "u48tevhmdc" opt); then
    myLOGGER "getopts error: no flags used. Printing usage message."
    myLOGGER -t "Usage: `basename $0` options (-u48temdc) (-v version) -h for help"
    exit;
fi


myLOGGER "$0 $- $@"

# Getopts is called to check which options are being specified. Appropriate variables are set for each option.
myLOGGER "carbon called with $1 option(s)."
while getopts "u48tevhasmd" opt; do
	case $opt in
		u)	bus="USB"; type=.02857142857; typef=.08403361345; transrateL=12; transrateH=35;;
		4)	bus="FW 400"; type=.02702702703; typef=.08100445525; transrateL=12; transrateH=37;;
		8)	bus="FW 800"; type=.01904761905; typef=.05714285714; transrateL=18; transrateH=53;;
		t)	bus="Thunderbolt";  type=.01041666667; typef=.03090234858; transrateL=32; transrateH=96;;
		e)	bus="Ethernet"; type=.01904761905; typef=.05714285714; transrateL=18; transrateH=53;;
		v)  myVersion;;											
		h)	myHelp | less; exit;;	
		m)  mount -uw /; mySYSCHECK; myUSERNAME; mySETUP;;
		d)  mydmg=1;;
                c)  clearMESSAGES;;
	esac
done

############################### DETERMINE AMOUNT OF DATA AND ETA #####################################
 myLOGGER "Transferring data over $bus."
 diskSpace								
 transTimeRaw=$(echo "scale=0; (($sizeRAW*512)/1000000)*$typef" | bc) 
 myTime $transTimeRaw
 echo "We are about to copy" $sizeHUMAN"B of data."
 etaO="$timeHours Hours $timeMinutes Minutes $timeSeconds Seconds"
 echo "Transfer via $bus will take a minimum of" $timeHours" hours, "$timeMinutes" minutes, "$timeSeconds" seconds."
 echo "Transfer time estimate assumes drive is corrupted or failing."
######################################### DITTO PREFLIGHT ##########################################
mySYSCHECK
myVERSREQ
start_time=$(date +%s)                                  #Grab the current system time
cd "$source"
IFSTMP=$IFS
IFS=$(echo -en "\n\b")
SOURCELIST=($(ls -A "$source" | grep -v Volumes))
IFS=$IFSTMP
############################################# FOR LOOP #############################################
#		Date & Time
#		XXGB copied.
#		XX% completed
#		Remaining to copy: XXGB
#		Current Transfer Rate: XX MB per second
#		Expected Transfer Rate: XX to XX MB per second.
#		Original ETA:
#		Current ETA:
#		Elapsed time:
#		Currently copying data in:
#		Last file copied was:
#		
#		Error report.
#		XX errors have occured.
####################################################################################################
clear

for i in "${SOURCELIST[@]}"
	do
		echo "Copying $i"
		myLOGGER "Copying $i"
		sudo ditto -V "$i" "$target$i" 2>>$clog &
        dittoERR
        
		#sleep 4                                         # Pause the script for 4 seconds.

		runtime


echo "Copying Data From $source to $target"
echo ""
echo "               Data Copied: "
echo "          Percent Complete: "
echo "         Remaining to Copy: "
echo " "
echo "     Current Transfer Rate: "
echo "    Expected Transfer Rate: " $transrateL" to "$transrateH" MB per second"
echo ""
echo "              Original ETA: $eta0"
echo "               Current ETA: "
echo "              Elapsed Time: "
echo ""
echo "Currently Copying Items In: "
echo "          Last Item Copied: "
echo "        Last Error Message: "

while [ -n "$scriptRUNTIME" ]
    do
                sizeCOPIED=$(df "$target" | awk '{print$3}' | sed s/Used//) 
        							
        		copiedRAW=$((sizeInitial-sizeCOPIED))			#How much has been copied in RAW format                    
				copiedRAW=$(echo ${copiedRAW#-})
				
        		###### IF Statement Begins #####
        		#+determines the scale of the data copied and presents it in human readable form
        	    mySCALE $copiedRAW
        		copiedHUMAN=$(echo "scale=2; ($copiedRAW*512)/$sdiv" | bc)$sunit
        		tput cup 2 28
        		echo -n $copiedHUMAN
        		# END of if statement
        		
        		# Calculate and present the percentage of data copied
        		percentCOMPLETE=$(echo "scale=2; ($copiedRAW/$sizeRAW)*100" | bc)
        		tput cup 3 28
        		echo -n $percentCOMPLETE
        		myLOGGER "$percentCOMPLETE Percent Completed"
        		
        		###### IF Statement Begins #####
        		# Calculate and present the amount of data remaining to be copied
        		remaining=$((sizeRAW-copiedRAW))
        		mySCALE $remaining
				remainingHUMAN=$(echo "scale=2; ($remaining*512)/$sdiv" | bc)$sunit
				tput cup 4 28
				echo -n $remainingHUMAN
				# END of if statement
				
				# Transfer Rates
				copiedDELTA=$(echo "scale=0; ($copiedRAW-$copiedTEMP)" | bc )
				transSPEED=$(echo "scale=2; (($copiedDELTA/30)*512)/1000000" | bc )
				tput cup 6 28
				echo -n $transSPEED" MB per second"
				
				# Calculate the amount of time remaining
				timeLEFT=$(echo "scale=2; (($remaining*512)/1000000)*$typef" | bc)
				myTime $timeLEFT
				etaCurrent="$timeHours Hours $timeMinutes Minutes $timeSeconds Seconds"
				tput cup 10 28
				echo -n $etaCurrent
        		myTime $SECONDS
        		tput cup 11 28
        		echo -n "$timeHours Hours $timeMinutes Minutes $timeSeconds Seconds"
				
				
				# Display information on the current working directory/file and the most recent error.
				
				lastFILE="($(ls -A $i | tail -n 1))"
				tput cup 13 28
				echo -n $i
				tput cup 14 28
				echo -n "$lastFILE"
				tput cup 15 28
                echo -n "$lastERROR"
                dittoERR
				
				copiedTEMP=$copiedRAW
        		# Script will now sleep for $refresh seconds. Default value of $refresh is 10.
        		sleep $refresh
        		runtime
            done		
    done
########################################### END FOR LOOP ###########################################

########################################### FINAL REPORT ###########################################
#		Data copy completed successfully (or exited early)
#		Average transfer rate of XX MB per second.
#		Total time to transfer data: x hours, x minutes, x secs.
#		Original ETA:
#		Transfer of data is completed.
####################################################################################################
isCOMPLETE	
dittoERROR	
finish_time=$(date +%s)
total_time=$(echo "scale=2; ($finish_time - $start_time)" | bc)
transAVE=$(echo "scale=2; ((($sizeRAW*512)/1000000)/$total_time)" | bc)
echo "Average transfer rate of "$transAVE "MB per second."
myTime $total_time
echo "Total time to transfer data: $timeHours hours, $timeMinutes minutes, $timeSeconds secs." 
echo "Original ETA:" $etaO   
echo "Transfer of data is completed."				# Script has completed.
######################################### END FINAL REPORT #########################################

########################################### FILE CLEANUP ###########################################
mv $log /Library/Logs/carbon.$today.log
exit												# Script exits. Have a nice day.
############################################ END SCRIPT ############################################
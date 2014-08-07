#!/bin/bash
##### HEADER BEGINS #####
#
#
#	carbon
#   v20140807
#   - Adding error numbers for logging. See /usr/include/sysexits.h. File can be found at:
#       http://www.opensource.apple.com/source/Libc/Libc-320/include/sysexits.h
#   v20140805
#   - New calculation for space used. 
#   v20140312
#   - Removed option to clear messages database. Issue was resolved in 10.8.3 update.
#   - Update: additional logging for OS version verification steps.
#   - Update: added Mavericks to supported OS. Still needs testing to verify, but everything
#       should work without issue.
#	v20130613
#	- corrected the name of the log files
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
#   Script renamed. Some functionality has been removed to reduce bloat and because it was 
#   rarely used to the point that if we needed to do so, it was just as easy to look it up.
#   New name more accurately reflects original and current intent.
#	v1.7.3b
#	- Changes to determine whether all data was copied or not. Added two new functions
#		to facilitate this process. myERRORCOUNT and myFILECOUNT
#	v1.7.2b
#	- Further refinement of error reporting and logging. 
#	- Simplified log filename to plus.current.log.
#	- Fixed error report if statements.
#	- Change in reporting of last file copied. Currently should echo the full path of file.
#	v1.7.1b
#	- Made error scanning a function and added a call to the end of the script to report
#		what may have caused ditto to exit.
#	- Adding to the error reporting for ditto to make it more robust.
#	v1.7b
#	- Added a new section to the loop to display transfer rate speeds. 
#	- Added a new calculation to the after loop display to provide the average 
#		transfer rate.
#	v1.6.5
#	- Altered the runtime test to be -n instead of -ge. Test should now properly show 
#		time elapsed based on output from ps.
#   v1.6.4
#   - Modified $total_time to not divide by 60. This was throwing off time calculations 
#       for the total time involved.
#   - Modified while loop call to runtime(). Loop will now print runtime in separated 
#       hours, minutes and seconds instead of colon seperated.
#   - Realized the new runtime call would fail to execute properly if seconds contained 
#       a 0. Altered the call to be -ge.
#   v1.6.3
#   - Modified myTime to account for hours as well as minutes and seconds
#   - Added hours to output in order to make it easier to understand times.
#	- Updated the manual to remove two flags no longer used (-k, -x)
#	v1.6.2
#	- Call to myHelp from getopts was broken at some point in the past. Fixed this.
#	v1.6.1
#	- Changed the way it saves the log file from ditto. plus$start_time.log
#	- Working on modification of time reporting.
#	- Working on modification of data reporting for ditto progress and location.
#	v1.6.0
#	- Added new code to check the version of the current OS and verify compatibility before 
#		continuing.
#	- Code modifications to remove existing pluslog files prior to creating a new file.
#	- Code modification to better reflect transfer speeds of failing or corrupted drives.
#	- Code modification to resolve a problem with time calculation ($total_time).
#
#   List of bug fixes:
#	v1.5.4b
#	- Reverting our use of ditto and instead are removing the /Volumes folder prior to copy.
#	- Set debug on as default for the script to continue monitoring use. Removed the getopts
#		'x' option to enable debug, and removed code to turn debug on or off.
#   v1.5.3b
#   - update to the ditto command request. xargs was causing ditto to place /Macintosh HD/
#       at the root level of the drive we were copying to. Since this is unacceptable, and
#       we still need to try to keep the /Volumes folder from being copied, we are switching
#       to a single command using find -exec to locate the files and pass them to ditto
#	
#   - Unimplimented functions added to facilite streamlining of code. Fewer repetitions.
#   v1.5.1
#   - while [ -n $scriptRUNTIME ] was not properly causing the script to terminate when ditto
#       completed. Added double quotes to the variable name to properly evaluate it.
#   - scriptRUNTIME was calling ps without the -c option. This could cause scriptRUNTIME to
#       get the run time of the grep command being used to search the output of ps. If this 
#       were to happen, it might cause incorrect times or might cause the script to never terminate.
#	v1.5
#	- Sometimes the Volumes folder shows up within the root level of the hard drive 
#		(/Macintosh HD/Volumes/). Rewrote the use of ditto to avoid copying all of the volumes
#		connected. This is acheived by listing the contents of the source into an array (minus 
#		Volumes), and the passing the contents of that array via xargs into ditto.
#	- Added a new function pathString. pathString helps with the new use of ditto by checking
#		the source and target variables for a trailing '/'. If none is found, one is appended.
#	v1.4.5
#	- Set a default for variable debugON in order to not have an error when that line is parsed.
#	V1.4.4
#   - Changes to the way sizes are grabbed from du and df. df size was passing a newline 
#       character before the number causing a parse error for bc.
#   - Changes to use of command pipe strings in creating new variables. Replacing back-
#       ticks with $(). Back-ticks are an archaic format.
#   - Simplification of if statements. Create local variables to pass instead of creating 
#       two versions of one calculation.
#   v1.4.3
#	- Code change to resolve a possible error with the final While loop. Changed the test 
#       from $scriptRUNTIME > 0 to -n $scriptRUNTIME. This should avoid the scenario where 
#       it reports an error that a unary operator was expected in the while loop evaluation.
#	- Temporarily commented out the reporting feature for errors and current directory 
#       location. Example log files are needed in order to properly prepare for all 
#       reporting situations and provide accurate information.
#
#   v 1.4.1b
#   - Code changes once again to fixe time estimates and size calculations. du and df use 
#       1024 bytes as the root for calculating human readable sizes. Since Snow Leopard 
#       and Lion use 1000 bytes as the root to more accurately reflect the sizes of drives 
#       in "human" readable format, our calculations reflect this as well. We may split
#       code base to have a separate pre-SL version in order to keep consistency between 
#       the GetInfo window and sizes reported during the copy of data.
#   - Still working on the reporting of locations during the file copy as well as reporting 
#       of errors.
#   v 1.4b
#	- Code changes to fix time estimates. Estimates were incorrectly calculated in previous 
#       version, and are now more accurately reported. 
#	- Time estimate for Thunderbolt has been added, and is based upon a test performed by 
#       thenextweb.com
#	- changes to the way flags are handled to simplify the code, and in preparation for 
#       resolving an issue where the command is called with arguments but no flags and 
#       runs without error and without copying data. With no error, the user is left 
#       wondering why the command did not work. Script needs to handle this situation 
#       gracefully and provide feedback to properly inform the user of how to resolve the 
#       issue.
#	1.3b
#	- Code additions to report on current directory and last error.
#	- Code additions to provide time estimates for Thunderbolt.
#	1.2.4
#	- Resolved long standing issue where the command could be called with a destination 
#       and source but no options. Command would run with no errors, and exit without 
#       performing a copy of data. By setting an expected value for number of 
#       strings/arguments and testing for that, we now get an error message instead.
#	1.2.3
#	- Lion breaks greps use of the -o (only matching) option in conjuction with matching digits. 
#	    Switched to -e (expression) matching in order to resolve this. This option also shortens 
#       the command.
#	1.2.2
#	- Additional corrections to the variables to check the source location.
#	1.2.1
#	- While loop now tests based on scriptRUNTIME variable, and exits properly when complete.
#	1.2.0
#       - Rewrite of script to try to clean up the code. Variable names should better reflect 
#           their purpose. New function myTime to handle decimal time and present it in a 
#           human readable format. Removed some deprecated commented code that may confuse someone
#           reading through the script.
#	- Removed bugs dealing with some of the variables and causing output of sizes to be incorrect.
#       1.1.2
#       - While loop now uses calculations to determine the scale of the data copied 
#         in order to better present information (i.e. MB for sizes below .9GB)
#       - du is still used in one location, when determining the size of data to be copied
#           if the source is a folder. This is still useable in this instance, as it is only
#           run once and stored in a variable. User is warned that it will take some time
#           to determine the amount of data to copy when using this method.
#       1.1.1b
#       - Discontinue use of du command to check size of data copied.
#           du can take too long to check size of a directory when multiple
#           gigabytes of data are involved, and will cause a slow down of
#           the refresh of information as well as the process of copying data.
#       1.1.0 
#       - Adjusted diskSpace if statement to correctly asses sizes
#       - Adjusted use of df to correctly grab drive size
#       1.0.9
#       - Added two temporary variables to allow us to compare the source location 
#			to the drives in the /Volumes folder. Allows us to determine the proper
#			way to check file sizes of the source.
#   	1.0.6b
#       - More code changes to try to handle spaces in filenames
#			when passing data to ditto.
#		- Removed function to call man page from within script, as the man page
#			will properly call with the command 'man plus'.
#		- Removed unused uid variable and the unusable function to call ditto with
#			or without sudo.
#		- Removed debug 'echo' lines.
#		1.0.5 final
#		- Added double quotes to source and target variables to properly handle spaces
#	
#   	1.0.5b
#       - Code changes to try to handle spaces in filenames
#           when passing data to ditto.
#		- Code changes in use of 'du' to better handle disk space sizes.
#       1.0.2 resolved a problem in the handling of options by
#       breaking down the routine into two case statements.
#
#   But wait, where is all the stuff that happened before this? Well, as magical a time as
#   it was it is lost to the annals of history. Or not. I was spending so much time just
#   trying to figure out this scripting and versioning business that I completely ignored
#   the bits about logging changes. I should probably be drawn and quartered by those in
#   charge, however since it is I that am in charge of this monstrosity I have deemed 
#   such measures too barbaric. I suppose that I could sack the editor, but that job
#   also falls under my purview so I've decided to just let bygones be bygones. 
#
#   Did you really read all of this? Wow. Really, just wow. I don't know if I should be
#   impressed or concerned.
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
#       USB2 transfer of 4.99GB took 2:21 m (1GB per 28s, 35MB/s, .02857142857s/MB)
#			Corrupted transfer estimate is 3* or 1GB per 84s, 11.9MB/s, .08403361345s/MB)
#       USB3 113.3MB/s, .0088261253s/MB
#       FW4 transfer of 4.99GB took 2:15 m (1GB per 27s, 37MB/s, .02702702703s/MB)
#			Corrupted transfer estimate is 3* or 1GB 81s, 12.35MB/s, .08100445525/MB
#       FW8 transfer of 4.99GB took 1:35 m (1GB per 19s, 52.5MB/s, .01904761905s/MB)
#			Corrupted transfer estimate is 3* or 1GB per 57s, 17.5MB/s, .05714285714s/MB 
#		TB  transfer of 9GB took approx 1:33 m (1GB per 10.3s, 96MB/s, .01041666667s/MB)
#			Corrupted transfer estimate is 3* or 1GB per 30.9s, 32.36MB/s, .03090234858s/MB
#
################################ use of tput cup ##########################################
#       tput cup 0 0
#            Send the sequence to move the cursor to row 0, column 0 (the upper
#            left  corner  of  the  screen,  usually known as the "home" cursor
#            position).
##### HEADER ENDS #####

###################################### GLOBAL VARIABLES ######################################
version="20140807b"                                             
width=$(tput cols)                                             #Determine width of window
refresh=10                                                     #Set default refresh
copiedRAW=0                                                    #Set the initial amount of data copied
debugON=0
sysREQ=(5 6 7 8 9)
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
        exit 1
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
        	myLOGGER -t "myTARGET [ERROR]:[EX-CANTCREAT]:73 Destination is read-only."
        	exit 73
        fi
    fi
    #Below we use df and awk to extract used 512b blocks, this is innacurate
    #thanks to either the journal or a difference between block sizes on the 
    #device vs those used by HFS+ (512b vs 4096b)
    #sizeInitial=$(df "$target" | awk '!/Used/ {print $3}')
    #This innacuracy is emphasized by the following command:
    #df / | awk 'FNR == 2 {print $2,"-"$4,"-"$3}' | bc
    #which subtracts "used" and "available" blocks from total blocks.
    #A calculation which results in 512000 (262.1MB) on my 3TB drive.
    #The above sizeInitial results in 3911071072 (2.002468TB) on my drive vs.
    #the correct size of 3911583072 (2.002730TB) verified in "Get Info"
    #The more accurate method for attaining the amount of data on a drive is thus
    #df / | awk 'FNR == 2 {print"("$2,"-"$4,")*512"}' | bc
    # awk 'FNR == 2' prints from line 2 of the output. With proper formatting
    #we send directly to bc to calculate.
    sizeInitial=$(df "$target" | awk 'FNR == 2 {print "("$2,"-"$4,")*512"}' | bc)
    myLOGGER "Calculated size of data in $target."
    #by having a starting value of data in our target directory, we can more accurately
    #determine how much of our data has been copied.
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
		9) SYSTEM=Mavericks;;
	esac
	myLOGGER "Currently running on MacOS X $(sw_vers -productVersion) $SYSTEM"
	}

myVERSREQ ()
	{
	if [[ "$sysCUR" != "${sysREQ[0]}" ]] && [[ "$sysCUR" != "${sysREQ[1]}" ]] && [[ "$sysCUR" != "${sysREQ[2]}" ]] && [[ "$sysCUR" != "${sysREQ[3]}" ]] && [[ "$sysCUR" != "${sysREQ[4]}" ]]; then
		myLOGGER -t "This script requires 10.6 or newer"
		myLOGGER -t "Current system is 10."$sysCUR
		exit
	else
		myLOGGER "Supported OS."
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
if ( ! getopts "u48tevhmd" opt); then
    myLOGGER "getopts [ERROR]:[EX-USAGE]:64 - No flags used. Printing usage message."
    myLOGGER -t "Usage: `basename $0` options (-u48temd) (-v version) -h for help"
    exit 64;
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
		h)	myHelp | less; exit 0;;	
		m)  mount -uw /; mySYSCHECK; myUSERNAME; mySETUP;;
		d)  mydmg=1;;
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
#
#Time		% Complete		Copied	Remaining	Transfer Rate/Expected
#-----------------------------------------------------------------------------------------------------------------
#
#
#-----------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------
#
#ETA Original		ETA Current		Elapsed	Current Folder	Current File
#-----------------------------------------------------------------------------------------------------------------
#
#
#-----------------------------------------------------------------------------------------------------------------
#
####################################################################################################
for i in "${SOURCELIST[@]}"
	do
		echo "Copying $i"
		myLOGGER "Copying $i"
		sudo ditto -V "$i" "$target$i" 2>>$clog &
		myLOGGER "$0: copy $i return status is $?"      # Returns exit status of ditto.
        dittoERR
        
		#sleep 4                                         # Pause the script for 4 seconds.
		clear

		runtime


		while [ -n "$scriptRUNTIME" ]
    		do
        		sizeCOPIED=$(df "$target" | awk '{print$3}' | sed s/Used//) 
        							
        		copiedRAW=$((sizeInitial-sizeCOPIED))			#How much has been copied in RAW format                    
				copiedRAW=$(echo ${copiedRAW#-})
				
        		###### IF Statement Begins #####
        		#+determines the scale of the data copied and presents it in human readable form
        	    mySCALE $copiedRAW
        		copiedHUMAN=$(echo "scale=2; ($copiedRAW*512)/$sdiv" | bc)$sunit
        		echo $copiedHUMAN " copied."
        		# END of if statement
        		
        		# Calculate and present the percentage of data copied
        		percentCOMPLETE=$(echo "scale=2; ($copiedRAW/$sizeRAW)*100" | bc)
        		echo $percentCOMPLETE"% completed."
        		
        		###### IF Statement Begins #####
        		# Calculate and present the amount of data remaining to be copied
        		remaining=$((sizeRAW-copiedRAW))
        		mySCALE $remaining
				remainingHUMAN=$(echo "scale=2; ($remaining*512)/$sdiv" | bc)$sunit
				echo "Remaining to copy:" $remainingHUMAN
				# END of if statement
				
				# Transfer Rates
				copiedDELTA=$(echo "scale=0; ($copiedRAW-$copiedTEMP)" | bc )
				transSPEED=$(echo "scale=2; (($copiedDELTA/30)*512)/1000000" | bc )
				echo " Current Transfer Rate: "$transSPEED" MB per second"
				echo "Expected Transfer Rate: "$transrateL" to "$transrateH" MB per second"
				
				# Calculate the amount of time remaining
				timeLEFT=$(echo "scale=2; (($remaining*512)/1000000)*$typef" | bc)
				myTime $timeLEFT
				etaCurrent="$timeHours Hours $timeMinutes Minutes $timeSeconds Seconds"
				echo "Original ETA:" $etaO
				echo " Current ETA:" $etaCurrent
        		myTime $SECONDS
        		echo "Elapsed time: $timeHours Hours $timeMinutes Minutes $timeSeconds Seconds"
				
				
				# Display information on the current working directory/file and the most recent error.
				
				lastFILE="($(ls -A $i | tail -n 1))"
				echo "Currently copying items in: "$i
				echo "Last item copied was: $lastFILE"
                echo "Last error: $lastERROR"
                dittoERR
				
				copiedTEMP=$copiedRAW
        		# Script will now sleep for $refresh seconds. Default value of $refresh is 10.
        		sleep $refresh
        		clear
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

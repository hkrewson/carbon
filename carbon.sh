#!/bin/bash
##### HEADER BEGINS #####
#
#
#	carbon
#   v20141128
#   - fix for directory not found line 393
#   - potential fix for exit 73
#   v20141030
#   - cfTARGET.CHECK line 562 changed to avoid exitting the script unintentionally
#       even when a target directory can be created.
#   v20141021
#   - Broke many things. Script exits shortly after starting.
#   - sizeRAW was breaking the interface, should no properly print to the Start
#       interface in location 8 32.
#   - cfLOGGER.file reported illegal option " --l". Option for "l" was provided,
#       but the getopts opt had only "te" options available. Changed this to "let"
#       to solve.
#   - Line 568 (if [ $cfDMG -eq 1 ];) was returning an error for cfDISKPACE()
#       "[: -eq:] unary operator expected". This was because cfDMG did not have a default
#       value, and beause the var name was the same as a function. Switched the var name
#       to cfDMGSET and set a default value of 0. Should allow cfDISKSPACE to function 
#       properly if we are not asking for a disk image to be created (no more unary 
#       operator error).
#   - Line 551 complex and/or broke the script. 
#       sudo mkdir "$target" && cfLOGGER.file -l "Created target directory: $target" 
#       || cfLOGGER.file -t "cfTARGET [ERROR]:[EX-CANTCREAT]:73 Destination is read-only." && exit 73
#       Was supposed to make the target directory and print a success message to the logs,
#       or report as read only and exit with a failure. Ended up creating the directory, writing success
#       and exiting with failure. Second half (the or) has been commented out until we figure out
#       how to do so properly.
#   v20141015
#   - cfINTERFACE edited to have a beggining, middle and end interface.
#   - sizeRAW calculation updated. Prints top-level directory to cfINTERFACE.open
#       position 8.32 as du is calculating. See the below forum post.
#   http://www.unix.com/shell-programming-and-scripting/251905-tee-multiple-streams-create-var.html#post302921182
#   
#   v20141005
#   - cfINTERFACE Changed 1st line for end user readability, and to better indicate our
#       (E)stimated (D)ate of (C)ompletion. Function integration is in progress.
#   v20141004
#   - cfINTERFACE resizes the terminal window and positions it in the top left corner of the 
#       display. It then builds a simple textual interface. Function is added, but not yet
#       implimented.
#   v20140914
#   - Target checking is handled in one function. Code cleaning.
#   v20140911
#   - Error logging and parsing of log file from ditto is handled within the function cfLOGGER
#       using nested functions cfLOGGER.file and cfLOGGER.ditto respectively. This grouping of
#       functions is initialized during script startup. At this point, these functions should
#       handle all the same error reporting and file logging. Log parsing should be much better.
#   v20140908
#   - Breaking things. Adding in error logging and checking for ditto, and making a large 
#       change to the way this happens. Until this is incorporated, some variables are
#       broken. Notably, the new variables for $lastERROR and $lastFERROR. Once the logging
#       function is fully replaced/implimented, these variables will be working again. Until
#       then, use an older version.
#   V20140904
#   - New version of dittoERR (). This version searches subsections of the ditto log file
#       and parses errors into one of two arrays (aERROR, or aFILE). Two arrays may be 
#       overkill for this, we may change it in the future. 
#   - Added output to display the last error recorded in the ditto log file.
#   v20140829
#   - Removed "512" from the calculation for sizeInitial. This was one cause for incorrect 
#       initial values, and incorrect percentage of completion reports.
#   - Legacy flag options 'm' and 's' removed. 
#   v20140822
#   - Began working through data from log dumps. Have only gotten through the initial phase
#       (pre-copy). Lot of data to wade through and validate.
#   - Working on time calculations. Two options. One using a longer decimal value and time
#       intensive calculations. The other is to make date do the math.
#   v20140821
#   - More logging.
#   - targTEST -- if [[ -d $(dirname "$target") ]] && [[ "$tarTEST" != "Volumes" ]]
#       Should test target directory and verify we are not creating a folder in "Volumes".
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
#	- Function cfCOMPLETE generated an error in the calculation to determine if the copy
#		is complete or not. percentCOMPLETE was scaled to a precision of 2, causing the if
#		statement to always show that the copy exited early. Changed scale of precision to 0.
#		This resolves the error since bc is required for any float calculations. if is
#		changed to look for -ge 99 instead of -gt 99.
#	- Realized that in a prior revision, I removed refresh. This also removed allocation of
#		$source and $target. Added this back in just after running cfCHDIR.
#	- dittoERROR has been added into the final report just after cfCOMPLETE. This should 
#		report any error messages.
#   v20120506
#   - Removed refresh rate options as they are never used.
#   - Created cfSCALE function for code reuse.
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
#	- Verified that $SECONDS can be passed to cfTIME function and provide proper results.
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
#   - Modified cfTIME to account for hours as well as minutes and seconds
#   - Added hours to output in order to make it easier to understand times.
#	- Updated the manual to remove two flags no longer used (-k, -x)
#	v1.6.2
#	- Call to cfHELP from getopts was broken at some point in the past. Fixed this.
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
#	- Added a new function cfPATH. cfPATH helps with the new use of ditto by checking
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
#           their purpose. New function cfTIME to handle decimal time and present it in a 
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
#       - Adjusted cfDISKSPACE if statement to correctly asses sizes
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
##################################### HEADER ENDS ############################################

###################################### GLOBAL VARIABLES ######################################
version="20140807b"                                             
width=$(tput cols)                                             #Determine width of window
refresh=10  
cfDMGSET=0
#Set default refresh
copiedRAW=0                                                    #Set the initial amount of data copied
debugON=0
sysREQ=(5 6 7 8 9)
SYSTEM=$(sw_vers -productVersion | awk -F. '{print $2}')
copiedTEMP=0
stamp=$(date +"%D %T")
today=$(date +"%m%d%Y")
mkdir ~/Library/Logs/Carbon
mkdir ~/Library/Logs/Carbon/$today
touch ~/Library/Logs/Carbon/$today/debug.log
log=~/Library/Logs/Carbon/$today/message.log
clog=~/Library/Logs/Carbon/$today/copy.log
elog=~/Library/Logs/Carbon/$today/error.log
####################################### SET DEBUG TRUE #######################################
# Enables debug mode in bash for this script and writes all debug related output to a file
#on the current user's desktop. File is labled 'DEBUG' with today's date.
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
exec 2>~/Library/Logs/Carbon/$today/debug.log
set -x
########################################### FUNCTIONS ###########################################

cfHELP ()
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

cfLOGGER () 
    {
    cfLOGGER.file()
        {
        #Logfile Date Stamp
        stamp=$(date +"[%m/%d/%y %H:%M:%S]")
        
        #Branch to correct log file.
        while getopts "let" opt; do
            case "${opt}" in
                l)  shift; echo $stamp "$*" >> $log;;
                e)  shift; echo $stamp "$*" >> $elog;;
                t) shift; echo $stamp "$*" | tee -a $log >(tput cup 12 31; echo "$*") >/dev/null;;
            esac
        done
        unset OPTIND
        }
        
    cfLOGGER.ditto()
        {
    #Call passes in one variable. $1 is the iteration step number, subtracting 
    # 1 from this gives us the section of the log to parse.
     if [[ $1 == "dump" ]]; then
            cfLOGGER.file -e ${aERROR[$@]}
            cfLOGGER.file -e ${aFILE[$@]}
    else
        #Save the current internal field seperator.
        IFSOLD=$IFS
        
        #Set the internal field seperator to newline character.
        IFS=$'\n'
        
        #Initialize some arrays.
        aERROR=()
        aFILE=()
        
        #Get variables.
        COUNT=$1
    
        if [[ $COUNT -eq 0 ]]; then
        	echo
        else
            #Create a list of errors for this section.
            ERRORLIST=($(cat carbon.copy.log | sed -n "/>>>\ Copying\ ${SOURCELIST[$((COUNT-1))]}/ ,/>>>\ Copying\ ${SOURCELIST[$COUNT]}/"p | egrep -e '(No such file|error\\b|Read-only|Device not configured|No space left)'))    
            
            #Dump ERRORSLIST into an array
            for i in "${ERRORLIST[@]}"
                do
                case $i in
                    "error")cfLOGGER.file -l $i;aERROR+=($i) ;;
        	        *"Read-only"*)cfLOGGER.file -l $i; aERROR+=($i);;
        	        *"Device not configured"*)cfLOGGER.file -l $i; aERROR+=($i);;
        	        *"No space left"*)cfLOGGER.file -l $i; aERROR+=($i);;
        	        *"No such file"*)aFILE+=($i);;
                esac
                done
        
        	cfLOGGER.file -l "[.ditto]: >>> Copying ${SOURCELIST[$((COUNT-1))]}"  
        	lastERROR=$(echo ${aERROR[@]} | tail -n 1) && tput cup 12 31; echo $lastERROR
        	lastFERROR=$(echo ${aFILE[@]} | tail -n 1) && tput cup 10 31; echo $lastFERROR
        	
        fi
    fi
    #Return IFS to original value.
	IFS=$IFSOLD
    
    #Empty ERRORLIST before returning to the script.
    unset 'ERRORLIST[@]'    
        }
    #if statement only used if calling as cfLOGGER [file | ditto] $option
    if [[ $1 == "file" ]]; then
        shift
        cfLOGGER.file "$@"
    elif [[ $1 == "ditto" ]]; then 
        shift
        cfLOGGER.ditto "$*"
    fi
        
    }

cfTARGET ()
    {
    cfTARGET.VOLUMES ()
        {
        tarTEST=$(echo $target | awk -F/ '{print $(NF-2)}')
    	if [[ -d $(dirname "$target") ]] && [[ "$tarTEST" != "Volumes" ]]; then
    	    return 0
        else
            cfLOGGER.file -t "cfTARGET error: Cannot create a new location in directory /Volumes."
            cfLOGGER.file -l "cfTARGET [FAILURE]:[TARGET]:1 Directory location is invalid."
            exit 1
        fi
        }
    
    cfTARGET.CHECK ()
        {
        #Function verifies we are not creating a new location in the /Volumes director
        if [[ -d "$target" ]]; then
            return 0
        else
            return 1
        fi
        }
    
    #Check target directories.    
    if cfTARGET.CHECK; then
        #Target directory exists. 
        cfLOGGER.file -l "cfTARGET [CHECK]:[DIR]:0 directory exists. $target"
        
    elif cfTARGET.VOLUMES; then
        #Target does not exist, Location is valid.
        cfLOGGER.file -t "cfTARGET [SUCCESS]:[TARGET]:0 Directory location is valid."
        
        #Make our target directory AND print a log message. OR Location is read only AND exit with error.
        #http://mywiki.wooledge.org/BashGuide/TestsAndConditionals#Control_Operators_.28.26.26_and_.7C.7C.29
        #cmd 1 && cmd 2 || {cmd 3 && cmd 4;}
        #If cmd 1 succeeds and cmd 2 succeeds skip {;}
        #If cmd 1 fails skip && run {;}
        #Curly braces require a newline or semicolon to end.
        {sudo mkdir "$target" && cfLOGGER.file -l "Created target directory: $target";} || {cfLOGGER.file -t "cfTARGET [ERROR]:[EX-CANTCREAT]:73 Destination is read-only." && exit 73;}
    fi
    
    #cfTARGET.MAIN
    #Get size of data on target drive. 
    sizeInitial=$(df "$target" | awk 'FNR == 2 {print "("$2,"-"$4,")"}' | bc)
    cfLOGGER.file -l "cfTARGET [CALC]:[SIZE]:0 Calculated size of data in [target]:[$target]. $sizeInitial"
    
    #by having a starting value of data in our target directory, we can more accurately
    #determine how much of our data has been copied.
	}
	
cfDISKSPACE ()
    {
    cfLOGGER.file -l "---------------Function cfDISKSPACE--------------"
    clear                                                                             
    ##### CHECK SOURCE #####
    cfPATH "$source" source                                                             #Ensure path has a trailing /
    cfPATH "$target" target                                                             #Ensure path has a trailing /
    cfLOGGER.file -l "Calculating size of data to be copied using command du. This will take some time, please be patient."
    sizeRAW=$(du -a ./ | awk -v C=$(tput cup 8 32) -F'[/\t]' '{printf(C "%59s", $3) >"/dev/stderr" } END{print "" > "/dev/stderr";printf $1}')                                        #sizeRAW is used for calculations
    cfLOGGER.file -l "cfDISKSPACE [CALC]:[SIZE]:0 Calculated raw size of source. $sizeRAW"    
    ##### END CHECK SOURCE #####  
    ##### CHECK TARGET #####   
    if [ $cfDMGSET -eq 1 ]; then
    	cfLOGGER.file -l "cfDISKSPACE [FUNC]:[CALL-FUNCTION]:0 Run function cfDMG."
    	cfDMG
    	
    else
    	cfLOGGER.file -l "cfDISKSPACE [FUNC]:[CALL-FUNCTION]:0 Run function cfTARGET."
    	cfTARGET
    fi
    ##### END CHECK cfTARGET #####    
    ##### HUMAN READABLE SIZE OF SOURCE #####
    cfLOGGER.file -l "cfDISKSPACE [FUNC]:[CALL-FUNCTION]:0 Run function cfSCALE on raw size [source]:[$source] $sizeRAW."
    cfSCALE $sizeRAW
    sizeHUMAN=$(echo "scale=2; ($sizeRAW*512)/$sdiv" | bc)$sunit                            #Calculate size
    cfLOGGER.file -l "cfDISKSPACE [CALC]:[SIZE]:0 Calculated size of source in human readable format. $sizeHUMAN"
    ##### END HUMAN READABLE SIZE #####
    cfLOGGER.file -l "---------------End Function cfDISKSPACE--------------"
    }

cfSCALE ()
    {
        if [ $1 -lt 1757813 ]; then                                                       #Is size below MB threshhold 
        sdiv=1000000 sunit=M                                                                #Size is in MB
    	cfLOGGER.file -l "Size calculation in MB."
    else
        sdiv=1000000000 sunit=G                                                             #Size is in GB
    	cfLOGGER.file -l "Size calculation in GB."
    fi
    }
    
cfVERSION ()                                                    						#Function to provide version of carbon
    {
    cfLOGGER.file -t "carbon $version"
    exit
    }
    
cfTIME ()                                                       						#Calculate times from decimal values
    {
        cfTIME.date ()
        {
            dateTime=$(date -v +"$1"S) 
            tput cup 0 66; echo $dateTime
            cfLOGGER.file -l "cfTIME [DATE]:Estimated Date of Completion: $dateTime"
        }
        
        cfTIME.time ()
        {
            time=$(date -v +"$1"S +%T)  
            cfLOGGER.file -l "cfTIME [TIME]:(E)stimated (T)ime to (C)ompletion: $time ."
        }
    }

cfPATH ()
    {
        #  cfPATH checks to see if there is a trailing / character in the path arguments
        #+ if there is not, one is added. 
    if	[[ $1 != */ ]]; then
        eval "$2='$1'/"
    else
        eval "$2='$1'"
    fi
    }

# Thanks to another post on the unix.com forums, this function should no longer be required.
# http://www.unix.com/shell-programming-and-scripting/252276-whats-wrong-while-loop.html
# At one point, there was a test for something like [ $scriptRUNTIME > 0 ]
# per the above post, the "> 0" was redirecting an output to a file named "0".
# cfCHDIR ()
# 	{
# 		# cfCHDIR looks for a file in the directory plus is run from. If a file named '0'
# 		#+ is found, the script attempts to remove it prior to continuing.
# 	if [ -e ./0 ]; then
# 		cfLOGGER.file -l "cfCHDIR [SUCCESS]:[ZFILE] Zero byte file located."
# 		sudo rm ./0 && cfLOGGER.file -l "cfCHDIR [SUCCESS]:[ZFILE] Zero byte file removed."
# 	fi
# 	}
	

cfSYSCHECK ()
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
	cfLOGGER.file -l "Currently running on MacOS X $(sw_vers -productVersion) $SYSTEM"
	}

cfVERSREQ ()
	{
	if [[ "$sysCUR" != "${sysREQ[0]}" ]] && [[ "$sysCUR" != "${sysREQ[1]}" ]] && [[ "$sysCUR" != "${sysREQ[2]}" ]] && [[ "$sysCUR" != "${sysREQ[3]}" ]] && [[ "$sysCUR" != "${sysREQ[4]}" ]]; then
		cfLOGGER.file -t "This script requires 10.6 or newer"
		cfLOGGER.file -t "Current system is 10."$sysCUR
		exit
	else
		cfLOGGER.file -l "Supported OS."
	fi

	}
	
float () 
    {
    printf "%.0f\n" "$@"
    }

cfDMG ()
	{
	cfTARGET.VOLUMES
	#dmgsize converts sizeRAW into human readable GB, removes decimal, and adds 1GB for clearance.
	dmgsize=$(echo $sizeRAW | awk '{print ($1 * 512) / 1000000000}' | awk '{printf "%.0f\n", $1}' | awk '{print ($1 + 1)}')
	#dmgname equals the final section of $target, ie: /Volumes/Backup/backup would become dmgname=backup
	dmgname=$(echo $target | awk -F/ '{print $(NF-1)}')
	cdtarget=$(dirname $target)
	cd $cdtarget
	#Create the disk image
	cfLOGGER.file -t "Creating a disk image of $dmgsize GB labeled $dmgname"
	hdiutil create -volname $dmgname -size $dmgsize -type SPARSEBUNDLE -fs HFS+ $dmgname
	hdiutil mount $dmgname.sparseimage
	target="/Volumes/$dmgname/"
	sizeInitial=$(df "$target" | awk '!/Used/ {print $3}')
    cfLOGGER.file -l "Calculated size of data in [Target] directory $target."
	}
	
cfCOMPLETE ()
    {
    percentCOMPLETE=$(echo "scale=0; ($copiedRAW/$sizeRAW)*100" | bc)
        
    if [[ $percentCOMPLETE -ge 99 ]]; then
    	tput cup 8 31; echo "Data copy completed successfully."
    	tput cup 5 49; echo $percentCOMPLETE"%"
    else
    	tput cup 8 31; echo "Data copy exited early"
    	tput cup 5 49; echo $percentCOMPLETE"%"
    fi
    }
    
cfRUNTIME()
    {
    scriptRUNTIME=$(ps -ceo uid,pid,etime | grep $! | awk '{print $3}')
    }

cfINTERFACE ()
    {
    
        #http://apple.stackexchange.com/questions/33736/can-a-terminal-window-be-resized-with-a-terminal-command
        #Set width of window to 80 columns, height to 50 rows
        printf '\e[8;18;94t'    
        #Move the window to the top left corner of the display.
        printf '\e[3;0;0t'
        width=$(tput cols)
        
        #Clear the screen
        clear
        
    cfINTERFACE.start ()
        {
        #tput cup linup --   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
        #                    Ddd Mmm D HH:MM:SS ZON YYYY
         tput cup 0 0; echo "$(date)"
         tput cup 1 0; echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
         tput cup 2 0; echo "| Original ETC | ETC Current  |  Elapsed Time  |            DATA             | Transfer Rate |"
         tput cup 3 0; echo "|  (HH:MM:SS)  |  (HH:MM:SS)  |   (HH:MM:SS)   |   %   | (Copied) | (Remain) | Expect | Last |"
         tput cup 4 0; echo "|==============|==============|================|=======|==========|==========|========|======|"
         tput cup 5 0; echo "| Calculating  | Calculating  |  Calculating   |   0   |    0     |    0     |   0    |   0  |"
         tput cup 6 0; echo "|______________|______________|________________|_______|__________|__________|________|______|"
         tput cup 7 0; echo "|=============================|==============================================================|"
         tput cup 8 0; echo "|  Calculating size of folder :                                                              |"
         tput cup 9 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 10 0; echo ""
        tput cup 11 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 12 0; echo "|                             |                                                              |"
        tput cup 13 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 14 0; echo "|                             |                                                              |"
        tput cup 15 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 16 0; echo "|                             |                                                              |"
        tput cup 17 0; echo "|-----------------------------|--------------------------------------------------------------|"    
        }
        
    cfINTERFACE.run ()
        {
        
        #tput cup linup --   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
        #                    Ddd Mmm D HH:MM:SS ZON YYYY                                  EDC: Tue Oct  7 05:00:59 CDT 2014
         tput cup 0 0; echo "$(date)                                 EDC: "
         tput cup 1 0; echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
         tput cup 2 0; echo "| Original ETC | ETC Current  |  Elapsed Time  |            DATA             | Transfer Rate |"
         tput cup 3 0; echo "|  (HH:MM:SS)  |  (HH:MM:SS)  |   (HH:MM:SS)   |   %   | (Copied) | (Remain) | Expect | Last |"
         tput cup 4 0; echo "|==============|==============|================|=======|==========|==========|========|======|"
         tput cup 5 0; echo "|              |              |                |       |          |          |        |      |"
         tput cup 6 0; echo "|______________|______________|________________|_______|__________|__________|________|______|"
         tput cup 7 0; echo "|=============================|==============================================================|"
         tput cup 8 0; echo "| Currently copying in folder :                                                              |"
         tput cup 9 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 10 0; echo "|            Last file copied :                                                              |"
        tput cup 11 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 12 0; echo "|        Last file copy ERROR :                                                              |"
        tput cup 13 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 14 0; echo "|           Transferring from :                                                              |"
        tput cup 15 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 16 0; echo "|             Transferring to :                                                              |"
        tput cup 17 0; echo "|-----------------------------|--------------------------------------------------------------|"
        }
    
    cfINTERFACE.close ()
        {
        tput cup 0 0; echo "| Elapsed Time | Time Completed |    Average    |             DATA              |"
        tput cup 1 0; echo "|  (HH:MM:SS)  |   (HH:MM:SS)   | Transfer Rate |   %   | (Original) | (Backup) |"
        tput cup 2 0; echo "|==============|================|===============|=======|============|==========|"
        tput cup 3 0; echo "|              |                |               |       |            |          |"
        tput cup 4 0; echo "|______________|________________|_______________|_______|____________|__________|"
        tput cup 5 0; echo "|           |    Copy Log : ~/Library/Logs/Carbon/$today/copy.log             |"
        tput cup 6 0; echo "| Log Files |   Debug Log : ~/Library/Logs/Carbon/$today/debug.log            |"
        tput cup 7 0; echo "|           | Message Log : ~/Library/Logs/Carbon/$today/message.log          |"
        tput cup 8 0; echo "|           |   Error Log : ~/Library/Logs/Carbon/$today/error.log            |"
        tput cup 9 0; echo "|===========|===================================================================|"  
        tput cup 10 0; tput el
        tput cup 11 0; tput el
        tput cup 12 0; tput el
        tput cup 13 0; tput el
        tput cup 14 0; tput el
        tput cup 15 0; tput el
        tput cup 16 0; tput el
        tput cup 17 0; tput el
        }
    }

####################################### SCRIPT INITIALIZATION #####################################
touch "$log"                                  				#Create a log file if it does not exist
touch "$elog"						   									

cfCHDIR	#Check current directory for 0

source="$2"

target="$3"


################################### INITIALIZE NESTED FUNCTIONS ###################################
cfLOGGER 
cfTIME 
cfINTERFACE
############################################# GETOPTS #############################################
## Based on getopts tutorial found at http://wiki.bash-hackers.org/howto/getopts_tutorial
## Base use of getopts: while getopts "OPTSTRING" VARNAME;
## Check for no opts: if ( ! getopts "OPTSTRING" VARNAME ); Placed just prior to while getopts call
# Check for valid -options being set. If no -options are specified, return usage to the user.
if ( ! getopts "u48tevhd?" opt); then
    cfLOGGER.file -l "getopts [ERROR]:[EX-USAGE]:64 - No flags used. Printing usage message."
    cfLOGGER.file -t "Usage: `basename $0` options (-u48ted) (-v version) -h for help"
    exit 64;
fi


cfLOGGER.file -l "$0 $- $@"

# Getopts is called to check which options are being specified. Appropriate variables are set for each option.

cfLOGGER.file -l "carbon called with $1 option(s)."
while getopts "u48tevhd" opt; do
	case $opt in
		u)	bus="USB"; type=.02857142857; typef=.08403361345; transrateL=12; transrateH=35;;
		4)	bus="FW 400"; type=.02702702703; typef=.08100445525; transrateL=12; transrateH=37;;
		8)	bus="FW 800"; type=.01904761905; typef=.05714285714; transrateL=18; transrateH=53;;
		t)	bus="Thunderbolt";  type=.01041666667; typef=.03090234858; transrateL=32; transrateH=96;;
		e)	bus="Ethernet"; type=.01904761905; typef=.05714285714; transrateL=18; transrateH=53;;
		v)  cfVERSION;;											
		h)	cfHELP | less; exit 0;;	
		d)  cfDMGSET=1;;
		?)  why | nroff -msafer -mandoc; exit 0;;
	esac
done

############################### DETERMINE AMOUNT OF DATA AND ETA #####################################
 cfLOGGER.file -l "Transferring data over $bus."
 
 #Draw beginning interface
 cfINTERFACE.start
 
 #Get size of data to copy
 cfDISKSPACE								
 
 #Draw our main interface.
 cfINTERFACE.run
 #Calculate ETC
 transTimeRaw=$(echo "scale=0; (($sizeRAW*512)/1000000)*$typef" | bc) 
 cfTIME.date $transTimeRaw
 cfTIME.time $transTimeRaw
 tput cup 5 2; echo $time && etaO=$time
 tput cup 5 91; echo $transrateL $transrateH | awk '{printf "%d - %d", $1 $2}'
 tput cup 5 68; echo $sizeHUMAN"" | awk '{printf "%.8sB", $1}'
 tput cup 14 32; echo "$source" | awk '{printf "%-.66s", $1}'
 tput cup 16 32; echo "$target" | awk '{printf "%-.66s", $1}'

######################################### DITTO PREFLIGHT ##########################################

cfSYSCHECK
cfVERSREQ
start_time=$(date +%s)                                  #Grab the current system time
cd "$source"
IFSTMP=$IFS
IFS=$(echo -en "\n\b")
SOURCELIST=($(ls -A "$source" | grep -v Volumes))
IFS=$IFSTMP
############################################# FOR LOOP #############################################

count=0
COPIED=()
for i in "${SOURCELIST[@]}"
	do
		cfLOGGER.file -l "Copying $i"
		sudo ditto -V "$i" "$target$i" 2>>$clog &
		cfLOGGER.file -l "[ditto]: copy $i return status is $?"      # Returns exit status of ditto.
		COPIED+=($i)
        cfLOGGER.ditto $count
        
		#sleep 4                                         # Pause the script for 4 seconds.
		clear

		cfRUNTIME


		while [ -n "$scriptRUNTIME" ]
    		do
        		sizeCOPIED=$(df "$target" | awk '{print$3}' | sed s/Used//) 
        							
        		copiedRAW=$((sizeInitial-sizeCOPIED))			#How much has been copied in RAW format                    
				copiedRAW=$(echo ${copiedRAW#-})
				
        		#+determines the scale of the data copied and presents it in human readable form
        	    cfSCALE $copiedRAW
        		copiedHUMAN=$(echo "scale=2; ($copiedRAW*512)/$sdiv" | bc)$sunit
        		tput cup 5 57; echo $copiedHUMAN"B" | awk '{printf "%-.8s", $1}'
        		# END of if statement
        		
        		# Calculate and present the percentage of data copied
        		percentCOMPLETE=$(echo "scale=2; ($copiedRAW/$sizeRAW)*100" | bc)
        		tput cup 5 49; echo $percentCOMPLETE"%" | awk '{printf "%.1f", $1}'
        		
        		###### IF Statement Begins #####
        		# Calculate and present the amount of data remaining to be copied
        		remaining=$((sizeRAW-copiedRAW))
        		cfSCALE $remaining
				remainingHUMAN=$(echo "scale=2; ($remaining*512)/$sdiv" | bc)$sunit
				tput cup 5 68; echo $remainingHUMAN"B" | awk '{printf "%-.8s", $1}'
				# END of if statement
				
				# Transfer Rates
				copiedDELTA=$(echo "scale=0; ($copiedRAW-$copiedTEMP)" | bc )
				transSPEED=$(echo "scale=2; (($copiedDELTA/30)*512)/1000000" | bc )
				tput cup 5 79; echo $transSPEED | awk '{printf "%.2f MB", $1}'
				
				
				# Calculate the amount of time remaining
				timeLEFT=$(echo "scale=2; (($remaining*512)/1000000)*$typef" | bc)
				cfTIME.time $timeLEFT
				tput cup 5 17; echo $time
        		tput cup 5 32; echo "scale=4; $SECONDS/3600" | bc | awk -v EL=$SECONDS -F. '{
        		    HH=$1
        		    MM=int((EL-(HH*3600))/60)
        		    SS=(EL-((HH*3600)+(MM*60)))
        		    printf "%02d:%02d:%02d", HH,MM,SS}'
        		    
				# Display information on the current working directory/file and the most recent error.
				
				lastFILE="($(ls -A $i | tail -n 1))"
				tput cup 8 32; echo $i | awk '{printf "%-.66s", $1}'
				tput cup 10 32; echo "$lastFILE" | awk '{printf "%-.66s", $1}'
                tput cup 12 32; echo "$lastFERROR" | awk '{printf "%-.66s", $1}'
				
				copiedTEMP=$copiedRAW
        		# Script will now sleep for $refresh seconds. Default value of $refresh is 10.
        		sleep $refresh
        		clear
        		cfRUNTIME
            done		
        ((count += 1))
    done
########################################### END FOR LOOP ###########################################

########################################### FINAL REPORT ###########################################
#		Data copy completed successfully (or exited early)
#		Average transfer rate of XX MB per second.
#		Total time to transfer data: x hours, x minutes, x secs.
#		Original ETA:
#		Transfer of data is completed.
####################################################################################################
cfCOMPLETE	
cfLOGGER.ditto $count
cfLOGGER.ditto dump
cfINTERFACE.close
finish_time=$(date +%s)
total_time=$(echo "scale=2; ($finish_time - $start_time)" | bc)
copiedDELTA=$(echo "scale=0; ($copiedRAW-$copiedTEMP)" | bc )
transAVE=$(echo "scale=2; (($copiedDELTA/30)*512)/1000000" | bc )
cfTIME $total_time
tput cup 3 2; echo $time
tput cup 3 18; echo date +"%r"| awk '{printf "%-.12s", $1}'
tput cup 3 34; echo $transAVE  | awk '{printf "%.2f MB", $1}'
#tput cup 3 ; echo    				
# Script has completed.
######################################### END FINAL REPORT #########################################

########################################### FILE CLEANUP ###########################################
mv $log ~/Library/Logs/carbon.$today.log
exit												# Script exits. Have a nice day.
############################################ END SCRIPT ############################################

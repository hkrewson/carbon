#!/bin/bash
##### HEADER BEGINS #####
#
#
#   CHANGELOG
#   vNEXTSAVE
#   - Use command "cp -Rp" either in place of "ditto -V" or set up a method 
#       of determining support OS portability (Linux/Unix/OSX)
#   v1890rc1
#   - Interface tweeks. echo prints a newline character, did not take this into 
#       account when setting up the interface. Caused all printed information
#       to be one line below expectations.
#   - Added the name of the folder to cfINTERFACEstart
#   - Added the size calculated to cfINTERFACEstart
#   - Set script to pause after printing the above to allow time to read.
#   - cfINTERFACErun should now display transferring from and to properly.
#   v1889r4
#   - At some point sizeRAW was being calculated based upon the current location.
#       Instead of changing the directory to the source location, cfDISKSPACE
#       was getting disk space calculations about the log directory. Initial
#       space calculations quickly reported an incorrect and grossly under-
#       estimated size. Switched back to specifying the $source location for
#       this calculated value.
#   v1889r3
#   - cleanup.
#   - additional information in interface functions
#   v1889r2
#   - removed "clear" from while loop
#   v1889
#   - use of shellcheck.net to begin removal of possible errors (not quoting, 
#       improper command usage, lack of error checking, etc.)
#   - error checking for cfSETLOGS
#   - creation of log files, updated log file variable names
#       messages.log    -- general messages from script actions
#       copy.log        -- verbose output from ditto
#       error.log       -- error and exit messages from script actions
#       debug.log       --  verbose step tracking of script actions
#   - cfHELP moves from use of echo to printf
#   - changes to usage message format and use of basename command
#   v1888
#   - cfTARGET line 616. Edited conditional test to use compound logic based
#       on results of mkdir command.
#   v1887
#   - Error and usage message changed to use printf and provide more helpful
#       directions.
#   - Added "build" string. Located just below the version string. Build is
#       the date in %m%d format, and will be printed on a -v call.
#   v1886
#   - Added Yosemite into list of supported systems. 
#   v1885
#   - fix for directory not found line 393
#   - potential fix for exit 73
#   v1884
#   - cfTARGET.CHECK line 562 changed to avoid exitting the script 
#       unintentionally even when a target directory can be created.
#   v1883
#   - Broke many things. Script exits shortly after starting.
#   - sizeRAW was breaking the interface, should no properly print to the Start
#       interface in location 8 32.
#   - cfLOGGER.file reported illegal option " --l". Option for "l" was provided,
#       but the getopts opt had only "te" options available. Changed this to 
#       "let" to solve.
#   - Line 568 (if [ $cfDMG -eq 1 ];) was returning an error for cfDISKPACE()
#       "[: -eq:] unary operator expected". This was because cfDMG did not have
#       a default value, and beause the var name was the same as a function.
#       Switched the var name to cfDMGSET and set a default value of 0. Should
#       allow cfDISKSPACE to function properly if we are not asking for a disk 
#       image to be created (no more unary operator error).
#   - Line 551 complex and/or broke the script. 
#       sudo mkdir "$target" && cfLOGGER.file -l "Created target directory: $target" 
#       || cfLOGGER.file -t "cfTARGET [ERROR]:[EX-CANTCREAT]:73 Destination is read-only." && exit 73
#       Was supposed to make the target directory and print a success message to the logs,
#       or report as read only and exit with a failure. Ended up creating the directory, writing success
#       and exiting with failure. Second half (the or) has been commented out until we figure out
#       how to do so properly.
#   v1882
#   - cfINTERFACE edited to have a beggining, middle and end interface.
#   - sizeRAW calculation updated. Prints top-level directory to cfINTERFACE.open
#       position 8.32 as du is calculating. See the below forum post.
#   http://www.unix.com/shell-programming-and-scripting/251905-tee-multiple-streams-create-var.html#post302921182
#   
#   v1881
#   - cfINTERFACE Changed 1st line for end user readability, and to better indicate our
#       (E)stimated (D)ate of (C)ompletion. Function integration is in progress.
#   v1880
#   - cfINTERFACE resizes the terminal window and positions it in the top left corner of the 
#       display. It then builds a simple textual interface. Function is added, but not yet
#       implimented.
#   v1873
#   - Target checking is handled in one function. Code cleaning.
#   v1872
#   - Error logging and parsing of log file from ditto is handled within the function cfLOGGER
#       using nested functions cfLOGGER.file and cfLOGGER.ditto respectively. This grouping of
#       functions is initialized during script startup. At this point, these functions should
#       handle all the same error reporting and file logging. Log parsing should be much better.
#   v1871
#   - Breaking things. Adding in error logging and checking for ditto, and making a large 
#       change to the way this happens. Until this is incorporated, some variables are
#       broken. Notably, the new variables for $lastERROR and $lastFERROR. Once the logging
#       function is fully replaced/implimented, these variables will be working again. Until
#       then, use an older version.
#   v1870
#   - New version of dittoERR (). This version searches subsections of the ditto log file
#       and parses errors into one of two arrays (aERROR, or aFILE). Two arrays may be 
#       overkill for this, we may change it in the future. 
#   - Added output to display the last error recorded in the ditto log file.
#   v1860
#   - Removed "512" from the calculation for sizeInitial. This was one cause for incorrect 
#       initial values, and incorrect percentage of completion reports.
#   - Legacy flag options 'm' and 's' removed. 
#   v1853
#   - Began working through data from log dumps. Have only gotten through the initial phase
#       (pre-copy). Lot of data to wade through and validate.
#   - Working on time calculations. Two options. One using a longer decimal value and time
#       intensive calculations. The other is to make date do the math.
#   v1852
#   - More logging.
#   - targTEST -- if [[ -d $(dirname "$target") ]] && [[ "$tarTEST" != "Volumes" ]]
#       Should test target directory and verify we are not creating a folder in "Volumes".
#   v1851
#   - Adding error numbers for logging. See /usr/include/sysexits.h. File can be found at:
#       http://www.opensource.apple.com/source/Libc/Libc-320/include/sysexits.h
#   v1850
#   - New calculation for space used. 
#   v1840
#   - Removed option to clear messages database. Issue was resolved in 10.8.3 update.
#   - Update: additional logging for OS version verification steps.
#   - Update: added Mavericks to supported OS. Still needs testing to verify, but everything
#       should work without issue.
#	v1831
#	- corrected the name of the log files
#   v1830
#   - While loop using tput cup to position the cursor instead of clearing the screen.
#	v1825 (10.8 Fork)
#	- Testing begins for using with Mountain Lion.
#	- Added mountain lion to list of supported OS versions to begin to allow testing.
#	- Passed myLOGGER "$0 $- $@" to add the full command into the logs.
#	- Added a printed output to request all logs and a description of any success or failure.
#	v1824
#	- $SOURCELIST was breaking when filenames contained spaces. Added temporary storage for IFS, 
#		and switched IFS=$(echo -en "\n\b"). This should allow for spaces in names. CLI testing
#		shows that it will work.
#	v1823
#	- Changed disk image creation from type SPARSE to SPARSEBUNDLE to allow for creation on
#		fat32 formatted drives.
#	v1822
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
#   v1821 
#   - Removed refresh rate options as they are never used.
#   - Created cfSCALE function for code reuse.
#   - Removed older entries from embeded changelog.
#   v1820 
#   - Added -t option to myLOGGER calls. Allows message to be displayed on screen and 
#       saved to a log file.
#   v1810 
#   - Trying to redirect stdout/err to function myERROR.
#	v1801 
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
#	v1800
#	- Remove ;;s from line 719 wich was causing the script to error.
#	- Resolved array usage with ditto.
#	- Resolved array stepping with for loop.
#	- Elapsed time is now based on bash default variable $SECONDS
#
#	- TODO: Still need a valid method for the while loop (runtime of ditto is no longer good)
#			Need an adjusted method of reporting time elapsed.
#			Need to ensure the disk image function properly resets the target.
#			myLOGGER may not be functioning in the loops.
#	v1743 
#	- Removed needlessly duplicated code in the section following getopts.
#	- New functions. 
#	- myLOGGER provides a method for appending log messages to a log file, splitting between
#		the regular log file and the error log file.
#	- Reattempting to split output of ditto to two log files.
#	V1742 
#	- Completed first version of for loop management for Volumes folder. Folder should be
#		skipped during data transfer.
#	- Cleanup 
#	- New code for reporting location should be simpler and hopefully faster as well as
#		actually work. Fingers crossed.
#	v1741
#	- Adding a for loop around the while loop to get rid of the Volumes folder deletion.
#	v1730
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
#   - Rewrite of script to try to clean up the code. Variable names should better reflect 
#       their purpose. New function cfTIME to handle decimal time and present it in a 
#       human readable format. Removed some deprecated commented code that may confuse someone
#       reading through the script.
#	- Removed bugs dealing with some of the variables and causing output of sizes to be incorrect.
#   1.1.2
#   - While loop now uses calculations to determine the scale of the data 
#       copied in order to better present information 
#       (i.e. MB for sizes below .9GB)
#   - du is still used in one location, when determining the size of data
#       to be copied if the source is a folder. This is still useable in 
#       this instance, as it is only run once and stored in a variable. 
#       User is warned that it will take some time to determine the amount 
#       of data to copy when using this method.
#   
#   1.1.1b
#   - Discontinue use of du command to check size of data copied. du can take
#       too long to check size of a directory when multiple gigabytes of data
#       are involved, and will cause a slow down of the refresh of information
#       as well as the process of copying data.
#   
#   1.1.0 
#   - Adjusted cfDISKSPACE if statement to correctly asses sizes
#   - Adjusted use of df to correctly grab drive size
#   
#   1.0.9
#   - Added two temporary variables to allow us to compare the source
#       location to the drives in the /Volumes folder. Allows us to 
#       determine the proper way to check file sizes of the source.
#   
#   1.0.6b
#   - More code changes to try to handle spaces in filenames when passing data
#       to ditto.
#	- Removed function to call man page from within script, as the man page
#		will properly call with the command 'man plus'.
#	- Removed unused uid variable and the unusable function to call ditto
#       with or without sudo.
#	- Removed debug 'echo' lines.
#
#	1.0.5 final
#	- Added double quotes to source and target variables to properly handle
#       spaces
#	
#   1.0.5b
#   - Code changes to try to handle spaces in filenames when passing data to
#       ditto.
#	- Code changes in use of 'du' to better handle disk space sizes.
#   
#   1.0.2 
#   - resolved a problem in the handling of options by breaking down the routine
#       into two case statements.
#
#   But wait, where is all the stuff that happened before this? Well, as magical 
#   a time as it was it is lost to the annals of history. Or not. I was spending 
#   so much time just trying to figure out this scripting and versioning 
#   business that I completely ignored the bits about logging changes. I should
#   probably be drawn and quartered by those in charge, however since it is I
#   that am in charge of this monstrosity I have deemed such measures too 
#   barbaric. I suppose that I could sack the editor, but that job also falls 
#   under my purview so I've decided to just let bygones be bygones. 
#
#   Did you really read all of this? Wow. Really, just wow. I don't know if I 
#   should be impressed or concerned.
#
################################# COPYRIGHT ####################################
#   Created 21 05, 2011 by H. R. Krewson
#   Copyright 2011 H. R. Krewson
#   
#   Licensed under the Apache License, Version 2.0 (the "License"); you may not 
#   use this file except in compliance with the License. You may obtain a copy 
#   of the License at
#   
#      http://www.apache.org/licenses/LICENSE-2.0
#      
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT 
#   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the 
#   License for the specific language governing permissions and limitations 
#   under the License.
#
################################ ERROR CODES ###################################
#   www.tldp.org/LDP/abs/html/exitcodes.html
#   opensource.apple.com/source/Libc/Libc-320/include/sysexits.h
########################### TECHNICAL INFORMATION ##############################
#   In order to determine Approximate Amout of time it will take to copy data 
#       this script bases its calculation on some assumptions.
#   In Controlled setting, copying data via ditto:
#       USB2 transfer of 4.99GB took 2:21 m 
#           (1GB per 28s, 35MB/s, .02857142857s/MB)
#			Corrupted transfer estimate is 3* or 1GB per 84s, 11.9MB/s, 
#               .08403361345s/MB)
#       USB3 113.3MB/s, .0088261253s/MB
#       FW4 transfer of 4.99GB took 2:15 m 
#           (1GB per 27s, 37MB/s, .02702702703s/MB)
#			Corrupted transfer estimate is 3* or 1GB 81s, 12.35MB/s, 
#               .08100445525/MB
#       FW8 transfer of 4.99GB took 1:35 m 
#           (1GB per 19s, 52.5MB/s, .01904761905s/MB)
#			Corrupted transfer estimate is 3* or 1GB per 57s, 17.5MB/s, 
#               .05714285714s/MB 
#		TB  transfer of 9GB took approx 1:33 m 
#           (1GB per 10.3s, 96MB/s, .01041666667s/MB)
#			Corrupted transfer estimate is 3* or 1GB per 30.9s, 32.36MB/s, 
#               .03090234858s/MB
#
############################## HEADER ENDS #####################################

############################ VERSION VARIABLES #################################
version="1.8.8.9r4"  
build="0429"
YEAR="2016"
cfbname=$(basename -s .sh "$0")
############################ VERSION VARIABLES #################################

############################ GLOBAL VARIABLES ##################################
width=$(tput cols)                  #Determine width of window
refresh=10                          #Set default refresh
cfDMGSET=0
copiedRAW=0                         #Set the initial amount of data copied
sysREQ=(5 6 7 8 9 10)
swVERS=$(sw_vers -productVersion | tr -d '\n')
copiedTEMP=0
stamp=$(date +"%D %T")
today=$(date +"%a_%h_%d_%H-%M%p")
############################ GLOBAL VARIABLES ##################################

############################### LOG FILES ######################################
dlog="debug.log"
mlog="message.log"
clog="copy.log"
elog="error.log"
############################### LOG FILES ######################################

################################# FUNCTIONS ####################################

cfHELP ()
    {
		printf "\n"
        printf "Usage: %s [ <options> ] source destination\n" "$cfbname"
        printf "Requires Mac OS X 10.5 (Leopard) or newer.\n"
        printf "\n"
        printf "       Data transfer <options> are any of:\n"
        printf "       -h              print full usage (this message).\n"
        printf ""
        printf "       -u              transfer is over USB,\n" 
        printf "                       script will base times on average real\n"
        printf "                       world USB transfer rates\n"
        printf "\n"
        printf "       -4              transfer is over Firewire 400,\n"
        printf "                       script will base times on average real\n" 
        printf "                       world FW transfer rates\n"
        printf "\n"
        printf "       -8              transfer is over Firewire 800,\n"
        printf "                       script will base times on average real\n" 
        printf "                       world FW transfer rates\n"
        printf "\n"
        printf "       -t              transfer is over thunderbolt,\n"
        printf "                       script will base times on average real\n"
        printf "                       world  Thunderbolt transfer rates\n"
        printf "\n"
        printf "       -e              transfer is over ethernet,\n"
        printf "                       script will base times on average real\n"
        printf "                       world  Thunderbolt transfer rates\n"
        printf "\n"
        printf "       -v              prints the version number.\n"
        printf "\n"
        printf "       -d              create a sparse disk image to copy to.\n"
        printf "                       destination should not have the .dmg\n" 
        printf "                       extension destination should include the\n"
        printf "                       location in which the dmg should be saved\n"
        printf "                       example: /Volumes/Backup/backup/\n"
        printf "                       creates: /Volumes/Backup/backup.dmg\n"
        printf "\n"
        printf "\n"
        printf "       source and destination are passed to ditto\n"
        printf "\n"
        printf "       ditto will run and output to a file located in:\n"
        printf "       %s/Library/Logs/\n" "$HOME"
        printf "\n"
        printf "\n"
        printf "%s ${version} (${build})\n" "$cfbname"
		printf "\n"
    myLOGGER "Printed help message."
    }
    
cfSETLOGS ()
	{
	#Find the user Log folder (OS X Only)
	cd "$HOME"/Library/Logs || \
	{ cfLOGGER.file "cfSETLOGS error: cannot locate user log folder" && exit 66 ;}

    #Verify Carbon directory exists.
	if [[ ! -d Carbon ]]; then
		mkdir Carbon || \
		{ cfLOGGER.file -e "cfSETLOGS error: cannot create log folder" && exit 73;}
	fi
    
    #Make a new directory for today's logs, change to that directory
	cd Carbon/ || exit 66
	mkdir "$today" || exit 73
    cd "$today" || exit 66
    
    #Make log files for
    #debug
    touch $dlog
    #messages
	touch $mlog
	#copy process
	touch $clog
	#errors
	touch $elog
	}

cfDEBUG ()
	{
	# Enables debug mode in bash for this script and writes all debug related 
	# output to a file on the current user's desktop. File is labled 'DEBUG' 
	# with today's date.
	export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
	exec 2>"$HOME"/Library/Logs/Carbon/"$today"/"$dlog"
	set -x
	}
	

cfLOGGER.file()
    {
        #Logfile Date Stamp
        stamp=$(date +"[%m/%d/%y %H:%M:%S]")
        
        #Branch to correct log file.
        while getopts "let" opt; do
            case "${opt}" in
                l) shift; echo "$stamp" "$*" >> $mlog;;
                e) shift; echo "$stamp" "$*" >> $elog;;
                t) shift; echo "$stamp" "$*" | tee -a $mlog >(tput cup 12 31; echo "$*") >/dev/null;;
            esac
        done
        unset OPTIND
    }
        
cfLOGGER.ditto()
    {
    #Call passes in one variable. $1 is the iteration step number, subtracting 
    # 1 from this gives us the section of the log to parse.
     if [[ $1 == "dump" ]]; then
            cfLOGGER.file -e "${aERROR[$@]}"
            cfLOGGER.file -e "${aFILE[$@]}"
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
                    "error")cfLOGGER.file -l "$i";aERROR+=("$i") ;;
        	        *"Read-only"*)cfLOGGER.file -l "$i"; aERROR+=("$i");;
        	        *"Device not configured"*)cfLOGGER.file -l "$i"; aERROR+=("$i");;
        	        *"No space left"*)cfLOGGER.file -l "$i"; aERROR+=("$i");;
        	        *"No such file"*)aFILE+=("$i");;
                esac
                done
        
        	cfLOGGER.file -l "[.ditto]: >>> Copying ${SOURCELIST[$((COUNT-1))]}"  
        	lastERROR=$(echo "${aERROR[@]}" | tail -n 1) \
        	            && tput cup 12 31; echo "$lastERROR"
        	lastFERROR=$(echo "${aFILE[@]}" | tail -n 1) \
        	            && tput cup 10 31; echo "$lastFERROR"
        	
        fi
    fi
    #Return IFS to original value.
	IFS=$IFSOLD
    
    #Empty ERRORLIST before returning to the script.
    unset 'ERRORLIST[@]'    
    }


cfTARGET ()
    {
    cfTARGET.VOLUMES ()
        {
        tarTEST=$(echo "$target" | awk -F/ '{print $(NF-2)}')
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
        cfLOGGER.file -t \
            "cfTARGET [SUCCESS]:[TARGET]:0 Directory location is valid."
        #http://unix.stackexchange.com/questions/88850/precedence-of-the-shell-logical-operators
        #http://mywiki.wooledge.org/BashGuide/TestsAndConditionals
        { mkdir "$target" && cfLOGGER.file -l \
            "Created target directory: $target" ;} || \
        { cfLOGGER.file -t \
            "cfTARGET [ERROR]:[EX-CANTCREAT]:73 Destination is read-only." \
            &&  exit 73 ;}

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
    ##### CHECK SOURCE #####
    cfPATH "$source" source                                                             #Ensure path has a trailing /
    cfPATH "$target" target                                                             #Ensure path has a trailing /
    
    #Calculate raw data size
    cfLOGGER.file -l "Calculating size of data to be copied using command du. This will take some time, please be patient."
    
    # du gets raw size. awk sets a cursor location (tput cup), grabs the raw 
    # size total, and prints to screen.
    tput cup 8 32; echo "$source"
    sizeRAW=$(du -a "$source" | awk -v C=$(tput cup 8 32) -F'[/\t]' '{printf(C "%59s", $3) >"/dev/stderr" } END{print "" > "/dev/stderr";printf $1}')                                        #sizeRAW is used for calculations
    cfLOGGER.file -l "cfDISKSPACE [CALC]:[SIZE]:0 Calculated raw size of source. $sizeRAW"    


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
    cfSCALE "$sizeRAW"
    sizeHUMAN=$(echo "scale=2; ($sizeRAW*512)/$sdiv" | bc)$sunit                            #Calculate size
    cfLOGGER.file -l "cfDISKSPACE [CALC]:[SIZE]:0 Calculated size of source in human readable format. $sizeHUMAN"
    
    tput cup 10 2; echo "Calculated size of folder"
    tput cup 10 32; echo "$sizeHUMAN$sunit"
    
    sleep 5
    
    ##### END HUMAN READABLE SIZE #####
    cfLOGGER.file -l "---------------End Function cfDISKSPACE--------------"
    }

cfSCALE ()
    {
        if [ "$1" -lt 1757813 ]; then                                                       #Is size below MB threshhold 
        sdiv=1000000 sunit=MB                                                                #Size is in MB
    	cfLOGGER.file -l "Size calculation in MB."
    else
        sdiv=1000000000 sunit=GB                                                             #Size is in GB
    	cfLOGGER.file -l "Size calculation in GB."
    fi
    }
    
cfVERSION ()                                                    						#Function to provide version of carbon
    {
    cfLOGGER.file -l "Call to cfVERSION"
        printf "%s %s (%s)\n" "${cfbname}" "${version}" "${build}"
        printf "Last revision written in %s\n" "${YEAR}"
        printf "Copyright (C) 2011 H. R. Krewson\n"
        printf "Licensed under the Apache License, Version 2.0\n"
        printf "http://www.apache.org/licenses/LICENSE-2.0\n"
        printf "\n"
        printf "Written by H. R. Krewson.\n"
    exit
    }
    
cfTIME ()                                                       						#Calculate times from decimal values
    {
        cfTIME.date ()
        {
            dateTime=$(date -v +"$1"S) 
            tput cup 0 66; echo "$dateTime"
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
    if	[[ "$1" != */ ]]; then
        eval "$2='$1'/"
    else
        eval "$2='$1'"
    fi
    }

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
		10) SYSTEM=Yosemite;;
	esac
	cfLOGGER.file -l "Currently running on MacOS X $swVERS $SYSTEM"
	}

cfVERSREQ ()
	{
	if [[ "$sysCUR" != "${sysREQ[0]}" ]] && [[ "$sysCUR" != "${sysREQ[1]}" ]] && [[ "$sysCUR" != "${sysREQ[2]}" ]] && [[ "$sysCUR" != "${sysREQ[3]}" ]] && [[ "$sysCUR" != "${sysREQ[4]}" ]] && [[ "$sysCUR" != "${sysREQ[5]}" ]]; then
		cfLOGGER.file -t "This script requires 10.6 or newer"
		cfLOGGER.file -t "Current system is $swVERS"
		exit 72
	else
		cfLOGGER.file -l "Installed OS $swVERS is supported."
		return 0
	fi

	}
	
# cfFLOAT () 
#     {
#     printf "%.0f\n" "$@"
#     }

cfDMG ()
	{
	cfTARGET.VOLUMES
	#dmgsize converts sizeRAW into human readable GB, removes decimal, and adds 1GB for clearance.
	dmgsize=$(echo "$sizeRAW" | awk '{print ($1 * 512) / 1000000000}' | awk '{printf "%.0f\n", $1}' | awk '{print ($1 + 1)}')
	#dmgname equals the final section of $target, ie: /Volumes/Backup/backup would become dmgname=backup
	dmgname=$(echo "$target" | awk -F/ '{print $(NF-1)}')
	cdtarget=$(dirname "$target")
	cd "$cdtarget"
	#Create the disk image
	cfLOGGER.file -t "Creating a disk image of $dmgsize GB labeled $dmgname"
	hdiutil create -volname "$dmgname" -size "$dmgsize" -type SPARSEBUNDLE -fs HFS+ "$dmgname"
	hdiutil mount "$dmgname".sparseimage
	target="/Volumes/$dmgname/"
	sizeInitial=$(df "$target" | awk '!/Used/ {print $3}')
    cfLOGGER.file -l "Calculated size of data in [Target] directory $target."
	}
	
cfCOMPLETE ()
    {
    percentCOMPLETE=$(echo "scale=0; ($copiedRAW/$sizeRAW)*100" | bc)
        
    if [[ "$percentCOMPLETE" -ge 99 ]]; then
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

cfINTERFACEinit ()
    {
        #Initialize interface by setting up a window size and position.
        
        #http://apple.stackexchange.com/questions/33736/can-a-terminal-window-be-resized-with-a-terminal-command
        #Set width of window to 80 columns, height to 18 rows
        printf '\e[8;18;94t'    
        #Move the window to the top left corner of the display.
        printf '\e[3;0;0t'
        width=$(tput cols)
        
        #Clear the screen
        clear
    }
        
cfINTERFACEstart ()
    {
        #Initialize the start interface. This will display while attempting to 
        # determine how much data is being copied and how long the process will 
        # be expected to take.
        
        clear
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
        tput cup 10 0; echo "|                             :                                                              |"
        tput cup 11 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 12 0; echo "|                             |                                                              |"
        tput cup 13 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 14 0; echo "|                             |                                                              |"
        tput cup 15 0; echo "|-----------------------------|--------------------------------------------------------------|"
        tput cup 16 0; echo "|                             |                                                              |"
        tput cup 17 0; echo -n "|-----------------------------|--------------------------------------------------------------|"    
    }
        
cfINTERFACErun ()
    {
        #Initialize the runtime interface. While data is being copied, this is 
        # the interface displayed. Information about how long the process is 
        # taking (including a comparison between original estimate and current),
        # how much data has been copied vs how much remains, expected vs actual
        # rate of file transfer, as well as information about which files and 
        # locations are currently being worked on and the most recent error
        # message if there is one.
        
        clear
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
        tput cup 17 0; echo -n "|-----------------------------|--------------------------------------------------------------|"
    }
    
cfINTERFACEclose ()
    {
        #Initialize the closing interface. This will be the last thing the 
        # script will present, with information about how long the process took
        # the average rate of transfer (calculated), and how much data was
        # copied to the destination.
        
        # start by clearing the screen
        clear
         tput cup 0 0; tput el; echo "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
         tput cup 1 0; tput el; echo "| Elapsed Time | Time Completed |    Average    |             DATA              |"
         tput cup 2 0; tput el; echo "|  (HH:MM:SS)  |   (HH:MM:SS)   | Transfer Rate |   %   | (Original) | (Backup) |"
         tput cup 3 0; tput el; echo "|==============|================|===============|=======|============|==========|"
         tput cup 4 0; tput el; echo "|              |                |               |       |            |          |"
         tput cup 5 0; tput el; echo "|______________|________________|_______________|_______|____________|__________|"
         tput cup 6 0; tput el; echo "|                                        |    Copy Log : copy.log               |"
         tput cup 7 0; tput el; echo "| Log Files located within directory:    |   Debug Log : debug.log              |"
         tput cup 8 0; tput el; echo "|      username/Library/Logs/Carbon/     | Message Log : message.log            |"
         tput cup 9 0; tput el; echo "|                                        |   Error Log : error.log              |"
        tput cup 10 0; tput el; echo -n "|========================================|======================================|"  
        tput cup 11 0; tput el
        tput cup 12 0; tput el
        tput cup 13 0; tput el
        tput cup 14 0; tput el
        tput cup 15 0; tput el
        tput cup 16 0; tput el
        tput cup 17 0; tput el
    }

####################################### SCRIPT INITIALIZATION #####################################
#Function Init
cfSETLOGS
cfDEBUG						   									
cfLOGGER 
cfTIME 
cfINTERFACEinit

#Start Checking Variables

# USAGE="Usage: `basename $0` options (-u48ted) (-v version) -h for help"
# opt=${1:?"Error. ${USAGE}"}
# SOURCE=${2:?"Error. You must supply a source directory."}
# TARGET=${3:?"Error. You must supply a target directory."}
source="$2"
target="$3"

############################################# GETOPTS #############################################
## Based on getopts tutorial found at http://wiki.bash-hackers.org/howto/getopts_tutorial
## Base use of getopts: while getopts "OPTSTRING" VARNAME;
## Check for no opts: if ( ! getopts "OPTSTRING" VARNAME ); Placed just prior to while getopts call
# Check for valid -options being set. If no -options are specified, return usage to the user.
if ( ! getopts "u48tevhd?" opt); then
    cfLOGGER.file -l "getopts [ERROR]:[EX-USAGE]:64 - No flags used. Printing usage message."
    printf "Usage: %s [-u48ted] SOURCE DESTINATION\n" "$cfbname"
    printf "   or: %s -v\n" "$cfbname"
    printf "   or: %s -h for help\n" "$cfbname"
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
	esac
done

############################### DETERMINE AMOUNT OF DATA AND ETA #####################################
 cfLOGGER.file -l "Transferring data over $bus."
 
 #Draw beginning interface
 cfINTERFACEstart
 
 #Get size of data to copy
 cfDISKSPACE								
 
 #Draw our main interface.
 cfINTERFACErun
 #Calculate ETC
 transTimeRaw=$(echo "scale=0; (($sizeRAW*512)/1000000)*$typef" | bc) 
 cfTIME.date "$transTimeRaw"
 cfTIME.time "$transTimeRaw"
 tput cup 5 2; echo "$time" && etaO="$time"
 tput cup 5 91; echo "$transrateL" "$transrateH" | awk '{printf "%d - %d", $1 $2}'
 tput cup 5 68; echo "$sizeHUMAN" | awk '{printf "%.8sB", $1}'
 tput cup 14 32; echo "$source" | awk '{printf "%-.66s", $0}'
 tput cup 16 32; echo "$target" | awk '{printf "%-.66s", $0}'

######################################### DITTO PREFLIGHT ##########################################

cfSYSCHECK
cfVERSREQ
start_time=$(date +%s)                                  #Grab the current system time
IFSTMP=$IFS
IFS=$(echo -en "\n\b")
SOURCELIST=($(ls -A "$source" | grep -v Volumes))
IFS=$IFSTMP
############################################# FOR LOOP #############################################

count=0
COPIED=()
for i in "${SOURCELIST[@]}"
	do
	    #copy stage. Write current directory to log, initiate copy.
		cfLOGGER.file -l "Copying $i"
		sudo ditto -V "$i" "$target$i" 2>>$clog &
		cfLOGGER.file -l "[ditto]: copy $i return status is $?"      # Returns exit status of ditto.
		COPIED+=($i)
        cfLOGGER.ditto $count
        

		cfRUNTIME


		while [ -n "$scriptRUNTIME" ]
    		do
        		sizeCOPIED=$(df "$target" | awk '{print$3}' | sed s/Used//) 
        		
        		#How much has been copied in RAW format 					
        		copiedRAW=$((sizeInitial-sizeCOPIED))			                   
				copiedRAW=$(echo ${copiedRAW#-})
				
        		#determines the scale of the data copied and presents it in
        		# human readable form
        	    cfSCALE $copiedRAW
        		copiedHUMAN=$(echo "scale=2; ($copiedRAW*512)/$sdiv" | bc)$sunit
        		tput cup 5 57; echo $copiedHUMAN"B" | awk '{printf "%-.8s", $1}'

        		# Calculate and present the percentage of data copied
        		percentCOMPLETE=$(echo "scale=2; ($copiedRAW/$sizeRAW)*100" | bc)
        		tput cup 5 49; echo "$percentCOMPLETE" | awk '{printf "%.1f", $1}'
        		
        		# Calculate and present the amount of data remaining to be copied
        		remaining=$((sizeRAW-copiedRAW))
        		cfSCALE "$remaining"
				remainingHUMAN=$(echo "scale=2; ($remaining*512)/$sdiv" | bc)"$sunit"
				tput cup 5 68; echo "$remainingHUMAN" | awk '{printf "%-.8s", $1}'

				# Transfer Rates
				copiedDELTA=$(echo "scale=0; ($copiedRAW-$copiedTEMP)" | bc )
				transSPEED=$(echo "scale=2; (($copiedDELTA/30)*512)/1000000" | bc )
				tput cup 5 79; echo "$transSPEED" | awk '{printf "%.2f MB", $1}'
				
				# Calculate the amount of time remaining
				timeLEFT=$(echo "scale=2; (($remaining*512)/1000000)*$typef" | bc)
				cfTIME.time "$timeLEFT"
				tput cup 5 17; echo "$time"
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
				
				copiedTEMP="$copiedRAW"
				
        		# Script will now sleep for $refresh seconds. Default value of $refresh is 10.
        		sleep "$refresh"
        		
        		#update runtime variable
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
cfLOGGER.ditto "$count"
cfLOGGER.ditto dump
cfINTERFACEclose
finish_time=$(date +%s)
total_time=$(echo "scale=2; ($finish_time - $start_time)" | bc)
copiedDELTA=$(echo "scale=0; ($copiedRAW-$copiedTEMP)" | bc )
transAVE=$(echo "scale=2; (($copiedDELTA/30)*512)/1000000" | bc )
cfTIME "$total_time"
tput cup 3 2; echo "$time"
tput cup 3 18; echo date +"%r"| awk '{printf "%-.12s", $1}'
tput cup 3 34; echo "$transAVE"  | awk '{printf "%.2f MB", $1}'
#tput cup 3 ; echo    				
# Script has completed.
######################################### END FINAL REPORT #########################################

########################################### FILE CLEANUP ###########################################
# Script exits. Have a nice day.
exit 0  										
############################################ END SCRIPT ############################################

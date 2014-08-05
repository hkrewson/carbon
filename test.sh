#!/bin/bash
#       08/02/2014 09:54a   TO DO
#           Validate data conversion scales. Located an article with the requisite
#       information.
#       http://ibm.co/USyKVd
#       "You can convert 512 byte blocks to kilobytes by dividing them by 2.   For example, six 512-byte-blocks divided by two equals 3 KB."
#       08/01/2014 02:10a   TO DO
#           Make a small function to determine Linux v BSD, and error
#       check date math with expected values.
#           Make a function to calculate elapsed time.
#       http://www.linuxjournal.com/content/use-date-command-measure-elapsed-time
#           Make a function that accepts inputs in order to properly
#       align the cursor. Should be universal for all data output. (Object)
#           Make a test function with data that can similate copy sizes and
#       times.
#           Validate ETC time estimates with real world test values. MacWorld 
#       artical comparing USB/USB3/FW800 values in seconds. Compare quotient
#       with current numbers.
#       http://www.macworld.com/article/2039427/how-fast-is-usb-3-0-really-.html
#7200	Write   Read 	Write   Read    Ave	    Ave	    Seconds per MB Write
#RPM    File    File    Folder  Folder  Write   Read    Average Ideal Conditions
#===============================================================================
#USB 2	35.4	40.6	35.1	39.5	35.25	40.05	0.0283687943262411
#USB 3	114.2	115	    112.4	112.3	113.3	113.65	0.0088261253309797
#FW 800	58.3	74.5	55.12	72.3	56.71	73.4	0.0176335743255158
#TB	    112.9	115	    110.8	111.9	111.85	113.45	0.00894054537326777
#

#.05 Date math and conversion of seconds from epoch to elapsed time
#.04 Date math with date -d (date -v in BSD/OSX)
#.03 Use of tput cup and tput ech to replace text
#.02 Testing to verify use of tput cup to insert cursor
#.01 Initial testing to draw a basic interface.

fAVETRANSRATE ()
    {
    #function call to get runtime
    fRUNTIME
    
    #function call to get amount of data copied
    }

fRUNTIME ()
    {
    scriptRUNTIME=$(ps -ceo uid,pid,etime | grep $! | awk '{print $3}')
    #Alternate method below. Test each to determine accuracy.
    #currentEPOCHTIME=$(date +"%s")
    #scriptRUNTIME=$(($currentEPOCHTIME - $startEPOCH))
    }
repairnum="R11235061"
custname="Krewson"
dtime=$(date +"%a %b %d %T")
stime=$(date +"%T")
startEpoch=$(date +"%s")

#date math. 
etc=$(date -d "+3 hours" "+%H:%M:%S" )  #Linux variant
                                        #OSX/BSD date -v "+#X" where # is 0-9
                                        #   and X is (H)ours, (M)inutes, (S)econds

lined=$(tput lines)
clear
echo "carbon                    $repairnum                  $dtime"
echo "==============================================================================="
echo "STARTED     TOTAL     COPIED      REMAINING      ELAPSED     E.T.C.      ERRORS"
echo ""
echo ""
echo ""
echo " CURRENT DIRECTORY:"
echo "  LAST FILE COPIED:"
echo "LAST ERROR MESSAGE:"
tput cup 3 0; echo "$stime"
tput cup 3 12; echo "212 GB"
tput cup 3 22; echo "  2 GB"
tput cup 3 37; echo "210 GB"
tput cup 3 49; echo "00:00:00"
tput cup 3 61; echo "$etc"
tput cup 3 73; echo "None"
sleep 5
ctime=$(date +"%s")
etime=$(($ctime - $startEpoch))
elapsed=$(date -u -d @${etime} "+%T")
tput cup 3 24; tput ech 1; echo "3"
tput cup 3 49; tput ech 8; echo "$elapsed"
tput cup $lined 0

#Convert seconds to H:M:S format
#http://stackoverflow.com/questions/13422743/convert-seconds-to-formatted-time-in-shell
#date -u -d @${i} +"%T"  #For "Coreutils" Linux date variant
#date -u -r $i +%T       #For BSD/OSX date variant
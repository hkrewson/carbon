#!/bin/bash
#mySCALE adjusted to appropriately scale to terabytes of data

myLOGGER ()
        {
        logfile=Logscale4.txt
        stamp=$(date +"[%m/%d/%y %H:%M:%S]")
        echo $stamp "$1" >>$logfile
        }

mySCALE ()
    {
        if [ $1 -lt 1952929 ]; then                                                       #Is size below MB threshhold
        sdiv=1000000 sunit=MB                                                                #Size is in MB
        myLOGGER "Size calculation in MB."
    elif [ $1 -lt 1952929687 ]; then
        sdiv=1000000000 sunit=GB                                                             #Size is in GB
        myLOGGER "Size calculation in GB."
    else
        sdiv=1000000000000 sunit=TB
    fi
    }

i=195312
while [ $i -lt 1954155000 ]
    do
        mySCALE $i
        size=$(echo "scale=2; ($i*512)/$sdiv" | bc)
        myLOGGER "Human Readable is $size$sunit"
        ((i += 195312))

    done
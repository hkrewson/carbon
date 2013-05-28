#!/bin/bash
# installer v 3

myInstall ()
    {
    if [ ! -e "/usr/local/bin/carbon" ]; then
        sudo ditto ./carbon.sh /usr/local/bin/carbon
        sudo cp ./carbon.7 /usr/share/man/man7/carbon.7
    else
    	vers=`carbon -v | awk '{print $3}'`
        sudo mv /usr/local/bin/carbon /usr/local/bin/carbonarchive/carbon_$vers
        sudo ditto ./carbon.sh /usr/local/bin/carbon
    fi
    sudo chmod +x /usr/local/bin/carbon
    exit    
    }

width=`tput cols`
 
echo "Installer will place the carbon.sh into /usr/local/bin/carbon, and will install carbon.7 into the man library. If an older version of carbon exists, it will be moved to /usr/local/bin/carbonarchive and labled with its version. If you are unsure of how to use carbon, type man carbon or carbon -h. Useage is very similar to ditto." | fold -sw $width


myInstall
    
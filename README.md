carbon
======

Carbon was created for two reasons. First, I wanted to learn a bit about shell scripts. Second, I wanted a way to 
get feedback about the progress of ditto. 


Installing carbon
-----------------

From the command prompt, cd into the carbon folder and type:

     sudo ./install.sh

This will place carbon.sh (and rename it as carbon) in /usr/local/bin, it will also place a copy of carbon.7 in 
/usr/share/man/man7/.


Using carbon
------------

Carbon was set up to be used nearly identically to how you would run ditto. Carbon expects you to provide it with 
3 arguments: the connection type (of the slowest connected device you intend to use for the transfer), the source 
folder or drive, and the destination.

Connection types known to carbon include: u (USB), 4 (FW400), 8 (FW800), e (Ethernet), t (Thunderbolt). Carbon 
uses this and some data derived from real world data transfer tests to determine a rough estimated time of 
completion. Since my original use scenario was to copy data from corrupted drives/folders, these time estimates 
longer than would be expected from a drive in good health.

Copying data from the internal drive to an external USB drive named "Backup":

     carbon -u /Volumes/Macintosh\ HD/ /Volumes/Backup/

Help statement can be accessed by typing:

     carbon -h

Carbon also has a man page (though admittedly I have not kept up with it as much).
   
     man carbon


Files
--------

carbon.sh
carbon.7
install.sh


Copyright
---------

   Copyright 2011 H. R. Krewson

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

Known Bugs
----------

Causing the script to exit with a ^c, can cause a 0 byte file to be created in the script's folder. As part of 
its startup, carbon looks for this file and attempts to remove it. 


Troubleshooting
---------------

If you don't include a connection type flag in your call to carbon, it will error with a usage statement. 

currently outputs a verbose log that can be read to determine the cause of any troubles.



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/hkrewson/carbon/trend.png)](https://bitdeli.com/free "Bitdeli Badge")


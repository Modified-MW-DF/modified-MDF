LegendsExportsProcessor
=======================

A simple script to compress and sort the files exported from Dwarf Fortress' Legends Mode.  Compressing the .bmp maps to .png usually reduces file size by 95 to 99+ percent (yes, really).  Compressing the legends.xml, which is tens to hundreds of MB, often reduces the file size by a similar margin.  The script then moves the compressed files to region-specific folder and puts site maps and world maps in separate subfolders.  

To get a copy, can use the 'download as a zip' option on the right and place the whole unzipped folder in the LNP/utilities folder of the DF Starter pack or the contents in the same folder as the Dwarf Fortress executable.  

This script is released under the GPL3.  License files for 7zip and OptiPNG are included.

----------------------------

General overview of functions:  

1. Find the folder to work in (must contain "Dwarf Fortress.exe"), either in current folder or the relative path from a Starter Pack utilities folder

2. Establish which region's exports we're working with, by iterating back from 99 and looking from a match.  Display message explaining function of the script if nothing is found.  

3. Call OptiPNG to compress the bitmaps to PNG format.  

4. Call 7zip to compress the legends XML in .zip format.  If all required files are available, an archive compatible with "Legends Viewer" will be created (includes other text history files and a map).

5. Move all output files to a "User Generated Content" folder next to the Dwarf Fortress folder, and delete color key text files.  
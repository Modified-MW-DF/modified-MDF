PictureFort
===========

Utility for the Dwarf Fortress utility: Quickfort. Converts images into fortress templates

Download: [http://dffd.wimbli.com/file.php?id=8564]

Changelog
---------

Version 2.1 - even more critical-er bugfixes
 - fixed single image saving in root directory if not specified
 - added designation dropdown boxes. Any manually entered text (text other than the dropdown items) will be treated as a custom designation.
 - added preview pane for multiple images. They can be clicked to change active image.
 - added custom output filename format
 	- [name] -> The name in the Output File textbox, or if not specified, the name of the active image.
 	- [mode] -> Either "dig", "build", "place", or "query" based on the mode of the template
 	- [size] -> Dimensions of the image. "(X-Size x Y-Size)"
 	- [levels] -> How many z-levels the template has
 	- "/" -> will create a subfolder. eg. [mode]/[name] will create the image in that subfolder (root_path/mode/filename.csv)
 - added an option: clear to persistent settings. If set to true, it will remove empty settings. 
 - added an option: file_format to persistent settings. It will remember your custom file name format.
 - added per-image settings to persistent settings. These will remember the start position, modes, and comments of each image you have edited. 

Version 2.0.1 - many critical bugfixes
- Fixed batch images output filepath
- Fixed multiple template types in one conversion. Uses pipe separated values (dig|build|place|query)
- Fixed saving the path settings & updating form with those settings
- Fixed missing start position from CSV
- Fixed various typos
- Updated start position: Center to use the ceiling, rather than truncate, to get the actual center

Version 2 - Major overhaul of UI and feature additions
- Changed WPF to WinForms enabling support on Linux/Mac with Mono
- Added multi-Level templates
- Added batch templates
- Added persistent settings (colors and last used output path)
- Added initial set of UI helpers (dig/query/place/build modes, start position, file/path chooser)


Version 1 - Initial Release


Notes
-----

I was intrigued by the idea of Chromafort, but it never really worked for me. So I made this little utility on a Sunday afternoon for myself.
I figured it worked wonderfully for me, so I might as well release it. It works on any type of image more or less, so you don't have to worry about
powers of two, image size, aspect ratio, the phase of the moon, or format of the image -- within reason. 

 - Lossy formats such as .gif/.jpg can create more colors than you painted. Stick to lossless filetypes (eg. .bmp/.png) for best results.
 

How to use
----------

1. Create an image of your desired fort. Each pixel represents one tile ingame. Each distinct color can have its own designation of your choosing. 

2. Run picturefort.exe, click "Load Image(s)". Select the image (or images) that you want to convert.

3. The "Color Designations" tab will generate a list of entries from the currently loaded images where you can enter your designations per color.

4. Select the drawing start position.

5. Select which type of template(s) to create (dig, build, place, query) and add any respective comments each one should have. 

6. Save your template(s):
    - The "Output File" textbox will specify the name of the file. If left blank, the template will have the same name as the originating image.
    - The "Output Path" textbox will specify the directory generated templates will be created in. If left blank, they will be created in the same directory as the images.
    - "Single Template" will create a single template from the loaded images. Each image is its own z-level.
    - "Batch Templates" will create multiple templates from the loaded images. Each file is its own template.

7. Run Quickfort while playing Dwarf Fortress, and load up your shiny new template. 


Contact
----------------------------------------------------------------------------------------------------------------

maackey@gmail.com for any bugs, questions, comments, suggestions, or offers to buy me a flagon of mead.




*Strike the earth!*

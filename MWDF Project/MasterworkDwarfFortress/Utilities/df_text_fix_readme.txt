http://www.bay12forums.com/smf/index.php?topic=149632.0

Purpose

This utility mitigates a bug in TrueType font rendering in Dwarf Fortress 0.40.xx (and some earlier versions). If you've used TrueType fonts in fortress mode (by pressing F12 or using a mod with TrueType on by default), you've likely noticed long lines of text in one column can overlap and "black out" the text in subsequent columns.

For more information on the bug, see http://www.bay12games.com/dwarves/mantisbt/view.php?id=5097.

What This Does

It runs in the background and tells Dwarf Fortress to redraw its window over and over. This does use up a few extra CPU cycles, but my testing shows no noticeable change in FPS.

Screenshots
Spoiler (click to show/hide)

How to Use It
Start df_text_fixer.exe
Start Dwarf Fortress
It also works if you do step #2 before step #1.
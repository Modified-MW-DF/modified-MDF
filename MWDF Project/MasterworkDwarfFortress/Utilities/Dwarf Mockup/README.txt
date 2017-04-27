Welcome to DwarfMockup !
========================

Purpose :
---------

This is a simple utility that allows you to quickly design rooms for Dwarf Fortress within a GUI.

The designs can then be imported into quickfort to translate them into orders for your dwarves...


Usage :
-------

Movement :
- To move the cursor, use either the numpad or the directional keys
- With <Shift> depressed, the cursor moves ten tiles at a time, DF like
- To move up and down the Z levels, use <PageUp> and <PageDown> or the numpad <+> and <->
- The <Insert> and <Delete> key dive you a peek at the levels above and below when pressed
- If you prefer, you can use the ghost (<Shift-G>) command to display a ghost image of the above and below levels
- To begin an action, press the <Enter> key

The other commands are all listed on the right.

The painted zone depends on the selection mode :
- <Shift+R> : full rectangles
- <Shift+C> : one tile width rectangle
- <Shift+E> : ellipses (the center will appear)
- <Shift+O> : one tile at a time

There are four main modes of operation : dig, items, stockpiles and adjust modes.  To switch between them, use <Shift+M>
and <Shift-N>.

In dig mode, it is possible to carve through rock (<d>), channel (<h>) or rebuild walls (<w>), carve stairs (<j>, <i>,
<u>) or ramps (<m>).  There is also the option decorate rooms and transform walls or ground into dirt (<t>), rough rock
(<g>), or smooth (<s>) and engrave (<e>) them.

The items mode is used to place diverse items on the map.

<Ctrl-C> enters copy mode, <Ctrl-X> enters cut mode, <Ctrl-V> pastes.

<Shift-H> toggles a crosshair centered on the cursor.

<Shift-X> places the center, used by quickfort to determine the starting point of the design.

<Ctrl-S> is used to save a template file (in the form of a few .csv files).  <Ctrl-L> is used to load a template,
either from a multi-layer quickfort file or a single layer .csv file.

<Ctrl-H> shows the help box.

<Ctrl-Q> quits.

<Ctrl-A> shows the about box, with licensing terms.

When first started, the software creates a "dwarfmockup.conf" file with the default config, and a "blueprints"
directory to store blueprints files.


Important note :
----------------

The Avira anti-virus program seems to believe that DwarfMockup.exe is infected with a trojan (TR/Dropper.Gen7).  This is
a false positive.

I believe it's caused by the OCRA system of embedding a ruby interpreter in one big exe file.

If you do not trust this file, you can always download the whole ruby source and execute with a ruby interpreter.


Thanks, links & copyright terms :
---------------------------------

Dwarf Mockup is written and maintained by Frédéric Senault <fred@lacave.net>.

This program is written in ruby : http://www.ruby-lang.org
It uses the gosu library for the interface : http://www.libgosu.org
It repacks a version of ImageMagick, which is (c) 1999-2014 ImageMagick Studio LLC : http://www.imagemagick.org
It is bundled for windows with the OCRA library : https://github.com/larsch/ocra

The graphics in the software are taken from the Mayday Graphics Pack found at : http://goblinart.pl/vg-eng/df.php
  It includes work of the following people : Mike Mayday, Tocky, Sphr, Herrbdog, Thrin, Bane18, NW_Kohaku, Kafine,
  Phoebus, RantingRodent, Lemunde, Ironhand, Wormslayer.

QuickFort can be found at : http://www.joelpt.net/quickfort/
Dwarf Fortress can be freely downloaded at : http://bay12games.com/dwarves

This software is licensed under the BSD license ; see the in-software about box or the LICENSE file for the gory
details.
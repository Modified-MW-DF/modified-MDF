-- Holds custom descriptions for view-item-info
-- Originally by PeridexisErrant
-- Mod-specific overrides for The Earth Strikes Back! mod by Dirst
--[[=begin

item-descriptions
=================
Exports a table with custom description text for every item in the game.
Used by `view-item-info`; see instructions there for how to override
for mods.

=end]]

-- Each line near the bottom has 53 characters of room until
-- it starts clipping over the UI in an ugly fashion.
-- For proper spacing, 50 characters is the maximum.
-- Descriptions which aren't pushed down the page by
-- barrel contents or such line up with the UI on the
-- 11th line down. There is room for a 10th long line
-- without clipping, but stopping at 9 leaves enough space
-- for ideal legibility.

-- The following people contributed descriptions:
-- Raideau, PeridexisErrant, /u/Puffin4Tom, /u/KroyMortlach
-- /u/genieus, /u/TeamsOnlyMedic, /u/johny5w, /u/DerTanni
-- /u/schmee101, /u/coaldiamond, /u/stolencatkarma, /u/sylth01
-- /u/MperorM, /u/SockHoarder, /u/_enclave_, WesQ3
-- /u/Xen0nex, /u/Jurph

if not moduleMode then
    print("scripts/more-item-descriptions.lua is a content library; calling it does nothing.")
end

local help --[[
This script has a single function: to return a custom description for certain 
items in The Earth Strikes Back! mod.

If "raw/scripts/item-descriptions.lua" exists, it will entirely replace this one.
Instead, mods should use "raw/scripts/more-item-descriptions.lua" to add content or replace
descriptions on a case-by-case basis.  If an item description cannot be found in
the latter script, view-item-info will fall back to the former.
]]

-- see http://dwarffortresswiki.org/index.php/cv:Item_token
descriptions = {
    BLOCKS = {  "Blocks can be used for constructions in place of raw materials such",
                "as logs or bars.  Cutting boulders into blocks gives four times as",
                "many items, all of which are lighter for faster hauling and yield",
                "smooth constructions.",
				"Three blocks of the same layer stone can be used to build a Tribute."},
    BOULDER = { "Mining may yield loose stones for industry.  There are four categories:",
                "non-economic stones for building materials,  ores for metal industry,",
                "gems, and special-purpose economic stones like flux/coal/lignite.", 
				"An Awakened Stone that is slain will revert to a normal boulder."},
    GEM = {		"A large gem. It can be sacrificed at a Tribute or used as a trade good."},
	ROCK = {    "A small rock, sharpened as a weapon in Adventure mode.",
				"A Pet Rock that is slain will revert to a normal rock."},
    ROUGH = {   "Rough gemstones and raw glass are cut by a Gem Cutter at a Jeweler's",
                "Workshop into small decorative gems.",
				"A miner can attempt to extract a Gem Seed from a rough Hidden Gem in an",
				"appropriate Tribute.",
				"A cut Hidden Gem can be sacrificed at an appropriate Tribute."},
    SMALLGEM = {"Cut gemstones and the odd gizzard stone (a product of butchering",
                "certain species of animals) are used by a Gem Setter to decorate items",
                "at a Jeweler's Workshop.",
				"A cut Hidden Gem can be sacrificed at a Tribute of the associated ",
				"layer stone."}
}

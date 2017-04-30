local G=_G
local _ENV={}

name="Mecha-Magical Workshops"
raws_list={"building_mechamagics.txt"}
patch_entity=[[
    [PERMITTED_BUILDING:MECHAMAGIC_PHYLACTERY]
]]
patch_dofile={"mechaMagics.lua"}
author="warmist"
description=[[
A collection of magical workshops. Many use mechanical
power to fuel dwarven magics.
 * phylactery: raise your dwarf from dead. Be careful
 	though. Sometimes it malfunctions. Must be bound 
 	first.
NOTICE: connecting machines must be built AFTER 
any mechanical workshop
]]
return _ENV
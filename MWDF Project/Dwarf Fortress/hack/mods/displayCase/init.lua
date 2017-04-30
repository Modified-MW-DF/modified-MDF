local G=_G
local _ENV={}


name="Display Case"

raws_list={"building_display_case.txt"}
patch_entity=[[
    [PERMITTED_BUILDING:DISPLAY_CASE]
]]
patch_dofile={"display_case.lua"}
author="warmist"
description=[[
A mod that adds a display case which can hold any item 
and has a custom query screen.
]]
return _ENV
local G=_G
local _ENV={}


name="Personal buildings"

raws_list={"building_personal_buildings.txt","reaction_personal_buildings.txt"}
patch_entity=[[
    [PERMITTED_BUILDING:HOBBY_WORKSHOP]
    [PERMITTED_BUILDING:COMUNAL_PULPIT]
    [PERMITTED_BUILDING:COMUNAL_SEAT]
]]
patch_dofile={"personal_buildings.lua"}
author="warmist"
description=[[
A mod that adds personal buildings that
can only be used by dwarves that own
that building.
]]
return _ENV
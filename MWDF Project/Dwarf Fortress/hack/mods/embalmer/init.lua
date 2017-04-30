local G=_G
local _ENV={}

--[=[
    TODO:
        * more complicated version (where each part needs to be carried over)
]=]
name="Embalmer workshop"

raws_list={"building_embalmer.txt","reaction_embalm_simple.txt"}
patch_entity=[[
    [PERMITTED_BUILDING:EMBALMER_SHOP]
]]
patch_dofile={"embalmer.lua"}
author="warmist"
description=[[
A workshop addon that fixes corpses for resurrection
or a nice burial.
]]
return _ENV
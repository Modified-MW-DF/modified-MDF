local G=_G
local _ENV={}


name="Slab sign"

raws_list={"building_slab_sign.txt","reaction_slab_sign.txt"}
patch_entity=[[
    [PERMITTED_BUILDING:SLAB_SIGN]
    [PERMITTED_BUILDING:SLAB_SIGN_MULTI]
]]
patch_dofile={"slab_sign.lua"}
author="warmist"
description=[[
A mod that adds a slab sign with nice sidebar
view
]]
return _ENV
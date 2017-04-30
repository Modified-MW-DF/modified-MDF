local G=_G
local _ENV={}

name="Steam Engine"
raws_list={"building_steam_engine.txt","item_trapcomp_steam_engine.txt","reaction_steam_engine.txt"}
patch_entity=[[
    [TRAPCOMP:ITEM_TRAPCOMP_STEAM_PISTON]
    [PERMITTED_BUILDING:STEAM_ENGINE]
    [PERMITTED_BUILDING:MAGMA_STEAM_ENGINE]
    [PERMITTED_REACTION:STOKE_BOILER]
]]
author="angavrilov"
description=[[
Adds working steam engines. One powered by magma, one
by fuel. Both need water to function.
NOTICE: connecting machines must be built AFTER 
steam engine
]]
return _ENV
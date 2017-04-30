local G=_G
local _ENV={}

name="Mechanical Workshops"
raws_list={"building_dragon_engine.txt","building_web_thrower.txt","reaction_add_webs.txt",
    "building_wall_mover.txt","building_auto_flinger.txt"}
patch_entity=[[
    [PERMITTED_BUILDING:DRAGON_ENGINE_S]
    [PERMITTED_BUILDING:DRAGON_ENGINE_E]
    [PERMITTED_BUILDING:DRAGON_ENGINE_W]
    [PERMITTED_BUILDING:DRAGON_ENGINE_N]
    [PERMITTED_BUILDING:WEBBER_S]
    [PERMITTED_BUILDING:WEBBER_E]
    [PERMITTED_BUILDING:WEBBER_W]
    [PERMITTED_BUILDING:WEBBER_N]
    [PERMITTED_BUILDING:WALL_MOVER]
    [PERMITTED_BUILDING:AUTO_FLINGER]
    [PERMITTED_BUILDING:ITEM_SMASHER]
    [PERMITTED_REACTION:LUA_HOOK_ADD_WEBS_TO_SHOOTER]
]]
patch_dofile={"mechanicalWorkshops.lua","wall_mover.lua","auto_flinger.lua"}
author="warmist"
description=[[
A mechanical workshop showcase:
 * Dragon engines - lava using, dragon breath 
        shooting machines
 * Webber - a mechanical web thrower
 * Wall mover - moves walls
 * Auto flinger - shoots items from nearby workshops
 * Smasher - makes blocks out of items
NOTICE: connecting machines must be built AFTER 
any mechanical workshop
]]
return _ENV
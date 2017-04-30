local G=_G
local _ENV={}

name="Spatter"
raws_list={"building_spatter.txt","reaction_spatter.txt"}
patch_entity=[[
    [PERMITTED_REACTION:SPATTER_ADD_WEAPON_EXTRACT]
    [PERMITTED_REACTION:SPATTER_ADD_AMMO_EXTRACT]
    [PERMITTED_BUILDING:GREASING_STATION]
]]
patch_files={
{
    filename="material_template_default.txt",
    patch=[[
    [REACTION_CLASS:CREATURE_EXTRACT]
]],
    after="[MATERIAL_TEMPLATE:CREATURE_EXTRACT_TEMPLATE]"
}
}
author="angavrilov"
description=[[
This mod adds a way to coat weapons with 
poisons at 'Greasing station'
]]
return _ENV
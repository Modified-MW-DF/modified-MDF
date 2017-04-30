local G=_G
local _ENV={}


name="Dwarven games"

raws_list={"building_dwarven_games.txt","reaction_dwarven_games.txt"}
patch_entity=[[
    [PERMITTED_BUILDING:DWARVEN_GAMES_TABLE]
    [PERMITTED_BUILDING:DWARVEN_GAMES_CHAIR]
]]
patch_dofile={"dwarven_games.lua"}
author="warmist"
description=[[
A mod that adds a game table with various games for your dwarves.
]]
return _ENV
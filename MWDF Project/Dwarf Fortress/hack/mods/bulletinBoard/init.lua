local G=_G
local _ENV={}


name="Bulletin Board"

raws_list={"building_bulletin_board.txt","reaction_bulletin_board.txt"}
patch_entity=[[
    [PERMITTED_BUILDING:BULLETIN_BOARD]
]]
patch_dofile={"bulletin_board.lua"}
author="warmist"
description=[[
A mod that adds a bulletin board, that your idle
dwarves will post thoughts, preferences, etc...
]]
return _ENV
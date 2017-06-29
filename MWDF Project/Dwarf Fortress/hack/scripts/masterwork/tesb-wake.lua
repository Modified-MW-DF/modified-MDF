--[=[
  Only the caste ID is required, all others have defaults (though default x,y,z exists only when cursor is visible)
  Includes portions of Rubble's announce.lua and expwent's unit-info-viewer.lua
  Calls create-unit.lua to spawn the actual creature
    Runs modtools if DFHack is 0.43.03-r1 or later, otherwise mod's included version
    References to modtools/create-unit are commented out until that script is updated.
--]=]

local utils=require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'caste',
 'wyrm',
 'miner',
 'location',
 'friendly',
 'unfriendly',
 'custom'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
 print([[scripts/tesb-wake.lua
arguments:
    -help
        Print this help message
    -caste
        Specify the type of awakened stone
        This parameter is required
  -wyrm
    Spawn a wyrm instead of an awakened stone
    A "friendly" Wyrm is one that is less likely to be berserk
    -location [ x y z ]
        The location to spawn the awakened stone
    Will default to the cursor location, if the cursor is displayed
    -miner
        Unit ID of creature causing the spawn
    If miner has the caste's favor syndrome, the creature spawns Tame
    If miner is omitted, "Something" without favor awakens the creature
    -friendly
        If flag is present, the awakened stone will be Tame
  -unfriendly
    If flag is present, the awakened stone will be a wild animal
  -custom
    Override DFHack version check and use tesb-create-unit
    
Note: -friendly and -unfriendly override the miner's favor status 
]])
 return
end
 
function Announce(caste_id,unit_id,is_friendly,is_wyrm,xyz) -- Create an in-game announcement that a stone has awakened
-- Rubble's Announcement command, customized by Dirst for The Earth Strikes Back mod

--[[
Rubble Announcement DFHack Command

Copyright 2013-2014 Milo Christiansen

This software is provided 'as-is', without any express or implied warranty. In
no event will the authors be held liable for any damages arising from the use of
this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to
the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim
that you wrote the original software. If you use this software in a product, an
acknowledgment in the product documentation would be appreciated but is not
required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
]]

if not dfhack.isMapLoaded() then
  dfhack.printerr('Error: Map is not loaded.')
  return
end

local caste_name = string.upper(string.sub(caste_id,1,1))..string.lower(string.sub(caste_id,2,-1))
if caste_name == "Rock_salt" then -- Special handling for two-word stone
  caste_name = "Rock Salt" 
end

local unit_name
if not unit_id then
  unit_name = "Something"  -- The player activated the script in an interactive window. 
else
  unit_name = dfhack.TranslateName(dfhack.units.getVisibleName(df.unit.find(tonumber(unit_id))))
end

if is_wyrm then
  text = unit_name.." has released a newly-hatched "..caste_name.." Wyrm!"
  color_id = "COLOR_RED"
else
  if is_friendly == true then
    text = unit_name.." has awakened a creature of Living "..caste_name 
    color_id = "COLOR_WHITE"
  else
    text = unit_name.." has incurred the wrath of an Awakened "..caste_name
    color_id = "COLOR_RED"
  end
end

local color = _G[color_id]

if xyz then dfhack.gui.makeAnnouncement(179,{false,false,false,true},xyz2pos(tonumber(xyz[1] or -3000), tonumber(xyz[2] or 0), tonumber(xyz[3] or 0)),text, color,1)
else dfhack.gui.makeAnnouncement(179,{false,false,false,true},xyz2pos(-3000,-3000,-3000),text, color,1) end

print(text)
 
end

function IsItFriendly(caste,miner,is_friendly,is_unfriendly)
-- is_unfriendly overrides is_friendly which overrides miner's status
-- The default is false if nothing was specified

local verdict = false

if is_unfriendly then -- Command line flag
  verdict = false
elseif is_friendly then -- Command line flag
  verdict = true
elseif miner then
  local miner_unit = df.unit.find(tonumber(miner))
  local syndrome_list = miner_unit.syndromes.active
  if caste == "ROCK_SALT" then caste = "rock salt" end -- Special handling for two-word stone
  local favor_syndrome_name = string.lower(caste).." favor"
  for index,syndrome in ipairs(syndrome_list) do
    local syndrome_info = df.syndrome.find(syndrome.type)
    if syndrome_info.syn_name == favor_syndrome_name then -- Unit has the appropriate "favor" syndrome
      verdict = true
      break
    end
  end
end

return verdict

end

function CreateUnitWrapper(RaceName, CasteName, Location, TameUnit)
--[[
    CreateUnit wrapper
    Amostubal - combine the finding of race_ID and caste_ID then call the CreateUnit.
    returns the unit Id.
    RaceName is the race name ex. TESB_PET_ROCK
    CasteName is past from the args and should be the caste name.
    TameUnit is a true false expression, where true triggers running createUnit.domesticate.
--]]

  local createUnit = dfhack.script_environment('modtools/create-unit')
  local race
  local raceIndex
  local casteIndex
  local unitId

  for i,v in ipairs(df.global.world.raws.creatures.all) do
    if v.creature_id == RaceName then
      raceIndex = i
      race=v
      break
    end
  end

  for i,v in ipairs(race.caste) do
    if v.caste_id == CasteName then
      casteIndex = i
      break
    end
  end

  unitId=createUnit.createUnit(raceIndex, casteIndex, Location)

  if domesticate then domesticate(unitId) end

  -- cleanup its name, to get rid of units having arena numbers.
  local unit = df.unit.find(unitId)
  unit.name.has_name = false
  unit.name.first_name = ""
  if unit.status.current_soul then
    unit.status.current_soul.name.has_name = false
  end

  return unitId

end

local argFriendly

argFriendly = IsItFriendly(args.caste,args.miner,args.friendly,args.unfriendly)

Announce(args.caste,args.miner,argFriendly,args.wyrm,args.location)

--[[
    Amostubal - start of my rewrite.  The old script was too verbose and used 
    archaic calls to create units.  Switched to better calls to make the script
    less verbose while increasing readability.
    CreateUnitWrapper is a local function to gather the proper tags and call the
    appropriate scripts inside of the modtools/create-unit.
--]]

-- the local holders of ID and Unit, changes with each creature created.
local thisUnitID
local thisUnit

--[[
    This section spawns 0 to 2 Pet Rocks alongside the Awakened Stone or Wyrm.
    The castes of Pet Rocks are in the same order as those of large creature.
--]]
if math.random(0,2) == 2 then 
  thisUnitID = CreateUnitWrapper("TESB_PET_ROCK", args.caste, args.location, true)
end
if math.random(0,3) == 3 then 
  thisUnitID = CreateUnitWrapper("TESB_PET_ROCK", args.caste, args.location, true)
end

if args.wyrm then
  thisUnitID = CreateUnitWrapper("TESB_WYRM", args.caste, args.location, false)  
  thisUnit = df.unit.find(tonumber(thisUnitID))
  thisUnit.flags1.marauder = true
  if argFriendly then  -- A "friendly" Wyrm is just less likely to be berserk
    if math.random(0,9)==9 then thisUnit.mood = 7 end
  else -- not a "friendly" wyrm.
    if math.random(0,3)==3 then thisUnit.mood = 7 end
  end

else -- its an awakened stone!
  thisUnitID = CreateUnitWrapper("TESB_AWAKENED_STONE", args.caste, args.location, argFriendly)  
  if not argFriendly then -- its not friendly so we need to make it mad.
    thisUnit = df.unit.find(tonumber(thisUnitID))
    thisUnit.flags1.marauder = true
    if math.random(0,9) == 9 then thisUnit.mood = 7 end -- One in ten chance of being berserk
  end
end


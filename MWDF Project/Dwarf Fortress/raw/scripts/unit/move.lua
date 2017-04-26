--unit/move.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'location',
 'random',
 'building',
 'area',
 'construction',
 'dur'
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[
   -unit
   -location [ x y z ]
     A specific location to move to in x, y, and z coordinates
   -random [ x y z ] or #
     Either a distance in x, y, and z about the unit to move to randomly
     Or a radius # about the unit to move to randomly
   -building ID or BUILDING_NAME or TYPE
     Either an ID of a building as found in DFHack
     Or the name of a custom building (e.g. SCREW_PRESS)
     Special Types:
      Random
      Owned
      TradeDepot
      Trap
   -area AREA_TYPE
     Valid Types:
      Idle
      Destination
      Opponent
      Farm
      MeetingArea
      WaterSource
      Hospital
      Barracks      
      Stockpile      
   -construction ID or CONSTRUCTION_TYPE
     Valid Types:
      WallTop
   -dur #
      
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit declared')
 return
end
dur = tonumber(args.dur) or 0

if args.location then
 location = args.location
elseif args.random then
 if type(args.random) == 'string' then 
  radius = {tonumber(args.random), tonumber(args.random), tonumber(args.random)}
 else
  radius = args.random
 end
 location = dfhack.script_environment('functions/map').getPositionUnitRandom(unit,radius)
elseif args.building then
 if tonumber(args.building) then
  building = df.building.find(tonumber(args.building))
 elseif args.building == 'Random' then
  list = df.global.world.buildings.all
  if #list >= 1 then
   building = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Building Found')
   return
  end
 elseif args.building == 'Owned' then
  list = unit.owned_buildings
  if #list >= 1 then
   building = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Owned Building Found')
   return
  end
 elseif args.building == 'TradeDepot' then
  list = df.global.world.buildings.other.TRADE_DEPOT
  if #list >= 1 then
   building = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Trade Depot Found')
   return
  end
 elseif args.building == 'Trap' then
  list = df.global.world.buildings.other.TRAP
  if #list >= 1 then
   building = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Building Found')
   return
  end
 else
  building = dfhack.script_environment('functions/building').findBuilding({'RANDOM','CUSTOM',args.building})
 end
 if building then
  location = {building.centerx,building.centery,building.z}
 else
  print('No Building Found')
  return
 end
elseif args.area then
 if args.area == 'Idle' then
  location = unit.idle_area
 elseif args.area == 'Destination' then
  location = unit.path.dest
 elseif args.area == 'Opponent' then
  location = unit.opponent.unit_pos
 elseif args.area == 'Farm' then
  list = df.global.world.buildings.other.FARM_PLOT
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Farm Plot Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'MeetingArea' then
  list = {}
  n = 1
  for _,zone in pairs(df.global.world.buildings.other.ANY_ZONE) do
   if zone.zone_flags.meeting_area then
    list[n] = zone
    n = n + 1
   end
  end
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[1]
  else
   print('No Meeting Area Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'WaterSource' then
  list = {}
  n = 1
  for _,zone in pairs(df.global.world.buildings.other.ANY_ZONE) do
   if zone.zone_flags.water_source then
    list[n] = zone
    n = n + 1
   end
  end
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[1]
  else
   print('No Water Source Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'Hospital' then
  list = df.global.world.buildings.other.ANY_HOSPITAL
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Hospital Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'Barracks' then
  list = df.global.world.buildings.other.ANY_BARRACKS
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Barracks Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 elseif args.area == 'Stockpile' then
  list = df.global.world.buildings.other.STOCKPILE
  if #list >= 1 then
   spot = dfhack.script_environment('functions/misc').permute(list)[0]
  else
   print('No Stockpile Found')
   return
  end
  location = {spot.centerx,spot.centery,spot.z}
 else
  print('Invalid Area Type')
  return
 end
elseif args.construction then
 if tonumber(args.construction) then
  construction = df.construction.find(tonumber(args.construction))
 elseif args.construction == 'WallTop' then
 else
 end 
end

if location then
 if location.x > 0 or location.y > 0 or location.z > 0 then
  dfhack.script_environment('functions/unit').move(unit,location)
 else
  print('No valid location')
  return
 end
else
 print('No valid location')
 return
end
--unit/create.lua version 42.06a

local utils = require 'utils'
local split = utils.split_string

validArgs = validArgs or utils.invert({
 'help',
 'loc',
 'creature',
 'reference',
 'dur',
 'syndrome',
 'side',
 'name',
 'track',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/create.lua
  Create a unit
  arguments:
   -help
     print this help message
   -loc [ x y z ]
     the location at which to create the creature
   -creature RACE:CASTE
     REQUIRED
     example:
      DWARF:MALE
   -reference id
     REQUIRED
     id number of the unit to reference
   -side type
     Valid Types:
      Civilian
      Ally
      Friendly
      Neutral
      Enemy
      Pet
      Domestic
   -name
     Valid Types:
      Random
      ENTITY_ID (MOUNTAIN, EVIL, etc...)
      Richard (or anything else)
   -syndrome "syndrome name"
   -dur #
     length of time, in in-game ticks, for the creature to last
     0 means the creature is permanent
     DEFAULT: 0
  examples:
 ]])
 return
end

if args.creature then
 race_token = split(args.creature,':')[1]
 caste_token = split(args.creature,':')[2]
else
 print('No unit declared')
 return
end

for i,x in ipairs(df.global.world.raws.creatures.all) do
  if x.creature_id == race_token then
    raceID = i
    race = x
    break
  end
end

if not race then
  print('Invalid race')
  return
end

if race.caste == 'RANDOM' then
 caste = dfhack.script_environment('functions/misc').permute(race.caste)[1]
 casteID = caste.id
else
 for i,x in ipairs(race.caste) do
  if x.caste_id == caste_token then
   casteID= i
   caste = x
   break
  end
 end
end

if not caste then
  print('Invalid caste')
  return
end

if args.reference and tonumber(args.reference) then
 reference = df.unit.find(tonumber(args.reference))
else
 print('No valid reference unit declared')
 return
end

dur = tonumber(args.dur) or 0

dfhack.script_environment('functions/unit').create(args.loc,raceID,casteID,reference,args.side,args.name,dur,args.track,args.syndrome)

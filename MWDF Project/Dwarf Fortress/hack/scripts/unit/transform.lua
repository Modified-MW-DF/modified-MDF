--unit/transform.lua version 42.06a

local utils = require 'utils'
local split = utils.split_string

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'creature',
 'dur',
 'syndrome',
 'track',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/transform
   -unit UNIT_ID
   -creature RACE:CASTE
   -dur
   -syndrome
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit declared')
 return
end
if not args.creature then
 print('No creature declared')
 return
else
 race = split(args.creature,':')[1]
 caste = split(args.creature,':')[2]
end
if dfhack.script_environment('functions/unit').checkCreatureRace(unit,args.creature) then
 print('Unit already the desired creature')
 return
end

for i,v in ipairs(df.global.world.raws.creatures.all) do
 if v.creature_id == race then
  raceIndex = i
  race = v
  break
 end
end
if not race then
  error 'Invalid race.'
end
for i,v in ipairs(race.caste) do
 if v.caste_id == caste then
  casteIndex = i
  break
 end
end
if not casteIndex then
  error 'Invalid caste.'
end

dur = tonumber(args.dur) or 0
track = nil
if args.track then track = 'track' end

dfhack.script_environment('functions/unit').transform(unit,raceIndex,casteIndex,dur,track,args.syndrome)
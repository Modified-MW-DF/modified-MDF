--unit/trait-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'trait',
 'mode',
 'amount',
 'dur',
 'unit',
 'announcement',
 'track',
 'syndrome',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/trait-change.lua
  Change the trait(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -trait TRAIT_TOKEN
     REQUIRED
     trait to be changed
   -mode Type
     Valid Types:
      Fixed
      Percent
      Set
   -amount #
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   unit/trait-change -unit \\UNIT_ID -fixed \-10 -trait ANGER
   unit/trait-change -unit \\UNIT_ID -set 100 -trait DEPRESSION
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

value = args.amount
dur = tonumber(args.dur) or 0
if dur < 0 then return end
if type(value) == 'string' then value = {value} end
if type(args.trait) == 'string' then args.trait = {args.trait} end
if #value ~= #args.trait then
 print('Mismatch between number of skills declared and number of changes declared')
 return
end

track = nil
if args.track then track = 'track' end

for i,trait in ipairs(args.trait) do
 current = unit.status.current_soul.personality.traits[trait]
 change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
 dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,track,args.syndrome)
end
if args.announcement then
--add announcement information
end
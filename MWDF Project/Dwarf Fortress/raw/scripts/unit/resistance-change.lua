--unit/resistance-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'resistance',
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
 print([[unit/resistance-change.lua
  Change the resistance(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -resistance RESISTANCE_ID
     resistance(s) to be changed
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
   -announcement string
     optional argument to create an announcement and combat log report
  examples:
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
if type(args.resistance) == 'string' then args.resistance = {args.resistance} end
if #value ~= #args.resistance then
 print('Mismatch between number of resistances declared and number of changes declared')
 return
end

track = nil
if args.track then track = 'track' end

for i,resistance in ipairs(args.resistance) do
 resistances = dfhack.script_environment('functions/misc').checkResistance(resistance)
 for j,x in ipairs(resistances) do
  _,current = dfhack.script_environment('functions/unit').trackResistance(unit,x,nil,nil,nil,nil,'get',nil,nil)
  change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
  dfhack.script_environment('functions/unit').changeResistance(unit,x,change,dur,track,args.syndrome)
 end
end
if args.announcement then
--add announcement information
end
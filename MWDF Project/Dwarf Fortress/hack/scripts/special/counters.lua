--special/counters.lua v1.0
   
local utils = require 'utils'
local persistTable = require 'persist-table'

function counters(types,unit,counter,increase,style,cap)
 if types == 'GLOBAL' then
  tables = persistTable.GlobalTable.roses.GlobalTable.Counters
 elseif types == 'UNIT' then
  unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
  if unitTable then
   if unitTable.Counters then
    tables = unitTable.Counters
   else
    unitTable.Counters = {}
	tables = unitTable.Counters
   end
  else
   persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)] = {}
   unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
   unitTable.Counters = {}
   tables = unitTable.Counters
  end
 end
 if tables[counter] then
  tables[counter] = tostring(tables[counter] + tonumber(increase))
 else
  tables[counter] = tostring(increase)
 end
 if style == 'minimum' then
  if tables[counter] >= cap and cap >= 0 then
   return true
  else
   return false
  end
 elseif style == 'percent' then
  rando = dfhack.random.new()
  roll = rando:drandom()
  if roll <= tables[counter]/cap and cap >=1 then
   return true
  else
   return false
  end
 else
  return false
 end
 return false
end

validArgs = validArgs or utils.invert({
 'help',
 'type',
 'unit',
 'style',
 'counter',
 'increment',
 'cap',
 'script',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[special/counters.lua
  Allows for creation, examination, and ultimately triggering based on counters
  arguments:
   -help
     print this help message
   -type GLOBAL or UNIT
    REQUIRED
   -unit id
     id of the target unit to associate the counter with, REQUIRED if using -type UNIT
   -style minimum or percent
     minimum - once the value of the counter has surpassed a certain amount, the counter will trigger the script. the counter is then reset to zero
     percent - the script has a chance of triggering each time the counter is increased, with a 100% chance once it reaches a certain amount. the counter is reset to zero on triggering
     if no style given will not check for cap and will just add to counter
   -counter ANY_STRING
     REQUIRED
     any string value, the counter will be saved as this type
     examples:
      FIRE
      BURN
      POISON
   -increment #
     amount for the counter to change
     DEFAULT 0
   -cap #
     level of triggering for the counter
     once it hits the cap (or is triggered earlier by percentage) the counter will reset to 0
     if no cap is given then script will never be run
   -script [ command line input ]
     the script to trigger when the counter is reached 
  example:
   special/counters -unit \\UNIT_ID -style minimum -counter BERSERK -increment 1 -cap 10 -script [unit-attributes-change -unit \\UNIT_ID -physical [STRENGTH,AGILITY] -fixed [1000,\-200] ]
 ]])
 return
end

if args.counter == nil or args.type == nil then -- Check for counter declaration !REQUIRED
 print('No counter selected')
 return
end
if args.unit then unit = df.unit.find(tonumber(args.unit)) end
increment = args.increment or 0
cap = args.cap or -1
style = args.style or nil

trigger = counters(args.type,unit,args.counter,increment,style,cap)
if trigger and args.script then
 dfhack.run_command(args.script[1],select(2,table.unpack(args.script)))
end

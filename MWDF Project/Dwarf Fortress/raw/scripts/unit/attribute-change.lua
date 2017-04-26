--unit/attribute-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'attribute',
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
 print([[unit/attribute-change.lua
  Change the attribute(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -attribute ATTRIBUTE_ID
     attribute(s) to be changed
   -mode
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
   unit/attribute-change -unit \\UNIT_ID -fixed 100 -attribute STRENGTH
   unit/attribute-change -unit \\UNIT_ID -percent [ 10 10 10 ] -attribute [ ENDURANCE TOUGHNESS WILLPOWER ] -dur 3600
   unit/attribute-change -unit \\UNIT_ID -set 5000 -attribute WILLPOWER -dur 1000
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
if type(args.attribute) == 'string' then args.attribute = {args.attribute} end
if #value ~= #args.attribute then
 print('Mismatch between number of attributes declared and number of changes declared')
 return
end

track = nil
if args.track then track = 'track' end

for i,attribute in ipairs(args.attribute) do
 if df.physical_attribute_type[attribute] then
  current = unit.body.physical_attrs[attribute].value
 elseif df.mental_attribute_type[attribute] then
  current = unit.status.current_soul.mental_attrs[attribute].value
 else
  persistTable = require 'persist-table'
  if not persistTable.GlobalTable.roses then
   print('Invalid attribute id')
   return
  end
  if persistTable.GlobalTable.roses.BaseTable.CustomAttributes[attribute] then
   _,current = dfhack.script_environment('functions/unit').trackAttribute(unit,attribute,nil,nil,nil,nil,'get')
  else
   print('Invalid attribute id')
   return
  end
 end
 change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
 dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,track,args.syndrome)
end
if args.announcement then
--add announcement information
end
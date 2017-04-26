--unit/body-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'temperature',
 'category',
 'token',
 'flag',
 'all',
 'dur',
 'unit',
 'age',
 'size',
 'fixed',
 'set',
 'percent',
 'mode',
 'amount',
 'announcement',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[body-change.lua
  Change the body parts of a unit (currently only supports changing temperature, size, or setting on fire)
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -category TYPE                           \
     change body parts of specific category |
     examples:                              |
      TENTACLE                              |
      HOOF_REAR                             |
      HEAD                                  |
   -token TYPE                              |
     change body parts by specific token    | Must at least one of these arguments if changing temperature
     examples:                              |
      UB                                    |
      LB                                    |
      REYE                                  |
   -flag FLAG                               |
     change body parts by specific flag     |
     examples:                              |
      SIGHT                                 |
      LIMB                                  |
      SMALL                                 /
   -temperature
     temperature to set body parts to
     special token:
      Fire - sets the body part on fire
   -size
     Valid Types:
      All
      Size
      Length
      Area
   -age (Not currently supported)
   -mode (Mode Type)
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
   unit/body-change -unit \\UNIT_ID -flag GRASP -temperature fire -dur 1000
   unit/body-change -unit \\UNIT_ID -category LEG_LOWER -temperature 8000
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

dur = tonumber(args.dur) or 0
if dur < 0 then return end
value = args.amount
 
if args.temperature then
 changeType = 'Temperature'
 parts = {}
 if args.category == 'ALL' or args.token == 'ALL' or args.flag == 'ALL' then
  body = unit.body.body_plan.body_parts
  for k,v in ipairs(body) do
   parts[k] = k
  end
 elseif args.category then
  parts = dfhack.script_environment('functions/unit').checkBodyCategory(unit,args.category)
 elseif args.token then
  parts = dfhack.script_environment('functions/unit').checkBodyToken(unit,args.token)
 elseif args.flag then
  parts = dfhack.script_environment('functions/unit').checkBodyFlag(unit,args.flag)
 else
  print('No body parts declared for temperature change')
  return
 end

 for _,part in ipairs(parts) do
  if args.temperature == 'Fire' or args.temperature == 'fire' then
   dfhack.script_environment('functions/unit').changeBody(unit,part,changeType,'Fire',dur)
  else
   current = unit.status2.body_part_temperature[part].whole
   if args.mode == 'Fixed' or args.mode == 'fixed' then
    change = tonumber(value)
   elseif args.mode == 'Percent' or args.mode == 'percent' then
    local percent = (100+tonumber(value))/100
    change = current*percent - current
   elseif args.mode == 'Set' or args.mode == 'set' then
    change = tonumber(value) - current
   else
    print('No method for change defined')
    return
   end 
   dfhack.script_environment('functions/unit').changeBody(unit,part,changeType,change,dur)
  end
 end
elseif args.age then
 changeType = 'age'
elseif args.size then
 if args.size == 'Size' or args.size == 'All' then
  current = unit.body.size_info.size_cur
  change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
  dfhack.script_environment('functions/unit').changeBody(unit,nil,'Size',change,dur)
 end
 if args.size == 'Area' or args.size == 'All' then
  current = unit.body.size_info.area_cur
  if args.mode == 'Fixed' or args.mode == 'fixed' then
   change = tonumber(value)
  elseif args.mode == 'Percent' or args.mode == 'percent' then
   local percent = (100+tonumber(value))/100
   change = current*percent - current
  elseif args.mode == 'Set' or args.mode == 'set' then
   change = tonumber(value) - current
  else
   print('No method for change defined')
   return
  end 
  dfhack.script_environment('functions/unit').changeBody(unit,nil,'Area',change,dur)
 end
 if args.size == 'Length' or args.size == 'All' then
  current = unit.body.size_info.length_cur
  if args.mode == 'Fixed' or args.mode == 'fixed' then
   change = tonumber(value)
  elseif args.mode == 'Percent' or args.mode == 'percent' then
   local percent = (100+tonumber(value))/100
   change = current*percent - current
  elseif args.mode == 'Set' or args.mode == 'set' then
   change = tonumber(value) - current
  else
   print('No method for change defined')
   return
  end 
  dfhack.script_environment('functions/unit').changeBody(unit,nil,'Length',change,dur)
 end
else
 print('Nothing to change declared, choose -age, -size, or -temperature')
 return
end
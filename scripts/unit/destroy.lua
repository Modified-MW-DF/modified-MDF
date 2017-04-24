--unit/destroy.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'type',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/destroy
  Remove a unit in certain ways
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -type Type
     type of removal
     Valid Types:
      Created
      Resurrected
      Animated
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

dfhack.script_environment('functions/unit').removal(unit,args.type)
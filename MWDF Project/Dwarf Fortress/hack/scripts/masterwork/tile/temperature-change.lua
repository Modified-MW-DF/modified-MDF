--tile/temperature-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'plan',
 'location',
 'temperature',
 'dur',
 'unit',
 'offset',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[tile/temperature-change.lua
  Changes a tiles temperature
  arguments:
   -help
     print this help message
   -unit id
     id of the unit to center on
     required if using -plan
   -plan filename                           \
     filename of plan to use (without .txt) |
   -location [# # #]                        | Must have at least one of these
     x,y,z coordinates to use for position  /
   -temperature #
     temperature to set tile to
   -offset [ # # # ]
     sets the x y z offset from the desired location to spawn around
     DEFAULT [ 0 0 0 ]
   -dur #
     length of time for tile change to last
     0 means the change is natural and will revert back to normal temperature
     DEFAULT 0
  examples:
   tile/temperature-change -unit \\UNIT_ID -plan 5x5_X -temperature 15000 -dur 1000
   tile/temperature-change -location [ \\LOCATION ] -temperature 8000
 ]])
 return
end

dur = tonumber(args.dur) or 0 -- Check if there is a duration (default 0)

if args.unit and tonumber(args.unit) then
 pos = df.unit.find(tonumber(args.unit)).pos
elseif args.location then
 pos = args.location
else
 print('No unit or location selected')
 return
end
offset = args.offset or {0,0,0}
location = {}
location.x = pos.x + offset[1] or pos[1] + offset[1]
location.y = pos.y + offset[2] or pos[2] + offset[2]
location.z = pos.z + offset[3] or pos[3] + offset[3]
 
if args.plan then
 file = dfhack.getDFPath()..'/raw/files/'..args.plan
 locations,n = dfhack.script_environment('functions/map').getPositionPlan(file,location)
 for i,loc in ipairs(locations) do
  dfhack.script_environment('functions/map').changeTemperature(loc,nil,nil,args.temperature,dur)
 end
else
 dfhack.script_environment('functions/map').changeTemperature(location,nil,nil,args.temperature,dur)
end
--tile/material-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'plan',
 'location',
 'material',
 'dur',
 'unit',
 'floor',
 'offset',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[tile/material-change.lua
  Change a tiles material
  arguments:
   -help
     print this help message
   -unit id
     id of the unit to center on
     required if using -plan
   -plan filename                           \
     filename of plan to use (without .txt) |
   -location [ # # # ]                        | Must have at least one of these
     x,y,z coordinates to use for position  /
   -material INORGANIC_TOKEN
     material to set tile to
     examples:
      STEEL
      GRANITE
      RUBY
   -floor
    targets the z-level below the specified location(s)
   -offset [ # # # ]
     sets the x y z offset from the desired location to spawn around
     DEFAULT [ 0 0 0 ]
   -dur #
     length of time for tile change to last
     0 means the change is natural and will revert back to normal temperature
     DEFAULT 0
  examples:
   tile/material-change -location [ \\LOCATION ] -material RUBY
   tile/material-change -plan 5x5_X -unit \\UNIT_ID -material SLADE -floor -dur 3000
 ]])
 return
end

if not args.material then
 print('No material declaration')
 return
end

dur = tonumber(args.dur) or 0

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
  if args.floor then
   loc.z = loc.z - 1
  end
  dfhack.script_environment('functions/map').changeInorganic(loc,nil,nil,args.material,dur)
 end
else
 if args.floor then
  location.z = location.z - 1
 end
 dfhack.script_environment('functions/map').changeInorganic(location,nil,nil,args.material,dur)
end


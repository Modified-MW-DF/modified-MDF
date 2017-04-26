--unit/convert.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'side',
 'type',
 'dur',
 'syndrome',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/convert
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -side id
     REQUIRED
     id of the unit whose side you want to convert from
   -type Type
     Valid Types:
      Civilian
      Ally
      Friend
      Neutral
      Enemy
      Invader
      Pet
    -dur #
      length of time, in in-game ticks, for the change to last
      0 means the change is permanent
      DEFAULT: 0
    -syndrome
      syndrome associated with conversion
   examples:
    unit/convert -unit \\UNIT_ID -side \\UNIT_ID -type Pet -dur 1000
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

if args.side and tonumber(args.side) then
 side = df.unit.find(tonumber(args.side))
else
 print('No side selected')
 return
end

side_type = args.type or 'Neutral'
dur = tonumber(args.dur) or 0
if dur < 0 then return end

dfhack.script_environment('functions/unit').changeSide(unit,side,side_type,dur,'track',args.syndrome)
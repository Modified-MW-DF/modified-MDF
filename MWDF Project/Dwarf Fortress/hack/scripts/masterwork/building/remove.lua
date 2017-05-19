local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'building',
 'unit'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
 print(
[[building/remove.lua
arguments:
    -help
        print this help message
    -building id
        specify the building to be removed
    -unit id
        specify the unit to use as location to find the building to be removed
 ]])
 return
end

if args.building then
 dfhack.buildings.deconstruct(df.building.find(tonumber(args.building)))
elseif args.unit then
 dfhack.buildings.deconstruct(dfhack.buildings.findAtTile(df.unit.find(tonumber(args.unit)).pos))
else
 print('No valid building')
end
local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'item'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
 print(
[[item/remove.lua
arguments:
    -help
        print this help message
    -item item_id
        specify the item to be removed
 ]])
 return
end

if not args.item then
 error 'Invalid item.'
end

dfhack.items.remove(df.global.world.items.all[tonumber(args.item)])
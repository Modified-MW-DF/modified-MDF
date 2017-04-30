local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'item',
 'upgrade',
 'downgrade',
 'quality'
})
local args = utils.processArgs({...}, validArgs)

local item=df.item.find(args.item)

print(args.item)

print(item)

printall(args)

if args.upgrade then
    item:setQuality(item.quality+1)
elseif args.downgrade then
    item:setQuality(item.quality-1)
elseif args.quality then
    item:setQuality(args.quality)
end
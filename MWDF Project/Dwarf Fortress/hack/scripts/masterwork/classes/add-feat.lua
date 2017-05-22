local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'feat',
 'override',
 'verbose'
})
local args = utils.processArgs({...}, validArgs)

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit declared')
 return
end

if args.feat then
 feat = args.feat
else
 print('No feat declared')
 return
end

verbose = false
if args.verbose then verbose = true end

if args.override then
 yes = true
else
 yes = dfhack.script_environment('functions/class').checkRequirementsFeat(unit,feat,verbose)
end
if yes then
 success = dfhack.script_environment('functions/class').addFeat(unit,feat,verbose)
 if success then
 -- Erase items used for reaction
 end
end
--unit/flag-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'flag',
 'dur',
 'reverse',
 'True',
 'False',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/flag-change
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

f1 = unit.flags1
f2 = unit.flags2
f3 = unit.flags3

for k,_ in pairs(f1) do
 if args.flag == k then
  flag = 'flags1'
 end
end
for k,_ in pairs(f2) do
 if args.flag == k then
  flag = 'flags2'
 end
end
for k,_ in pairs(f3) do
 if args.flag == k then
  flag = 'flags3'
 end
end

if not flag then
 print('No valid flag declared')
 return
end

if args.reverse then
 if unit[flag][args.flag] then
  unit[flag][args.flag] = false
 else
  unit[flag][args.flag] = true
 end
elseif args.True then
 unit[flag][args.flag] = true
elseif args.False then
 unit[flag][args.flag] = false
end
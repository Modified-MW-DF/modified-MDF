
local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'location',
 'offset',
 'source',
 'sink',
 'remove',
 'removeAll',
 'removeAllSource',
 'removeAllSink',
 'magma'
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 return
end

if args.unit and tonumber(args.unit) then
 pos = df.unit.find(tonumber(args.unit)).pos
elseif args.location then
 pos = args.location
else
 print('No unit or location selected')
 return
end
offset = args.offset or {0,0,0}
x = pos.x + offset[1] or pos[1] + offset[1]
y = pos.y + offset[2] or pos[2] + offset[2]
z = pos.z + offset[3] or pos[3] + offset[3]

local persistTable = require 'persist-table'
liquidTable = persistTable.GlobalTable.roses.LiquidTable
number = tostring(#liquidTable._children)

if args.removeAll then
 persistTable.GlobalTable.roses.LiquidTable = {}
elseif args.removeAllSource then
 for _,i in pairs(liquidTable._children) do
  liquid = liquidTable[i]
  if liquid.Type == 'Source' then
   liquidTable[i] = nil
  end
 end
elseif args.removeAllSink then
 for _,i in pairs(liquidTable._children) do
  liquid = liquidTable[i]
  if liquid.Type == 'Sink' then
   liquidTable[i] = nil
  end
 end
elseif args.remove then
 for _,i in pairs(liquidTable._children) do
  liquid = liquidTable[i]
  if tonumber(liquid.x) == x and tonumber(liquid.y) == y and tonumber(liquid.z) == z then
   liquidTable[i] = nil
  end
 end
elseif args.source then
 depth = args.source
 for _,i in pairs(liquidTable._children) do
  liquid = liquidTable[i]
  if tonumber(liquid.x) == x and tonumber(liquid.y) == y and tonumber(liquid.z) == z then
   liquidTable[i] = nil
  end
 end
 liquidTable[number] = {}
 liquidTable[number].x = tostring(x)
 liquidTable[number].y = tostring(y)
 liquidTable[number].z = tostring(z)
 liquidTable[number].Depth = tostring(depth)
 if args.magma then liquidTable[number].Magma = 'true' end
 liquidTable[number].Type = 'Source'
 dfhack.script_environment('functions/map').liquidSource(number)
elseif args.sink then
 depth = args.sink
 for _,i in pairs(liquidTable._children) do
  liquid = liquidTable[i]
  if tonumber(liquid.x) == x and tonumber(liquid.y) == y and tonumber(liquid.z) == z then
   liquidTable[i] = nil
  end
 end
 liquidTable[number] = {}
 liquidTable[number].x = tostring(x)
 liquidTable[number].y = tostring(y)
 liquidTable[number].z = tostring(z)
 liquidTable[number].Depth = tostring(depth)
 if args.magma then liquidTable[number].Magma = 'true' end
 liquidTable[number].Type = 'Sink'
 dfhack.script_environment('functions/map').liquidSink(number)
end
local utils = require 'utils'

local function changeBuilding(bldg,items,subtype,dur,direction)

 if subtype == 'upgrade' then
-- Increase buildings number by one
  local name = df.global.world.raws.buildings.all[bldg.custom_type].code
  local namea = split(name,'_')
  local num = tonumber(namea[#namea])
  num = num + 1
  namea[#namea] = tostring(num)
  name = table.concat(namea,'_')
  ctype = nil
  for _,x in ipairs(df.global.world.raws.buildings.all) do
   if x.code == name then ctype = x.id end
  end
  if ctype == nil then 
   print('Cant find upgrade building, possibly upgraded to max') 
   return
  end
  if dur > 0 then
   script = 'building/subtype-change -building '..tostring(bldg.id)..' -type downgrade'
   if items then
    script = script..' -item [ '..table.unpack(items)..' ]'
	if direction == 1 then script = script..' -remove' end
	if direction == -1 then script = script..' -add' end
   end   
   dfhack.script_environment('persist-delay').persistentDelay(dur,script)
  end
 elseif subtype == 'downgrade' then
-- Decrease buildings number by one
  local name = df.global.world.raws.buildings.all[bldg.custom_type].code
  local namea = split(name,'_')
  local num = tonumber(namea[#namea])
  num = num - 1
  if num > 0 then namea[#namea] = tostring(num) end 
  name = table.concat(namea,'_')
  ctype = nil
  for _,x in ipairs(df.global.world.raws.buildings.all) do
   if x.code == name then ctype = x.id end
  end
  if ctype == nil then 
   print('Cant find upgrade building, possibly upgraded to max') 
   return
  end
  if dur > 0 then
   script = 'building/subtype-change -building '..tostring(bldg.id)..' -type upgrade'
   if items then
    script = script..' -item [ '..table.unpack(items)..' ]'
	if direction == 1 then script = script..' -remove' end
	if direction == -1 then script = script..' -add' end
   end   
   dfhack.script_environment('persist-delay').persistentDelay(dur,script)
  end
 else
-- Change building to new building
  if dur > 0 then sid = df.global.world.raws.buildings.all[bldg.custom_type].code end
  local name = subtype
  ctype = nil
  for _,x in ipairs(df.global.world.raws.buildings.all) do
   if x.code == name then ctype = x.id end
  end
  if ctype == nil then 
   print('Cant find upgrade building, possibly upgraded to max') 
   return
  end
  if dur > 0 then
   script = 'building/subtype-change -building '..tostring(bldg.id)..' -type '..sid
   if items then
    script = script..' -item [ '..table.unpack(items)..' ]'
	if direction == 1 then script = script..' -remove' end
	if direction == -1 then script = script..' -add' end
   end   
   dfhack.script_environment('persist-delay').persistentDelay(dur,script)
  end
 end

 bldg.custom_type=ctype
 for _,y in pairs(items) do
  local item = df.item.find(y)
  if direction == 1 then
   dfhack.items.moveToBuilding(item,bldg,2)
   item.flags.in_building = true
  elseif direction == -1 then
   item.flags.in_building = false
  end
 end
end

validArgs = validArgs or utils.invert({
 'help',
 'building',
 'unit',
 'item',
 'type',
 'dur',
 'add',
 'remove',
})

local args = utils.processArgs({...}, validArgs)

if args.help then
print(
[[building/subtype-change.lua
 arguments:
  -help
   print this help message
  -building id
   specify the building to be removed
  -unit id
   specify the unit to use as location to find the building to be removed
  -item ids
   table of item ids to be added or removed from the building
  -type TOKEN
   building to change the other into
   special tokens
    upgrade
	downgrade
  -dur #
   length of time in in-game ticks for the change to last, any items added will be removed, any items removed will be added
  -add
   add items listed in -item
  -remove
   remove items listed in -item
]])
return
end

if args.building then
 building = df.building.find(tonumber(args.building))
elseif args.unit then
 building = dfhack.buildings.findAtTile(df.unit.find(tonumber(args.unit)).pos)
else
 print('No valid building')
 return
end

if building.custom_type < 0 then print('Changing vanilla buildings not currently supported') return end
if not args.type then print('No specified subtype chosen') return end
local direction = 0
if args.remove then direction = -1 end
if args.add then direction = 1 end
if args.item and direction == 0 then
 print('Items specified but no addition or removal declared. Assuming addition wanted')
 direction = 1
end
dur = args.dur or 0
changeBuilding(building,args.item,args.type,dur,direction)
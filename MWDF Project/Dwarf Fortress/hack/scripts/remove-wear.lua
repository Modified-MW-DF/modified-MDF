-- Reset items in your fort to 0 wear
-- original author: Laggy, edited by expwnent
local help = [====[

remove-wear
===========
Sets the wear on items in your fort to zero.  Usage:

:remove-wear all:
    Removes wear from all items in your fort.
:remove-wear ID1 ID2 ...:
    Removes wear from items with the given ID numbers.

]====]

local args = {...}

if args[1] == 'help' then
    print(help)
    return
elseif args[1] == 'all' then
 local count = 0;
 for _,item in ipairs(df.global.world.items.all) do
  if (item.wear > 0) then
   item:setWear(0)
   count = count+1
  end
 end
 print('remove-wear removed wear from '..count..' objects')
else
 local argIndex = 1
 local isCompleted = {}
 for i,x in ipairs(args) do
  args[i] = tonumber(x)
 end
 table.sort(args)
 for _,item in ipairs(df.global.world.items.all) do
  local function loop()
   if argIndex > #args then
    return
   elseif item.id > args[argIndex] then
    argIndex = argIndex+1
    loop()
    return
   elseif item.id == args[argIndex] then
    --print('removing wear from item with id ' .. args[argIndex])
    item:setWear(0)
    isCompleted[args[argIndex]] = true
    argIndex = argIndex+1
   end
  end
  loop()
 end
 for _,arg in ipairs(args) do
  if isCompleted[arg] ~= true then
   print('failed to remove wear from item ' .. arg .. ': could not find item with that id')
  end
 end
end

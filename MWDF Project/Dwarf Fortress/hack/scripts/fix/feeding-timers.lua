-- feeding-timers.lua
-- original author: tejón
-- rewritten by expwnent
-- see repeat.lua for how to run this every so often automatically
local help = [====[

fix/feeding-timers
==================
Reset the GiveWater and GiveFood timers of all living citizens.

]====]
local args = {...}
if args[1] ~= nil then
 print(help)
 return
end

local fixcount = 0
for _,unit in ipairs(df.global.world.units.all) do
 if dfhack.units.isCitizen(unit) and not (unit.flags1.dead) then
  for _,v in pairs(unit.status.misc_traits) do
   local didfix = 0
   if v.id == 0 then -- I think this should have additional conditions...
    v.value = 0 -- GiveWater cooldown set to zero
    didfix = 1
   end
   if v.id == 1 then -- I think this should have additional conditions...
    v.value = 0 -- GiveFood cooldown set to zero
    didfix = 1
   end
   fixcount = fixcount + didfix
  end
 end
end
print("Fixed feeding timers for " .. fixcount .. " citizens.")

--item/material-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'item',
 'equipment',
 'mat',
 'dur',
 'track',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[item/material-change.lua
  Change the material a equipped item is made out of
  arguments:
   -help
     print this help message
   -unit id                   \
     id of the target unit    |
   -item id                   | Must have one and only one of them
     id of the target item    /
   -equipment Type
     Valid Types:
      WEAPON
      ARMOR
      HELM
      SHOES
      SHIELD
      GLOVES
      PANTS
      AMMO
   -mat matstring
     specify the material of the item to be changed to
     examples:
      INORGANIC:IRON
      CREATURE_MAT:DWARF:BRAIN
      PLANT_MAT:MUSHROOM_HELMET_PLUMP:DRINK
   -dur #
     length of time, in in-game ticks, for the material change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   item/material-change -unit \\UNIT_ID -weapon -ammo -mat INORGANIC:IMBUE_FIRE -dur 3600
   item/material-change -unit \\UNIT_ID -armor -helm -shoes -pants -gloves -mat INORGANIC:IMBUE_STONE -dur 1000
   item/material-change -unit \\UNIT_ID -shield -mat INORGANIC:IMBUE_AIR
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
 local types = args.equipment
 items = dfhack.script_environment('functions/unit').checkInventoryType(unit,types)
else
 if args.item and tonumber(args.item) then
  items = {df.item.find(tonumber(args.item))}
 else
  print('No unit or item selected')
  return
 end
end

dur = tonumber(args.dur) or 0
track = nil
if args.track then track = 'track' end

for _,item in pairs(items) do
 dfhack.script_environment('functions/item').changeMaterial(item,args.mat,dur,track)
end

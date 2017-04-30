--unit/wound-change.lua v2.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'corpse',
 'animate',
 'remove',
 'recent',
 'regrow',
 'resurrect',
 'fitForResurrect',
 'fitForAnimate',
 'syndrome',
 'dur',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[
   -unit UNIT_ID
     The unit id of the item to remove wounds from, animate, or resurrect. If using animate or resurrect will take corpse parts from unit.corpse_parts
   -corpse ITEM_ID
     Can either be the item id for an item_corpsest or an item_corpsepartst, only applicable when using animate and resurrect
   -remove # or All
     Will remove a number of wounds from the unit, note that this removes wounds found in unit.body.wounds, each wound may effect multiple parts (i.e. a stab wound will effect all the layers of a body part and possible other body parts). Removing this wound will reset all damage to the layers defined in unit.body.wounds[#].parts
   -recent
     Starts with the most recent wounds first, if absent will select wounds at random to remove
   -animate UNIT_ID or nothing
     If left blank:
      Will bring a unit back from the dead that is hostile to everyone and is a zombie
     If a UNIT_ID is included:
      Will bring a unit back from the dead that is a zombie loyal to the UNIT_ID faction
     If fitForResurrect will only bring back the UPPERBODY of the unit
     if fitForAnimate will only bring back the parts of the unit, note this will create several new creatures, they will all be hostile Hand/Head/etc... zombies
   -resurrect UNIT_ID or nothing
     If left blank:
      Will bring a unit back from the dead with the same loyalties
     If a UNIT_ID is included:
      Will bring a unit back from the dead loyal to the UNIT_ID faction
     If fitForResurrect will only bring back the UPPERBODY of the unit (standard DF resurrection)
     if fitForAnimate will only bring back the parts of the unit, note this will create several new creatures, they will retain the same loyalties and you will end up with friendly Hands/Head/etc... zombies
   -regrow
     If used with animate or resurrect, regrow makes the UPPERBODY of the corpse/unit regrow all lost parts, including this without fitForResurrect or fitForAnimate will treat it as -fitForResurrect -regrow
     If used with remove, regrow will regrow any lost limbs as if they were tracked in the unit.body.wounds (normally linked severed body parts are not tracked)
   -fitForResurrect
     Will only resurrect/animate the item_corpsest of a unit (i.e. the UPPERBODY and everything still attached to it)
   -fitForAnimate
     Will only resurrect/animate the item_corpsepartst of a unit (i.e. everything that has been chopped off the UPPERBODY)
   -syndrome SYN_NAME
   -dur #
  examples:
   unit/wound-change -unit \\UNIT_ID -remove All regrow (completely heals a unit)
   unit/wound-change -unit \\UNIT_ID -remove 2 -recent (heal the last two wounds the unit suffered, doesn't regrow lost limbs)
   unit/wound-change -unit \\UNIT_ID -resurrect -fitForResurrect -regrow (fully restores a unit to life, including all of their lost body parts)
   unit/wound-change -unit \\UNIT_ID -animate -dur 1000 (animates all body parts and main body of unit for 1000 ticks)
   unit/wound-change -unit \\UNIT_ID -resurrect -fitForAnimate -regrow (if unit was chopped into 4 pieces, would create one original and 3 copies, all complete units)
 ]])
 return
end
regrow = false
if args.regrow then regrow = true end
changeLife = false
reference = false
if args.animate then
 changeLife = 'Animate'
 if tonumber(args.animate) then
  reference = df.unit.find(tonumber(args.animate))
 end
elseif args.resurrect then
 changeLife = 'Resurrect'
 if tonumber(args.resurrect) then
  reference = df.unit.find(tonumber(args.resurrect))
 end
end
dur = tonumber(dur) or 0

if args.remove then
 if tonumber(args.remove) then
  number = tonumber(args.remove)
 elseif args.remove == 'All' then
  number = 9999
 end
 if args.unit and tonumber(args.unit) then
  unit = df.unit.find(tonumber(args.unit))
 else
  print('No unit declared for wound removal')
  return
 end
 if #unit.body.wounds == 0 then return end
 if #unit.body.wounds <= number or number == 9999 then
  while #unit.body.wounds > 0 do
   unit.body.wounds:erase(#unit.body.wounds-1)
  end
  unit.body.wound_next_id=1
  dfhack.script_environment('functions/unit').changeWound(unit,'All','All',regrow)
  return
 end
 if args.recent then
  wounds = unit.body.wounds
 else
  wounds = dfhack.script_environment('functions/misc').permute(unit.body.wounds)
 end
 j = 0
 while j < number do
  j = j + 1
  for _,part in pairs(wounds[#wounds-1].parts) do
   bp_id = part.body_part_id
   if unit.body.components.body_part_status[bp_id].missing and regrow then
    con_parts = dfhack.script_environment('functions/unit').checkBodyConnectedParts(unit,bp_id)
   else
    con_parts = {bp_id}
   end
   for _,con_part in pairs(con_parts) do
    dfhack.script_environment('functions/unit').changeWound(unit,con_part,'All',regrow)
   end
  end
  wounds:erase(#wounds-1)
 end
elseif changeLife then
 if args.unit then 
  corpseparts = dfhack.script_environment('functions/unit').checkBodyCorpseParts(args.unit)
 elseif args.corpse then
  corpseparts = dfhack.script_environment('functions/unit').checkBodyCorpseParts(args.corpse)
 else
  print('Neither a unit nor a corpse item declared for resurrection/animation')
  return
 end
 if not corpseparts.Corpse and #corpseparts.Parts == 0 then
  print('No corpse parts found for resurrection/animation')
  return
 end
 if args.fitForResurrect then
  if not corpseparts.Corpse then
   print('Targeted corpse unfit for resurrection/animation')
   return
  end
  dfhack.script_environment('functions/unit').changeLife(corpseparts.Unit,corpseparts.Corpse,changeLife,reference,regrow,args.syndrome,dur)
 elseif args.fitForAnimate then
  for _,id in pairs(corpseparts.Parts) do
   dfhack.script_environment('functions/unit').changeLife(corpseparts.Unit,id,changeLife,reference,regrow,args.syndrome,dur)
  end
 else
  if corpseparts.Corpse then
   dfhack.script_environment('functions/unit').changeLife(corpseparts.Unit,corpseparts.Corpse,changeLife,reference,regrow,args.syndrome,dur)
  end
  if not regrow then
   for _,id in pairs(corpseparts.Parts) do
    dfhack.script_environment('functions/unit').changeLife(corpseparts.Unit,id,changeLife,reference,regrow,args.syndrome,dur)
   end
  end
 end
end

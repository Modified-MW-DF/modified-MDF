------------------------------------------------------------------------------------------------------------------------
--------------------------------------- Enhanced Creature System Functions ---------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function enhanceCreature(unit)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 if unitTable.Enhanced then return end
 local EnhancedCreatureTable = persistTable.GlobalTable.roses.EnhancedCreatureTable
 if EnhancedCreatureTable then
  local creatureID = df.global.world.raws.creatures.all[unit.race].creature_id
  local casteID = df.global.world.raws.creatures.all[unit.race].caste[unit.caste].caste_id
  if safe_index(EnhancedCreatureTable,creatureID,casteID) then
   unitTable.Enhanced = 'true'
   local creatureTable = EnhancedCreatureTable[creatureID][casteID]
   if creatureTable.Size then setSize(unit,creatureTable.Size) end
   if creatureTable.Attributes then setAttributes(unit,creatureTable.Attributes) end
   if creatureTable.Skills then setSkills(unit,creatureTable.Skills) end
   if creatureTable.Stats then setStats(unit,creatureTable.Stats) end
   if creatureTable.Resistances then setResistances(unit,creatureTable.Resistances) end
   if creatureTable.Classes and classNeeded then setClass(unit,creatureTable.Classes) end
   if creatureTable.Interactions then setInteractions(unit,creatureTable.Classes) end
  else
   unitTable.Enhanced = 'true'
  end
 else
  unitTable.Enhanced = 'true'
 end
end

function setAttributes(unit,table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)] 
 for _,attribute in pairs(table._children) do
  local current = 0
  if not unitTable.Attributes[attribute] then 
   dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit,'Attributes',attribute) 
  end
  _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Attributes',attribute)
  rn = math.random(0,100)
  if rn > 95 then
   value = table[attribute]['7']
  elseif rn > 85 then
   value = table[attribute]['6']
  elseif rn > 65 then
   value = table[attribute]['5']
  elseif rn < 5 then
   value = table[attribute]['1']
  elseif rn < 15 then
   value = table[attribute]['2']
  elseif rn < 35 then
   value = table[attribute]['3']
  else
   value = table[attribute]['4']
  end
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,0,'track')
 end
end

function setClass(unit,table)

end

function setInteractions(unit,table)

end

function setResistances(unit,table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]  
 for _,resistance in pairs(table._children) do
  local current = 0
  if not unitTable.Resistances[resistance] then 
   dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit,'Resistances',resistance) 
  end
  _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Resistances',resistance)
  rn = math.random(0,100)
  if rn > 95 then
   value = table[resistance]['7']
  elseif rn > 85 then
   value = table[resistance]['6']
  elseif rn > 65 then
   value = table[resistance]['5']
  elseif rn < 5 then
   value = table[resistance]['1']
  elseif rn < 15 then
   value = table[resistance]['2']
  elseif rn < 35 then
   value = table[resistance]['3']
  else
   value = table[resistance]['4']
  end
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,0,'track')
 end
end

function setSize(unit,table)

end

function setSkills(unit,table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]  
 for _,skill in pairs(table._children) do
  local current = 0
  if not unitTable.Skills[skill] then 
   dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit,'Attributes',attribute) 
  end
  _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Skills',skill)
  rn = math.random(0,100)
  if rn > 95 then
   value = table[skill]['7']
  elseif rn > 85 then
   value = table[skill]['6']
  elseif rn > 65 then
   value = table[skill]['5']
  elseif rn < 5 then
   value = table[skill]['1']
  elseif rn < 15 then
   value = table[skill]['2']
  elseif rn < 35 then
   value = table[skill]['3']
  else
   value = table[skill]['4']
  end
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,0,'track')
 end
end

function setStats(unit,table)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return false end
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unit.id)] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]  
 for _,stat in pairs(table._children) do
  local current = 0
  if not unitTable.Stats[stat] then 
   dfhack.script_environment('functions/tables').makeUnitTableSecondary(unit,'Stats',stat) 
  end
  _,current = dfhack.script_environment('functions/unit').getUnit(unit,'Stats',stat)
  rn = math.random(0,100)
  if rn > 95 then
   value = table[stat]['7']
  elseif rn > 85 then
   value = table[stat]['6']
  elseif rn > 65 then
   value = table[stat]['5']
  elseif rn < 5 then
   value = table[stat]['1']
  elseif rn < 15 then
   value = table[stat]['2']
  elseif rn < 35 then
   value = table[stat]['3']
  else
   value = table[stat]['4']
  end
  change = dfhack.script_environment('functions/misc').getChange(current,value,'set')
  dfhack.script_environment('functions/unit').changeStat(unit,stat,change,0,'track')
 end
end

------------------------------------------------------------------------------------------------------------------------
----------------------------------------- Enhanced Item System Functions -----------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function enhanceItemsInventory()
 
end

function onEquip(item,unit)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.EnhancedItemTable
 if not itemTable then return end
 itemTable = itemTable[item.subtype.id]
 if not itemTable then return end
 onTable = itemTable.onEquip
 for _,attribute in pairs(onTable.Attributes._children) do
  change = onTable.Attributes[attribute]
  dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,0,'item')
 end
 for _,resistance in pairs(onTable.Resistances._children) do
  change = onTable.Resistances[resistance]
  dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,0,'item')
 end
 for _,skill in pairs(onTable.Skills._children) do
  change = onTable.Skills[skill]
  dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,0,'item')
 end
 for _,stat in pairs(onTable.Stats._children) do
  change = onTable.Stats[stat]
  dfhack.script_environment('functions/unit').changeStat(unit,stat,change,0,'item')
 end
 for _,trait in pairs(onTable.Traits._children) do
  change = onTable.Traits[trait]
  dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,0,'item')
 end
 for _,n in pairs(onTable.Syndromes._children) do
  syndrome = onTable.Syndromes[n]
  dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',0)
 end
 for _,n in pairs(onTable.Interactions._children) do
  syndrome = onTable.Interactions[n]
  dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',0)
 end
 for _,n in pairs(onTable.Scripts._children) do
  script = onTable.Scripts[n]
  dfhack.run_command(script)
 end
end

function onUnEquip(item,unit)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.EnhancedItemTable
 if not itemTable then return end
 itemTable = itemTable[item.subtype.id]
 if not itemTable then return end
 onTable = itemTable.onEquip
 for _,attribute in pairs(onTable.Attributes._children) do
  change = onTable.Attributes[attribute]
  dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,-change,0,'item')
 end
 for _,resistance in pairs(onTable.Resistances._children) do
  change = onTable.Resistances[resistance]
  dfhack.script_environment('functions/unit').changeResistance(unit,resistance,-change,0,'item')
 end
 for _,skill in pairs(onTable.Skills._children) do
  change = onTable.Skills[skill]
  dfhack.script_environment('functions/unit').changeSkill(unit,skill,-change,0,'item')
 end
 for _,stat in pairs(onTable.Stats._children) do
  change = onTable.Stats[stat]
  dfhack.script_environment('functions/unit').changeStat(unit,stat,-change,0,'item')
 end
 for _,trait in pairs(onTable.Traits._children) do
  change = onTable.Traits[trait]
  dfhack.script_environment('functions/unit').changeTrait(unit,trait,-change,0,'item')
 end
 for _,n in pairs(onTable.Syndromes._children) do
  syndrome = onTable.Syndromes[n]
  dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'erase',0)
 end
 for _,n in pairs(onTable.Interactions._children) do
  syndrome = onTable.Interactions[n]
  dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'erase',0)
 end  
end

function onStrike(item,attacker,defender)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(attacker) then attacker = df.unit.find(tonumber(attacker)) end
 if tonumber(defender) then defender = df.unit.find(tonumber(defender)) end
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.EnhancedItemTable
 if not itemTable then return end
 itemTable = itemTable[item.subtype.id]
 if not itemTable then return end
 onTable = itemTable.onStrike
 for _,add in pairs({'Attacker','Defender'}) do
  if add == 'Attacker' then 
   unit = attacker
   dur = onTable.AttackerDur or 0
  end
  if add == 'Defender' then
   unit = defender
   dur = onTable.DefenderDur or 0
  end
  dur = tonumber(dur)
  for _,attribute in pairs(onTable[add..'Attributes']._children) do
   change = onTable[add..'Attributes'][attribute]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,'item')
  end
  for _,resistance in pairs(onTable[add..'Resistances']._children) do
   change = onTable[add..'Resistances'][resistance]
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,'item')
  end
  for _,skill in pairs(onTable[add..'Skills']._children) do
   change = onTable[add..'Skills'][skill]
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,dur,'item')
  end
  for _,stat in pairs(onTable[add..'Stats']._children) do
   change = onTable[add..'Stats'][stat]
   dfhack.script_environment('functions/unit').changeStat(unit,stat,change,dur,'item')
  end
  for _,trait in pairs(onTable[add..'Traits']._children) do
   change = onTable[add..'Traits'][trait]
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,'item')
  end
  for _,n in pairs(onTable[add..'Syndromes']._children) do
   syndrome = onTable[add..'Syndromes'][n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
  end
  for _,n in pairs(onTable[add..'Interactions']._children) do
   syndrome = onTable[add..'Interactions'][n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
  end
 end
 for _,n in pairs(onTable.Scripts._children) do
  script = onTable.Scripts[n]
  dfhack.run_command(script)
 end
end

function onParry(item,attacker,defender)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(attacker) then attacker = df.unit.find(tonumber(attacker)) end
 if tonumber(defender) then defender = df.unit.find(tonumber(defender)) end
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.EnhancedItemTable
 if not itemTable then return end
 itemTable = itemTable[item.subtype.id]
 if not itemTable then return end
 onTable = itemTable.onParry
 for _,add in pairs({'Attacker','Defender'}) do
  if add == 'Attacker' then 
   unit = attacker
   dur = onTable.AttackerDur or 0
  end
  if add == 'Defender' then
   unit = defender
   dur = onTable.DefenderDur or 0
  end
  dur = tonumber(dur)
  for _,attribute in pairs(onTable[add..'Attributes']._children) do
   change = onTable[add..'Attributes'][attribute]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,'item')
  end
  for _,resistance in pairs(onTable[add..'Resistances']._children) do
   change = onTable[add..'Resistances'][resistance]
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,'item')
  end
  for _,skill in pairs(onTable[add..'Skills']._children) do
   change = onTable[add..'Skills'][skill]
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,dur,'item')
  end
  for _,stat in pairs(onTable[add..'Stats']._children) do
   change = onTable[add..'Stats'][stat]
   dfhack.script_environment('functions/unit').changeStat(unit,stat,change,dur,'item')
  end
  for _,trait in pairs(onTable[add..'Traits']._children) do
   change = onTable[add..'Traits'][trait]
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,'item')
  end
  for _,n in pairs(onTable[add..'Syndromes']._children) do
   syndrome = onTable[add..'Syndromes'][n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
  end
  for _,n in pairs(onTable[add..'Interactions']._children) do
   syndrome = onTable[add..'Interactions'][n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
  end
 end
 for _,n in pairs(onTable.Scripts._children) do
  script = onTable.Scripts[n]
  dfhack.run_command(script)
 end 
end

function onDodge(item,attacker,defender)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if tonumber(attacker) then attacker = df.unit.find(tonumber(attacker)) end
 if tonumber(defender) then defender = df.unit.find(tonumber(defender)) end
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.EnhancedItemTable
 if not itemTable then return end
 itemTable = itemTable[item.subtype.id]
 if not itemTable then return end
 onTable = itemTable.onDodge
 for _,add in pairs({'Attacker','Defender'}) do
  if add == 'Attacker' then 
   unit = attacker
   dur = onTable.AttackerDur or 0
  end
  if add == 'Defender' then
   unit = defender
   dur = onTable.DefenderDur or 0
  end
  dur = tonumber(dur)
  for _,attribute in pairs(onTable[add..'Attributes']._children) do
   change = onTable[add..'Attributes'][attribute]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,'item')
  end
  for _,resistance in pairs(onTable[add..'Resistances']._children) do
   change = onTable[add..'Resistances'][resistance]
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,'item')
  end
  for _,skill in pairs(onTable[add..'Skills']._children) do
   change = onTable[add..'Skills'][skill]
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,dur,'item')
  end
  for _,stat in pairs(onTable[add..'Stats']._children) do
   change = onTable[add..'Stats'][stat]
   dfhack.script_environment('functions/unit').changeStat(unit,stat,change,dur,'item')
  end
  for _,trait in pairs(onTable[add..'Traits']._children) do
   change = onTable[add..'Traits'][trait]
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,'item')
  end
  for _,n in pairs(onTable[add..'Syndromes']._children) do
   syndrome = onTable[add..'Syndromes'][n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
  end
  for _,n in pairs(onTable[add..'Interactions']._children) do
   syndrome = onTable[add..'Interactions'][n]
   dfhack.script_environment('functions/unit').changeSyndrome(unit,syndrome,'add',dur)
  end
 end
 for _,n in pairs(onTable.Scripts._children) do
  script = onTable.Scripts[n]
  dfhack.run_command(script)
 end 
end

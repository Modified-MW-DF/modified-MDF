-- Functions for the Spell SubSystem in the Class System, vN/A
-- NOTE: These scripts still need substantial work, and have not been tested yet (hence the N/A)
--[[
 calculateAttribute(unit,spell,base,check,verbose)
 calculateSkill(unit,spell,base,verbose)
 calculateStat(unit,spell,base,verbose)
 calculateResistance(target,spell,verbose) -- Calculates the resistances for a given spell/target combo
 Spell(source,target,spell,verbose) -- Sets up the spell, calculates various needed parameters, then calls castSpell to run the actual script
 castSpell(source,target,spell,verbose) -- Runs the scripts associated with the spell, replacing certain key strings with the appropriate numbers
]]
------------------------------------------------------------------------
function calculateAttribute(unit,spell,base,check,verbose)
 local attribute = 0
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return attribute end
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return attribute
 end
 spellTable = spellTable[spell]
 if base == 'PRIMARY' then
  if check == 'SOURCE' then
   table = spellTable.SourcePrimaryAttribute
  elseif check == 'TARGET' then
   table = spellTable.TargetPrimaryAttribute
  end
 elseif base == 'SECONDARY' then
  if check == 'SOURCE' then
   table = spellTable.SourceSecondaryAttribute
  elseif check == 'TARGET' then
   table = spellTable.TargetSecondaryAttribute
  end
 end
 if table then
  for _,n in pairs(table._children) do
   attCheck = table[n]
   attribute = attribute + dfhack.script_environment('functions/unit').getUnit(unit,'Attributes',attCheck,verbose)
  end
  attribute = attribute/(#table._children) 
 end
 return attribute
end

function calculateSkill(unit,spell,base,verbose)
 local skill = 0
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return skill end
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return skill
 end
 spellTable = spellTable[spell]
 TSSDS = {}
 if spellTable.Type then table.insert(TSSDS,spellTable.Type) end
 if spellTable.Sphere then table.insert(TSSDS,spellTable.Sphere) end
 if spellTable.School then table.insert(TSSDS,spellTable.School) end
 if spellTable.Discipline then table.insert(TSSDS,spellTable.Discipline) end
 if spellTable.SubDiscipline then table.insert(TSSDS,spellTable.SubDiscipline) end
 for _,add in pairs(TSSDS) do
  sklCheck = add..'_'..base
  skill = skill + dfhack.script_environment('functions/unit').getUnit(unit,'Skills',sklCheck,verbose)
 end
 return skill
end

function calculateStat(unit,spell,base,verbose)
 local stat = 0
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 if not unit then return stat end
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return stat
 end
 spellTable = spellTable[spell]
 TSSDS = {}
 if spellTable.Type then table.insert(TSSDS,spellTable.Type) end
 if spellTable.Sphere then table.insert(TSSDS,spellTable.Sphere) end
 if spellTable.School then table.insert(TSSDS,spellTable.School) end
 if spellTable.Discipline then table.insert(TSSDS,spellTable.Discipline) end
 if spellTable.SubDiscipline then table.insert(TSSDS,spellTable.SubDiscipline) end
 for _,add in pairs(TSSDS) do
  sttCheck = add..'_'..base
  stat = stat + dfhack.script_environment('functions/unit').getUnit(unit,'Stats',sttCheck,verbose)
 end
 if base == 'SKILL_PENETRATION' then
  if spellTable.Penetration then stat = stat + tonumber(spellTable.Penetration) end
  if spellTable.Resistable then
   for _,n in pairs(spellTable.Resistable._children) do
    resistance = spellTable.Resistable[n]
    stat = stat + dfhack.script_environment('functions/unit').getUnit(unit,'Stats',resistance..'_SKILL_PENETRATION',verbose)
   end
  end
 elseif base == 'HIT_CHANCE' then
  if spellTable.HitModifier then stat = stat + tonumber(spellTable.HitModifier) end
  if spellTable.HitModifierPerc then stat = stat*(tonumber(spellTable.HitModifierPerc)/100) end
 end
 return stat
end

function calculateResistance(target,spell,verbose)
 local resistance = 0
 local unit = target
 if not unit then return resistance end
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 unitID = tostring(unit.id)
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return resistance
 end
 spellTable = spellTable[spell]
 if not spellTable.Resistable then return resistance end
 local TSSDS = {}
 if spellTable.Type then table.insert(TSSDS,spellTable.Type) end
 if spellTable.Sphere then table.insert(TSSDS,spellTable.Sphere) end
 if spellTable.School then table.insert(TSSDS,spellTable.School) end
 if spellTable.Discipline then table.insert(TSSDS,spellTable.Discipline) end
 if spellTable.SubDiscipline then table.insert(TSSDS,spellTable.SubDiscipline) end
 local resistanceTable = TSSDS
 for _,x in pairs(spellTable.Resistable._children) do
  table.insert(resistanceTable,spellTable.Resistable[x])
 end
 local resistances = {}
 for _,rstCheck in pairs(resistanceTable) do
  table.insert(resistances,dfhack.script_environment('functions/unit').getUnit(unit,'Resistances',rstCheck,verbose))
 end
-- Should resistance just take the largest one?
-- resistance = table.sort(resistances)[#resistances]
-- Or should it be multiplicative?
-- for _,val in pairs(resistances) do
--  resistance = resistance + val*(100-resistance)/100
-- end
-- Or should it just all add together?
 for _,val in pairs(resistances) do
  resistance = resistance + val
 end
 return resistance
end

function Spell(source,target,spell,verbose)
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return
 end
 spellTable = spellTable[spell]
 if source then 
  if tonumber(source) then source = df.unit.find(tonumber(source)) end
  sourceID = tostring(source.id)
 else
  sourceID = nil
 end
 if target then
  if tonumber(target) then target = df.unit.find(tonumber(target)) end
  targetID = tostring(target.id)
 else
  targetID = nil
 end
 if sourceID then
  local unitTable = persistTable.GlobalTable.roses.UnitTable
  if not unitTable[sourceID] then dfhack.script_environment('functions/tables').makeUnitTable(source) end
  unitTable = unitTable[sourceID]
  if spellTable.Type then
   speedPerc = dfhack.script_environment('functions/misc').fillEquation(source,spell,spellTable.Type..'_SPEED_PERC')
   exaustion = dfhack.script_environment('functions/misc').fillEquation(source,spell,spellTable.Type..'_EXHAUSTION_MODIFIER')
  else
   speedPerc = dfhack.script_environment('functions/misc').fillEquation(source,spell,'MAGICAL_SPEED_PERC')
   exaustion = dfhack.script_environment('functions/misc').fillEquation(source,spell,'MAGICAL_EXHAUSTION_MODIFIER')
  end
 else
  speedPerc = 100
  exhaustion = 0
 end
 -- process spell -> Set delay (if necessary) -> Cast Spell -> Gain Experience -> Gain Skill -> Add Exhaustion
 if spellTable.CastTime and speedPerc > 0 then
  speed = math.floor((speedPerc/100)*tonumber(spellTable.CastTime))
  if speed == 0 then speed = 1 end
  if sourceID then dfhack.run_command('unit/action-change -unit '..sourceID..' -action All -interaction All -timer '..tostring(speed)))
  dfhack.script_environment('persist-delay').environmentDelay(speed,'functions/class','castSpell',{sourceID,targetID,spell})
 else
  castSpell(source,target,spell)
 end
 if exhaustion > 0 and sourceID then dfhack.script_environment('functions/unit').changeCounter(sourceID,'exhaustion',exhaustion) end
 if spellTable.ExperienceGain and sourceID then dfhack.script_environment('functions/class').addExperience(sourceID,tonumber(spellTable.ExperienceGain)) end
 if spellTable.SkillGain and sourceID then
  for _,skill in pairs(spellTable.SkillGain._children) do
   amount = spellTable.SkillGain[skill]
   dfhack.script_environment('functions/unit').changeSkill(sourceID,skill,amount)
  end
 end
end

function castSpell(source,target,spell,verbose)
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  if verbose then print('Not a valid spell: '..spell) end
  return
 end
 spellTable = spellTable[spell]
 if source then
  if tonumber(source) then source = df.unit.find(tonumber(source)) end
  sourceID = tostring(source.id)
 else
  sourceID = "\\-1"
 end
 if target then
  if tonumber(target) then target = df.unit.find(tonumber(target)) end
  targetID = tostring(target.id)
 else
  targetID = "\\-1"
 end
 for _,i in pairs(spellTable.Script._children) do
  script = spellTable.Script[i]
  script = script:gsub('SPELL_TARGET',targetID)
  script = script:gsub('\\TARGET_ID',targetID)
  script = script:gsub('\\DEFENDER_ID',targetID)
  script = script:gsub('SPELL_SOURCE',sourceID)
  script = script:gsub('\\SOURCE_ID',sourceID)
  script = script:gsub('\\ATTACKER_ID',sourceID)
  dfhack.run_command(script)
 end
end

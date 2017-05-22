--Functions for use in the Class System, v42.06a
--[[
 addExperience(unit,amount,verbose) - Adds a given amount of experience to a units class, then checks for leveling up
 changeClass(unit,change,verbose) - Change the class of the unit, returns true if successful
 changeLevel(unit,amount,verbose) - Change the level of the class of the unit (up or down)
 changeName(unit,name,direction,verbose) - Change the name of the unit through syndromes (this is how the unit's class name is displayed)
 changeSpell(unit,spell,direction,verbose) - Change the spells (interactions) available to the unit
 checkRequirementsClass(unit,class,verbose) - Check if the unit meets the requirements for the class, returns true if yes, false if no
 checkRequirementsSpell(unit,spell,verbose) - Check if the unit meets the requirements for the spell, returns true if yes, false if no
 addFeat(unit,feat,verbose) - Adds a feat to the unit
 checkRequirementsFeat(unit,feat,verbose) - Checks if the unit meets the requirements for the feet, returns true if yes, false if no
]]
-- CLASS FUNCTIONS
function addExperience(unit,amount,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local unitID = unit.id
 local persistTable = require 'persist-table'
 local classTable = persistTable.GlobalTable.roses.ClassTable
 if not classTable then return end
 local utils = require 'utils'
 local split = utils.split_string
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unitID)] then dfhack.script_environment('functions/tables').makeUnitTable(unitID) end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unitID)]
 local unitClasses = unitTable.Classes
 local currentClass = unitClasses.Current
 if currentClass.Name ~= 'NONE' then
  currentClass.TotalExp = tostring(tonumber(currentClass.TotalExp)+amount)
  numFeats = tonumber(currentClass.FeatPoints)
  for _,feat in pairs(unitTable.Feats._children) do
   numFeats = numFeats + tonumber(persistTable.GlobalTable.roses.FeatTable[feat].Cost)
  end
  featGains = split(persistTable.GlobalTable.roses.BaseTable.FeatGains,':')
  A = tonumber(featGains[2])/2
  C = tonumber(featGains[1])
  B = A+C
  if (tonumber(currentClass.TotalExp)+amount) >  A*numFeats*numFeats + B*numFeats + C then currentClass.FeatPoints = tostring(currentClass.FeatPoints+1) end
  local currentClassName = currentClass.Name
  unitClasses[currentClassName].Experience = tostring(unitClasses[currentClassName].Experience + amount)
  unitClasses[currentClassName].SkillExp = tostring(unitClasses[currentClassName].SkillExp + amount)
  local currentClassLevel = tonumber(unitClasses[currentClassName].Level)
  if currentClassLevel < tonumber(classTable[currentClassName].Levels) then
   classExpLevel = tonumber(classTable[currentClassName].Experience[tostring(currentClassLevel+1)])
   if tonumber(unitClasses[currentClassName].Experience) >= classExpLevel then
    if verbose then print('LEVEL UP! '..currentClassName..' LEVEL '..tostring(currentClassLevel+1)) end
    changeLevel(unitID,1,verbose)
   end
  end
 end
end

function changeClass(unit,change,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local key = tostring(unit.id)
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 if not unitTable[key].Classes[change] then dfhack.script_environment('functions/tables').makeUnitTableClass(unit,change) end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
-- Change the units class
 local currentClass = unitTable.Classes.Current
 local nextClass = unitTable.Classes[change]
 if not nextClass then
  if verbose then print('No such class to change into: '..change) end
  return false
 end
 if not checkRequirementsClass(unit,change,verbose) then
  if verbose then print('Does not meet class requirements') end
  return false
 end
 if currentClass.Name == nextClass.Name then
  if verbose then print('Already this class: '..change) end
  return false
 end
 local storeName = 'NONE'
 local classes = persistTable.GlobalTable.roses.ClassTable
 if currentClass.Name ~= 'NONE' then
  local storeClass = unitTable.Classes[currentClass.Name]
  storeName = currentClass.Name
  local currentClassLevel = storeClass.Level
  -- Remove Class Name From Unit
  changeName(unit,currentClass.Name,'remove')
  -- Remove Attribute Bonuses
  if classes[currentClass.Name].BonusAttribute then
   for _,attr in pairs(classes[currentClass.Name].BonusAttribute._children) do
    local attrTable = classes[currentClass.Name].BonusAttribute[attr]
    dfhack.script_environment('functions/unit').changeAttribute(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
   end
  end
  -- Remove Skill Bonuses
  if classes[currentClass.Name].BonusSkill then
   for _,attr in pairs(classes[currentClass.Name].BonusSkill._children) do
    local attrTable = classes[currentClass.Name].BonusSkill[attr]
    dfhack.script_environment('functions/unit').changeSkill(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
   end
  end
  -- Remove Trait Bonuses
  if classes[currentClass.Name].BonusTrait then
   for _,attr in pairs(classes[currentClass.Name].BonusTrait._children) do
    local attrTable = classes[currentClass.Name].BonusTrait[attr]
    dfhack.script_environment('functions/unit').changeTrait(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
   end
  end
  -- Remove Stat Bonuses
  if classes[currentClass.Name].BonusStat then
   for _,attr in pairs(classes[currentClass.Name].BonusStat._children) do
    local attrTable = classes[currentClass.Name].BonusStat[attr]
    dfhack.script_environment('functions/unit').changeStat(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
   end
  end
  -- Remove Resistance Bonuses
  if classes[currentClass.Name].BonusResistance then
   for _,attr in pairs(classes[currentClass.Name].BonusResistance._children) do
    local attrTable = classes[currentClass.Name].BonusResistance[attr]
    dfhack.script_environment('functions/unit').changeResistance(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
   end
  end
  -- Remove Spells and Abilities
  for _,spell in pairs(classes[currentClass.Name].Spells._children) do
   changeSpell(unit,spell,'remove',verbose)
  end
 end
 -- Change Current Class Table
 currentClass.Name = change
 currentClassLevel = nextClass.Level
 -- Add Class Name to Unit
 changeName(unit,currentClass.Name,'add')
 -- Add Attribute Bonuses
 if classes[currentClass.Name].BonusAttribute then
  for _,attr in pairs(classes[currentClass.Name].BonusAttribute._children) do
   local attrTable = classes[currentClass.Name].BonusAttribute[attr]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
 end
 -- Add Skill Bonuses
 if classes[currentClass.Name].BonusSkill then
  for _,attr in pairs(classes[currentClass.Name].BonusSkill._children) do
   local attrTable = classes[currentClass.Name].BonusSkill[attr]
   dfhack.script_environment('functions/unit').changeSkill(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
 end
 -- Add Trait Bonuses
 if classes[currentClass.Name].BonusTrait then
  for _,attr in pairs(classes[currentClass.Name].BonusTrait._children) do
   local attrTable = classes[currentClass.Name].BonusTrait[attr]
   dfhack.script_environment('functions/unit').changeTrait(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
 end
 -- Add Stat Bonuses
 if classes[currentClass.Name].BonusStat then
  for _,attr in pairs(classes[currentClass.Name].BonusStat._children) do
   local attrTable = classes[currentClass.Name].BonusStat[attr]
   dfhack.script_environment('functions/unit').changeStat(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
 end
 -- Add Resistance Bonuses
 if classes[currentClass.Name].BonusResistance then
  for _,attr in pairs(classes[currentClass.Name].BonusResistance._children) do
   local attrTable = classes[currentClass.Name].BonusResistance[attr]
   dfhack.script_environment('functions/unit').changeResistance(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
 end
 -- Add Spells and Abilities
 for _,spell in ipairs(classes[currentClass.Name].Spells._children) do
  local spellTable = classes[currentClass.Name].Spells[spell]
  if (tonumber(spellTable.RequiredLevel) <= tonumber(currentClassLevel)) and spellTable.AutoLearn then
   unitTable.Spells[spell] = '1'
  else
   unitTable.Spells[spell] = '0'
  end
  if unitTable.Spells[spell] == '1' then
   changeSpell(unit,spell,'add',verbose)
  end
 end
 if verbose then print('Class change successful! '..storeName..' -> '..currentClass.Name) end
 return true
end

function changeLevel(unit,amount,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local key = tostring(unit.id)
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
 local currentClass = unitTable.Classes.Current
 if currentClass.Name == 'NONE' then
  if verbose then print('Unit does not have a current class assigned. Can not change level') end
  return
 end
 local name = currentClass.Name
 local level = tonumber(unitTable.Classes[name].Level)
 local class = persistTable.GlobalTable.roses.ClassTable[name]
 local maxLevel = false
 if amount > 0 then
  if level + amount >= tonumber(class.Levels) then
   unitTable.Classes[name].Level = class.Levels
   newLevel = tonumber(class.Levels)
   maxLevel = true
  else
   unitTable.Classes[name].Level = tostring(level+amount)
   newLevel = level + amount
  end
 elseif amount < 0 then
  if level + amount <= 0 then
   unitTable.Classes[name].Level = '0'
   newLevel = 0
  else
   unitTable.Classes[name].Level = tostring(level+amount)
   newLevel = level + amount
  end
 end
 --Add/Subtract temporary level bonuses
 if class.BonusAttribute then
  for _,attr in pairs(class.BonusAttribute._children) do
   local bonus = class.BonusAttribute[attr]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attr,bonus[newLevel+1]-bonus[level+1],0,'class')
  end
 end
 if class.BonusSkill then
  for _,skill in pairs(class.BonusSkill._children) do
   local bonus = class.BonusSkill[skill]
   dfhack.script_environment('functions/unit').changeSkill(unit,skill,bonus[newLevel+1]-bonus[level+1],0,'class')
  end
 end
 if class.BonusTrait then
  for _,trait in pairs(class.BonusTrait._children) do
   local bonus = class.BonusTrait[trait]
   dfhack.script_environment('functions/unit').changeTrait(unit,trait,bonus[newLevel+1]-bonus[level+1],0,'class')
  end
 end
 if class.BonusStat then
  for _,stat in pairs(class.BonusStat._children) do
   local bonus = class.BonusStat[stat]
   dfhack.script_environment('functions/unit').changeStat(unit,stat,bonus[newLevel+1]-bonus[level+1],0,'class')
  end
 end
 if class.BonusResistance then
  for _,resistance in pairs(class.BonusResistance._children) do
   local bonus = class.BonusResistance[resistance]
   dfhack.script_environment('functions/unit').changeResistance(unit,resistance,bonus[newLevel+1]-bonus[level+1],0,'class')
  end
 end
 --Add/Subtract permanent level bonuses
 if class.LevelBonus then
  if class.LevelBonus.Attribute then
   for _,attr in pairs(class.LevelBonus.Attribute._children) do
    local amount = class.LevelBonus.Attribute[attr]
    dfhack.script_environment('functions/unit').changeAttribute(unit,attr,amount[newLevel+1],0,'track')
   end
  end
  if class.LevelBonus.Skill then
   for _,skill in pairs(class.LevelBonus.Skill._children) do
    local amount = class.LevelBonus.Skill[skill]
    dfhack.script_environment('functions/unit').changeSkill(unit,skill,amount[newLevel+1],0,'track')
   end
  end
  if class.LevelBonus.Trait then
   for _,trait in pairs(class.LevelBonus.Trait._children) do
    local amount = class.LevelBonus.Trait[trait]
    dfhack.script_environment('functions/unit').changeTrait(unit,trait,amount[newLevel+1],0,'track')
   end
  end
  if class.LevelBonus.Stat then
   for _,stat in pairs(class.LevelBonus.Stat._children) do
    local amount = class.LevelBonus.Stat[stat]
    dfhack.script_environment('functions/unit').changeStat(unit,stat,amount[newLevel+1],0,'track')
   end
  end
  if class.LevelBonus.Resistance then
   for _,resistance in pairs(class.LevelBonus.Resistance._children) do
    local amount = class.LevelBonus.Resistance[resistance]
    dfhack.script_environment('functions/unit').changeResistance(unit,trait,amount[newLevel+1],0,'track')
   end
  end
 end
 --Learn/Unlearn Skills
 for _,spell in pairs(class.Spells._children) do
  local spellTable = class.Spells[spell]
  if amount > 0 and tonumber(spellTable.RequiredLevel) <= newLevel then
   if spellTable.AutoLearn then
    changeSpell(unit,spell,'learn',verbose)
   end
  elseif amount < 0 and tonumber(spellTable.RequiredLevel) > newLevel then
   changeSpell(unit,spell,'unlearn',verbose)
  end
 end
 if maxLevel then
  if verbose then print('Maximum level for class '..name..' reached!') end
  if class.AutoUpgrade then
   if verbose then print('Auto upgrading class to '..class.AutoUpgrade) end
   changeClass(unit,class.AutoUpgrade,verbose)
  end
 end
end

function changeName(unit,name,direction,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local synUtils = require 'syndrome-util'
 if direction == 'add' then
  dfhack.script_environment('functions/unit').changeSyndrome(unit,name,'add',0)
 elseif direction == 'remove' then
  dfhack.script_environment('functions/unit').changeSyndrome(unit,name,'erase',0)
 elseif direction == 'removeall' then
  dfhack.script_environment('functions/unit').changeSyndrome(unit,'CLASS_NAME','eraseClass',0)
 end
end

function changeSpell(unit,spell,direction,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local key = tostring(unit.id)
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
 if not unitTable.Spells[spell] then dfhack.script_environment('functions/tables').makeUnitTableSpell(unit,spell) end
 if direction == 'add' then
  test, upgrade = checkRequirementsSpell(unit,spell,verbose)
  if test then
   dfhack.script_environment('functions/unit').changeSyndrome(unit,spell,'add',0)
   unitTable.Spells.Active[spell] = spell
  end
  if upgrade then
   dfhack.script_environment('functions/unit').changeSyndrome(unit,upgrade,'erase',0)
   unitTable.Spells.Active[upgrade] = nil
  end
 elseif direction == 'remove' then
  dfhack.script_environment('functions/unit').changeSyndrome(unit,spell,'erase',0)
  unitTable.Spells.Active[spell] = nil
 elseif direction == 'removeall' then
  dfhack.script_environment('functions/unit').changeSyndrome(unit,'CLASS_SPELL','eraseClass',0)
 elseif direction == 'learn' then
  if unitTable.Spells[spell] == '1' then
   if verbose then print('Spell already known, adding to unit') end
  else
   test, upgrade = checkRequirementsSpell(unit,spell,verbose)
   if test then
    if verbose then print('Spell learned, adding to unit') end
    unitTable.Spells[spell] = '1'
    changeSpell(unit,spell,'add',verbose)
    if unitTable.Classes.Current.Name ~= 'NONE' then
     unitTable.Classes[unitTable.Classes.Current.Name].SkillExp = tostring(unitTable.Classes[unitTable.Classes.Current.Name].SkillExp - persistTable.GlobalTable.roses.SpellTable[spell].Cost)
    end
   end
  end
 elseif direction == 'unlearn' then
  if unitTable.Spells[spell] == '1' then
   if verbose then print('Spell loss, removing from unit') end
   unitTable.Spells[spell] = '0'
  else
   if verbose then print('Spell not known') end
  end
  changeSpell(unit,spell,'remove',verbose)
 end
end

function checkRequirementsClass(unit,class,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local key = tostring(unit.id)
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
 local unitClasses = unitTable.Classes
 local unitCounters = unitTable.Counters
 local currentClass = unitClasses.Current
 local classTable = persistTable.GlobalTable.roses.ClassTable[class]
 if not classTable then
  if verbose then print ('No specified class to check for requirements') end
  return false
 end
-- local currentClassName = currentClass.Name
-- local currentClassLevel = unitClasses[currentClass.Name].Level
-- Check for Required Class
 if classTable.RequiredClass then
  for _,class in pairs(classTable.RequiredClass._children) do
   local check = unitClasses[class].Level
   local level = classTable.RequiredClass[class]
   if tonumber(check) < tonumber(level) then
    if verbose then print('Class requirements not met. '..class..' level '..level..' needed. Current level is '..tostring(check)) end
    return false
   end
  end
 end
-- Check for Forbidden Class
 if classTable.ForbiddenClass then 
  for _,class in pairs(classTable.ForbiddenClass._children) do
   local check = unitClasses[class]
   local level = classTable.ForbiddenClass[class]
   if tonumber(check.Level) >= tonumber(level) and tonumber(level) ~= 0 then
    if verbose then print('Already a member of a forbidden class. '..class) end
    return false
   elseif tonumber(level) == 0 and tonumber(check.Experience) > 0 then
    if verbose then print('Already a member of a forbidden class. '..class) end
    return false
   end
  end
 end
-- Check for Required Counters (not currently working)
 --[[
 for _,x in pairs(classTable.RequiredCounter._children) do
  local i = classes[change]['RequiredCounter'][x]
  if unitCounters[x] then
   if tonumber(unitCounters[x]['Value']) < tonumber(x) then
    if verbose then print('Counter requirements not met. '..i..x..' needed. Current amount is '..unitCounters[i]['Value']) end
    yes = false
   end
  else
   if verbose then print('Counter requirements not met. '..i..x..' needed. No current counter on the unit') end
   yes = false
  end
 end
]]
-- Check for Required Attributes
 if classTable.RequiredAttribute then
  for _,attr in pairs(classTable.RequiredAttribute._children) do
   local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
   local check = total-change-class-syndrome
   local value = classTable.RequiredAttribute[attr]
   if check < tonumber(value) then
    if verbose then print('Stat requirements not met. '..value..' '..attr..' needed. Current amount is '..tostring(check)) end
    return false
   end
  end
 end
-- Check for Required Skills
 if classTable.RequiredSkill then
  for _,skill in pairs(classTable.RequiredSkill._children) do
   local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackSkill(unit,skill,0,0,0,0,'get')
   local check = total-change-class-syndrome
   local value = classTable.RequiredSkill[skill]
   if currentSkill < tonumber(value) then
    if verbose then print('Skill requirements not met. '..value..' '..skill..' needed. Current amount is '..tostring(check)) end
    return false
   end
  end
 end
-- Check for Required Traits
 if classTable.RequiredTrait then
  for _,trait in pairs(classTable.RequiredTrait._children) do
   local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackTrait(unit,trait,0,0,0,0,'get')
   local check = total-change-class-syndrome
   local value = classTable.RequiredTrait[trait]
   if currentTrait < tonumber(value) then
    if verbose then print('Trait requirements not met. '..value..' '..trait..' needed. Current amount is '..tostring(check)) end
    return false
   end
  end
 end
 return true
end

function checkRequirementsSpell(unit,spell,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local key = tostring(unit.id)
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
 local unitClasses = unitTable.Classes
 local unitCounters = unitTable.Counters
 local currentClass = unitClasses.Current
 local currentClassName = currentClass.Name
 local currentClassLevel = unitClasses[currentClassName].Level
 local classTable = persistTable.GlobalTable.roses.ClassTable[currentClassName]
 local spellTable = persistTable.GlobalTable.roses.SpellTable[spell]
 if not classTable then
  if verbose then print ('No specified class to check for requirements') end
  return false
 end
 if not spellTable then
  if verbose then print('No valid spell to check for requirements') end
  return false
 end
 local found = false
 local upgrade = false
 local classSpellTable = classTable.Spells[spell]
 if spellTable then
-- Check for Required Class
  if tonumber(currentClassLevel) < tonumber(classSpellTable.RequiredLevel) then
   if verbose then print('Class requirements not met. '..currentClassName..' level '..classSpellTable.RequiredLevel..' needed. Current level is '..tostring(currentClassLevel)) end
   return false
  end
-- Check for Forbidden Class
  if spellTable.ForbiddenClass then
   for _,class in pairs(spellTable.ForbiddenClass._children) do
    local check = unitClasses[class]
    local level = spellTable.ForbiddenClass[class]
    if tonumber(check.Level) >= tonumber(level) and tonumber(level) ~= 0 then
     if verbose then print('Already a member of a forbidden class: '..class) end
     return false
    elseif tonumber(level) == 0 and tonumber(check.Experience) > 0 then
     if verbose then print('Already a member of a forbidden class: '..class) end
     return false
    end
   end
  end
-- Check for Forbidden Spell
  if spellTable.ForbiddenSpell then
   local synUtils = require 'syndrome-util'
   for _,i in pairs(spellTable.ForbiddenSpell._children) do
    for _,syn in ipairs(df.global.world.raws.syndromes.all) do
     local x = spellTable.ForbiddenSpell[i]
     if syn.syn_name == x then
      oldsyndrome = synUtils.findUnitSyndrome(unit,syn.id)
      if oldsyndrome then
       if verbose then print('Knows a forbidden spell: '..x) end
       return false
      end
     end
    end
   end
  end
-- Check for Required Attributes
  if spellTable.RequiredAttribute then
   for _,attr in pairs(spellTable.RequiredAttribute._children) do
    local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
    local check = total-change-class-syndrome
    local value = spellTable.RequiredAttribute[attr]
    if currentStat < tonumber(value) then
     if verbose then print('Stat requirements not met. '..value..' '..attr..' needed. Current amount is '..tostring(check)) end
     return false
    end
   end
  end
-- Check for Cost
  if spellTable.Cost then
   if tonumber(unitClasses[currentClassName].SkillExp) < tonumber(spellTable.Cost) then
    if verbose then print('Not enough points to learn spell. Needed '..spellTable.Cost..' currently have '..unitClasses[currentClassName].SkillExp) end
    return false
   end
  end
  if spellTable.Upgrade then upgrade = spellTable.Upgrade end
 else
  if verbose then print(spell..' not learnable by '..currentClassName) end
  return false
 end
 return true, upgrade
end

-- FEAT FUNCTIONS

function addFeat(unit,feat,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local key = tostring(unit.id)
 local persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses.FeatTable then return end
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 local featTable = persistTable.GlobalTable.roses.FeatTable[feat]
 if not featTable then
  if verbose then print('Not a valid feat: '..feat) end
  return
 end
 test = checkRequirementsFeat(unit,feat,verbose)
 if test then
  unitTable[key].Feats[feat] = feat
  currentClass = persistTable.GlobalTable.roses.ClassTable.Current
  currentClass.FeatPoints = tostring(tonumber(currentClass.FeatPoints) - tonumber(featTable.Cost))
  for _,x in pairs(featTable.Script._children) do
   effect = featTable.Script[x]
   effect = effect:gsub('UNIT_ID',key)
   dfhack.run_command(effect)
  end
 end
end

function checkRequirementsFeat(unit,feat,verbose)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local key = tostring(unit.id)
 local persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses.FeatTable then return false end
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then dfhack.script_environment('functions/tables').makeUnitTable(unit) end
 featTable = persistTable.GlobalTable.roses.FeatTable[feat]
 if not featTable then
  if verbose then print('Not a valid feat: '..feat) end
  return false
 end
 local unitClasses = unitTable[key].Classes
 local currentClass = unitClasses.Current
 local currentClassName = currentClass.Name
 local currentClassLevel = unitClasses[currentClassName].Level
 if tonumber(featTable.Cost) > tonumber(currentClass.FeatPoints) then
  if verbose then print('Not enough feat points to learn feat') end
  return false
 end
 if featTable.ForbiddenClass then
  for _,class in pairs(featTable.ForbiddenClass._children) do
   level = featTable.ForbiddenClass[class]
   if unitClasses[class] then
    if tonumber(level) == 0 and tonumber(unitClasses[class].Experience) > 0 then
     if verbose then print('Unit has experience in a forbidden class') end
     return false
    elseif tonumber(level) < tonumber(unitClasses[class].Level) then
     if verbose then print('Unit has too many levels in a forbidden class') end
     return false
    end
   end
  end
 end
 if featTable.ForbiddenFeat then
  for _,forbiddenFeat in pairs(featTable.ForbiddenFeat._children) do
   if unitTable[key].Feats[forbiddenFeat] then
    if verbose then print('Unit has a forbidden feat') end
    return false
   end
  end
 end
 check = true
 if featTable.RequiredFeat then
  for _,requiredFeat in pairs(featTable.RequiredFeat._children) do
   if not unitTable[key].Feats[requiredFeat] then
    check = false
   end
  end
 end
 if not check then
  if verbose then print('Unit does not have the required feat') end
  return false
 end
 if featTable.RequiredClass then
  for _,class in pairs(featTable.RequiredClass._children) do
   level = featTable.RequiredClass[class]
   if not unitClasses[class] then
    check = false
   end
   if tonumber(level) == 0 and tonumber(unitClasses[class].Experience) == 0 then
    check = false
   elseif tonumber(level) > tonumber(unitClasses[class].Level) then
    check = false
   end
  end
 end
 if not check then
  if verbose then print('Unit does not have the required class') end
  return false
 end
 return true
end

-- CLASS FUNCTIONS
function addExperience(unit,amount,verbose)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local unitID = unit.id

 local persistTable = require 'persist-table'
 local utils = require 'utils'
 local split = utils.split_string
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unitID)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unitID)
 end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unitID)]
 local unitClasses = unitTable.Classes
 local currentClass = unitClasses.Current
 local classTable = persistTable.GlobalTable.roses.ClassTable
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
 if currentClass.Name ~= 'NONE' then
  local currentClassName = currentClass.Name
  unitClasses[currentClassName].Experience = tostring(unitClasses[currentClassName].Experience + amount)
  unitClasses[currentClassName].SkillExp = tostring(unitClasses[currentClassName].SkillExp + amount)
  local currentClassLevel = tonumber(unitClasses[currentClassName].Level)
  if currentClassLevel < tonumber(classTable[currentClassName].Levels) then
   classExpLevel = tonumber(classTable[currentClassName].Experience[tostring(currentClassLevel+1)])
   if tonumber(unitClasses[currentClassName].Experience) >= classExpLevel then
    if verbose then
     print('LEVEL UP! '..currentClassName..' LEVEL '..tostring(currentClassLevel+1))
     changeLevel(unitID,1,true)
    else
     changeLevel(unitID,1,false)
    end
   end
  end
 end
end

function changeClass(unit,change,verbose)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)

 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
 if not unitTable[key].Classes[change] then
  dfhack.script_environment('functions/tables').makeUnitTableClass(unit,change)
 end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
-- Change the units class
 local currentClass = unitTable.Classes.Current
 local nextClass = unitTable.Classes[change]
 if not nextClass then
  print('No such class to change into')
  return false
 end
 if not checkRequirementsClass(unit,change,verbose) then
  print('Does not meet class requirements')
  return false
 end
 local classes = persistTable.GlobalTable.roses.ClassTable
 if currentClass.Name == change then
  print('Already this class')
  return false
 end
 local storeName = 'NONE'
 if currentClass.Name ~= 'NONE' then
  local storeClass = unitTable.Classes[currentClass.Name]
  storeName = currentClass.Name
  local currentClassLevel = storeClass.Level
  -- Remove Class Name From Unit
  changeName(unit,currentClass.Name,'remove')
  -- Remove Physical Attribute Bonuses
  if classes[currentClass.Name].BonusPhysical then
   for _,attr in pairs(classes[currentClass.Name].BonusPhysical._children) do
    local attrTable = classes[currentClass.Name].BonusPhysical[attr]
    dfhack.script_environment('functions/unit').changeAttribute(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
   end
  end
  -- Remove Mental Attribute Bonuses
  if classes[currentClass.Name].BonusMental then
   for _,attr in pairs(classes[currentClass.Name].BonusMental._children) do
    local attrTable = classes[currentClass.Name].BonusMental[attr]
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
 -- Add Physical Attribute Bonuses
 if classes[currentClass.Name].BonusPhysical then
  for _,attr in pairs(classes[currentClass.Name].BonusPhysical._children) do
   local attrTable = classes[currentClass.Name].BonusPhysical[attr]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
 end
 -- Add Mental Attribute Bonuses
 if classes[currentClass.Name].BonusMental then
  for _,attr in pairs(classes[currentClass.Name].BonusMental._children) do
   local attrTable = classes[currentClass.Name].BonusMental[attr]
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
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)

 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
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
 if class.BonusPhysical then
  for _,attr in pairs(class.BonusPhysical._children) do
   local bonus = class.BonusPhysical[attr]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attr,bonus[newLevel+1]-bonus[level+1],0,'class')
  end
 end
 if class.BonusMental then
  for _,attr in pairs(class.BonusMental._children) do
   local bonus = class.BonusMental[attr]
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

 --Add/Subtract permanent level bonuses
 if class.LevelBonus then
  if class.LevelBonus.Physical then
   for _,attr in pairs(class.LevelBonus.Physical._children) do
    local amount = class.LevelBonus.Physical[attr]
    dfhack.script_environment('functions/unit').changeAttribute(unit,attr,amount,0,'track')
   end
  end
  if class.LevelBonus.Mental then
   for _,attr in pairs(class.LevelBonus.Mental._children) do
    local amount = class.LevelBonus.Mental[attr]
    dfhack.script_environment('functions/unit').changeAttribute(unit,attr,amount,0,'track')
   end
  end
  if class.LevelBonus.Skill then
   for _,skill in pairs(class.LevelBonus.Skill._children) do
    local amount = class.LevelBonus.Skill[skill]
    dfhack.script_environment('functions/unit').changeSkill(unit,skill,amount,0,'track')
   end
  end
  if class.LevelBonus.Trait then
   for _,trait in pairs(class.LevelBonus.Trait._children) do
    local amount = class.LevelBonus.Trait[trait]
    dfhack.script_environment('functions/unit').changeTrait(unit,trait,amount,0,'track')
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

function changeName(unit,name,direction)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

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
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local key = tostring(unit.id)
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
 if not unitTable.Spells[spell] then
  dfhack.script_environment('functions/tables').makeUnitTableSpell(unit,spell)
 end
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
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)

 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
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
-- Check for Required Physical Attributes
 if classTable.RequiredPhysical then
  for _,attr in pairs(classTable.RequiredPhysical._children) do
   local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
   local check = total-change-class-syndrome
   local value = classTable.RequiredPhysical[attr]
   if check < tonumber(value) then
    if verbose then print('Stat requirements not met. '..value..' '..attr..' needed. Current amount is '..tostring(check)) end
    return false
   end
  end
 end
-- Check for Required Mental Attributes
 if classTable.RequiredMental then
  for _,attr in pairs(classTable.RequiredMental._children) do
   local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
   local check = total-change-class-syndrome
   local value = classTable.RequiredMental[attr]
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

-- SPELL FUNCTIONS

function Spell(source,target,spell)
 if tonumber(source) then
  source = df.unit.find(tonumber(source))
 end
 if source then
  sourceID = tostring(source.id)
 else
  print('No valid source declared')
  return
 end
 if tonumber(target) then
  target = df.unit.find(tonumber(target))
 end
 if target then
  targetID = tostring(target.id)
 else
  targetID = '-1'
 end
 local persistTable = require 'persist-table'
 
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[sourceID] then
  dfhack.script_environment('functions/tables').makeUnitTable(source)
 end
 unitTable = unitTable[sourceID]
 
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  print('Not a valid spell')
  return
 end
 spellTable = spellTable[spell]

 -- check for casting speed buffs/debuffs
 if not unitTable.Stats.CastingSpeed then dfhack.script_environment('functions/tables').makeUnitTableStat(source,'CastingSpeed') end
 speedTable = unitTable.Stats.CastingSpeed
 speed = 100 - tonumber(speedTable.Base) - tonumber(speedTable.Change) - tonumber(speedTable.Item) - tonumber(speedTable.Class)
 
 -- check for casting skill and determine exhaustion
 if not unitTable.Skills['SPELL_CASTING'] then dfhack.script_environment('functions/tables').makeUnitTableSkill(source,'SPELL_CASTING') end
 if unitTable.Skills['SPELL_CASTING'] and spellTable.CastExhaustion then
  castTable = unitTable.Skills['SPELL_CASTING']
  castSkill = tonumber(castTable.Base) + tonumber(castTable.Change) + tonumber(castTable.Item) + tonumber(castTable.Class)
  if castSkill < 0 then castSkill = 0 end
  if castSkill > 20 then castSkill = 20 end
  exhaustion = (100 - 4*castSkill)/100
  exhaustion = exhaustion*tonumber(spellTable.CastExhaustion)
 else
  exhaustion = spellTable.CastExhaustion
 end
 
 -- process spell -> Set delay (if necessary) -> Cast Spell -> Gain Experience -> Gain Skill -> Add Exhaustion
 if spellTable.CastTime and speed > 0 then
  speed = math.floor((speed/100)*tonumber(spellTable.CastTime))
  if speed == 0 then speed = 1 end
  dfhack.run_command('unit/action-change -unit '..sourceID..' -action All -interaction All -timer '..tostring(speed))
  dfhack.script_environment('persist-delay').environmentDelay(speed,'functions/class','castSpell',{sourceID,targetID,spell})
  if exhaustion then dfhack.script_environment('persist-delay').environmentDelay(speed,'functions/unit','changeCounter',{sourceID,'exhaustion',exhaustion}) end
  if spellTable.ExperienceGain then dfhack.script_environment('persist-delay').environmentDelay(speed,'functions/class','addExperience',{sourceID,spellTable.ExperienceGain}) end
  if spellTable.SkillGain then
   for _,skill in pairs(spellTable.SkillGain._children) do
    amount = spellTable.SkillGain[skill]
    dfhack.script_environment('persist-delay').environmentDelay(speed,'functions/unit','changeSkill',{sourceID,skill,amount})
   end
  end
 else
  castSpell(source,target,spell)
  if exhaustion then dfhack.script_environment('functions/unit').changeCounter(sourceID,'exhaustion',exhaustion) end
  if spellTable.ExperienceGain then addExperience(sourceID,tonumber(spellTable.ExperienceGain)) end
  if spellTable.SkillGain then
   for _,skill in pairs(spellTable.SkillGain._children) do
    amount = spellTable.SkillGain[skill]
    dfhack.script_environment('functions/unit').changeSkill(sourceID,skill,amount)
   end
  end  
 end
end

function castSpell(source,target,spell)
 if tonumber(source) then
  source = df.unit.find(tonumber(source))
 end
 if source then
  sourceID = tostring(source.id)
 else
  sourceID = "\\-1"
 end
 if tonumber(target) then
  target = df.unit.find(tonumber(target))
 end
 if target then
  targetID = tostring(target.id)
 else
  targetID = "\\-1"
 end
 
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 if not spellTable[spell] then
  print('Not a valid spell')
  return
 end
 spellTable = spellTable[spell]
 
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

function checkRequirementsSpell(unit,spell,verbose)

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)

 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
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
     if verbose then print('Already a member of a forbidden class. '..class) end
     return false
    elseif tonumber(level) == 0 and tonumber(check.Experience) > 0 then
     if verbose then print('Already a member of a forbidden class. '..class) end
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
       if verbose then print('Knows a forbidden spell. '..x) end
       return false
      end
     end
    end
   end
  end
-- Check for Required Physical Attributes
  if spellTable.RequiredPhysical then
   for _,attr in pairs(spellTable.RequiredPhysical._children) do
    local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
    local check = total-change-class-syndrome
    local value = spellTable.RequiredPhysical[attr]
    if currentStat < tonumber(value) then
     if verbose then print('Stat requirements not met. '..value..' '..attr..' needed. Current amount is '..tostring(check)) end
     return false
    end
   end
  end
-- Check for Required Mental Attributes
  if spellTable.RequiredMental then
   for _,attr in pairs(spellTable.RequiredMental._children) do
    local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
    local check = total-change-class-syndrome
    local value = spellTable.RequiredMental[attr]
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
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)
 
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
 featTable = persistTable.GlobalTable.roses.FeatTable[feat]
 if not featTable then
  print('Not a valid feat')
  return
 end
 
 test = checkRequirementsFeat(unit,feat,verbose)
 if test then
  unitTable[key].Feats[feat] = feat
  currentClass = persistTable.GlobalTable.roses.ClassTable.Current
  currentClass.FeatPoints = tostring(tonumber(currentClass.FeatPoints) - tonumber(featTable.Cost))
  for _,x in pairs(featTable.Effect,_children) do
   effect = featTable.Effect[x]
   effect = effect:gsub('UNIT_ID',key)
   dfhack.run_command(effect)
  end
 end
end

function checkRequirementsFeat(unit,feat,verbose)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)
 
 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
 featTable = persistTable.GlobalTable.roses.FeatTable[feat]
 if not featTable then
  if verbose then print('Not a valid feat') end
  return
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
   if unitTable[key].Feats.Active[forbiddenFeat] then
    if verbose then print('Unit has a forbidden feat') end
    return false
   end
  end
 end
 
 check = true
 if featTable.RequiredFeat then
  for _,requiredFeat in pairs(featTable.RequiredFeat._children) do
   if not unitTable[key].Feats.Active[requiredFeat] then
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

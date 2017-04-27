function makeBaseTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.BaseTable = {}
 
 print('Searching for an included base file')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/','/raw/files/','/raw/scripts/'}
 local n = 1
 for _,location in ipairs(locations) do
  local path = dir..location
--  print('Looking in '..location)
  for _,fname in pairs(dfhack.internal.getDir(path)) do
   if (fname == 'base.txt') then
    files[n] = path..fname
    n = n + 1
   end
  end
 end
 
 base = persistTable.GlobalTable.roses.BaseTable
 base.ExperienceRadius = '-1'
 base.FeatGains = '100:25'
 base.CustomAttributes = {}
 base.CustomSkills = {}
 base.CustomResistances = {}
 base.CustomStats = {}
 if #files < 1 then
  print('No Base file found, assuming defaults')
 else
  for _,file in ipairs(files) do
   local data = {}
   local iofile = io.open(file,"r")
   local lineCount = 1
   while true do
    local line = iofile:read("*line")
    if line == nil then break end
    data[lineCount] = line
    lineCount = lineCount + 1
   end
   iofile:close()  
   
   for i,line in pairs(data) do
    test = line:gsub("%s+","")
    test = split(test,':')[1]
    array = split(line,':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if test == '[EXPERIENCE_RADIUS' then
     base.ExperienceRadius = array[2]
    elseif test == '[FEAT_GAINS' then
     base.FeatGains = array[2]..':'..array[3]
    elseif test == '[SKILL' then
     base.CustomSkills[array[2]] = array[3]
    elseif test == '[ATTRIBUTE' then
     base.CustomAttributes[array[2]] = array[2]
    elseif test == '[RESISTANCE' then
     resistanceTable = base.CustomResistances
     for j,x in pairs(array) do
      if j == 1 then
       a = 1
      elseif j == #array then
       resistanceTable[array[j]] = array[j]
      else
       resistanceTable[array[j]] = resistanceTable[array[j]] or {}
       resistanceTable = resistanceTable[array[j]]
      end
     end
    elseif test == '[STAT' then
     base.CustomStats[array[2]] = array[2]
    end
   end
  end
 end
end

function makeCivilizationTable()

 function tchelper(first, rest)
  return first:upper()..rest:lower()
 end

 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.CivilizationTable = {}

 print('Searching for civilization files')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/Civilizations/','/raw/scripts/files/'}
 local n = 1
 for location in ipairs(locations) do
  local path = dir..location
  print('Looking in '..location)
  for _,fname in pairs(dfhack.internal.getDir(path)) do
   if (split(fname,'_')[1] == 'civilizations' or fname == 'civilizations.txt') then
    files[n] = path..fname
    n = n + 1
   end
  end
 end

 if #files >= 1 then
  print('Civilization files found:')
  printall(files)
 else
  print('No Civilization files found')
  return false
 end

 civilizations = persistTable.GlobalTable.roses.CivilizationTable
 for _,file in ipairs(files) do

  local data = {}
  local iofile = io.open(file,"r")
  local lineCount = 1
  while true do
   local line = iofile:read("*line")
   if line == nil then break end
   data[lineCount] = line
   lineCount = lineCount + 1
  end
  iofile:close()

  local dataInfo = {}
  local count = 1
  for i,line in ipairs(data) do
   if split(line,':')[1] == '[CIVILIZATION' then
    dataInfo[count] = {split(split(line,':')[2],']')[1],i,0}
    count = count + 1
   end
  end

 for i,x in ipairs(dataInfo) do
  civilizationToken = x[1]
  startLine = x[2]+1
  if i ==#dataInfo then
   endLine = #data
  else
   endLine = dataInfo[i+1][2]-1
  end
  civilizations[civilizationToken] = {}
  civilization = civilizations[civilizationToken]
  civilization.Level = {}
  civilization.Positions = {}
  for j = startLine,endLine,1 do
   test = data[j]:gsub("%s+","")
   test = split(test,':')[1]
   array = split(data[j],':')
   for k = 1, #array, 1 do
    array[k] = split(array[k],']')[1]
   end
   if test == '[NAME' then
    civilization.Name = array[2]
   elseif test == '[LEVELS' then
    civilization.Levels = array[2]
   elseif test == '[LEVEL_METHOD' then
    civilization.LevelMethod = array[2]
    civilization.LevelPercent = array[3]
   elseif test == '[LEVEL' then
    level = array[2]
    civilization.Level[level] = {}
    civsLevel = civilization.Level[level]
    civsLevel.Ethics = {}
    civsLevel.RemovePosition = {}
    civsLevel.AddPosition = {}
    civsLevel.Remove = {}
    civsLevel.Remove.Creature = {}
    civsLevel.Remove.Organic = {}
    civsLevel.Remove.Inorganic = {}
    civsLevel.Remove.Refuse = {}
    civsLevel.Remove.Item = {}
    civsLevel.Remove.Misc = {}
    civsLevel.Add = {}
    civsLevel.Add.Creature = {}
    civsLevel.Add.Organic = {}
    civsLevel.Add.Inorganic = {}
    civsLevel.Add.Refuse = {}
    civsLevel.Add.Item = {}
    civsLevel.Add.Misc = {}
   elseif test == '[LEVEL_NAME' then
    civsLevel.Name = array[2]
   elseif test == '[LEVEL_REMOVE' then
    subType = array[3]:gsub("(%a)([%w_']*)", tchelper)
    if array[2] == 'CREATURE' then
     civsLevel.Remove.Creature[subType] = civsLevel.Remove.Creature[subType] or {}
     civsLevel.Remove.Creature[subType][array[4]] = array[5]
    elseif array[2] == 'INORGANIC' then
     civsLevel.Remove.Inorganic[subType] = civsLevel.Remove.Inorganic[subType] or {}
     civsLevel.Remove.Inorganic[subType][array[4]] = array[4]
    elseif array[2] == 'ORGANIC' then
     civsLevel.Remove.Organic[subType] = civsLevel.Remove.Organic[subType] or {}
     civsLevel.Remove.Organic[subType][array[4]] = array[5]
    elseif array[2] == 'REFUSE' then
     civsLevel.Remove.Refuse[subType] = civsLevel.Remove.Refuse[subType] or {}
     civsLevel.Remove.Refuse[subType][array[4]] = array[5]
    elseif array[2] == 'ITEM' then
     civsLevel.Remove.Item[subType] = civsLevel.Remove.Item[subType] or {}
     civsLevel.Remove.Item[subType][array[4]] = array[4]
    elseif array[2] == 'MISC' then
     civsLevel.Remove.Misc[subType] = civsLevel.Remove.Misc[subType] or {}
     civsLevel.Remove.Misc[subType][array[4]] = array[5]
    end
   elseif test == '[LEVEL_ADD' then
    subType = array[3]:gsub("(%a)([%w_']*)", tchelper)
    if array[2] == 'CREATURE' then
     civsLevel.Add.Creature[subType] = civsLevel.Add.Creature[subType] or {}
     civsLevel.Add.Creature[subType][array[4]] = array[5]
    elseif array[2] == 'INORGANIC' then
     civsLevel.Add.Inorganic[subType] = civsLevel.Add.Inorganic[subType] or {}
     civsLevel.Add.Inorganic[subType][array[4]] = array[4]
    elseif array[2] == 'ORGANIC' then
     civsLevel.Add.Organic[subType] = civsLevel.Add.Organic[subType] or {}
     civsLevel.Add.Organic[subType][array[4]] = array[5]
    elseif array[2] == 'REFUSE' then
     civsLevel.Add.Refuse[subType] = civsLevel.Add.Refuse[subType] or {}
     civsLevel.Add.Refuse[subType][array[4]] = array[5]
    elseif array[2] == 'ITEM' then
     civsLevel.Add.Item[subType] = civsLevel.Add.Item[subType] or {}
     civsLevel.Add.Item[subType][array[4]] = array[4]
    elseif array[2] == 'MISC' then
     civsLevel.Add.Misc[subType] = civsLevel.Add.Misc[subType] or {}
     civsLevel.Add.Misc[subType][array[4]] = array[5]
    end
   elseif testa== '[LEVEL_CHANGE_ETHIC' then
    civsLevel.Ethics[array[2]:gsub("(%a)([%w_']*)", tchelper)] = array[3]
   elseif test == '[LEVEL_CHANGE_METHOD' then
    civsLevel.LevelMethod = array[2]
    civsLevel.LevelPercent = array[3]
   elseif test == '[LEVEL_REMOVE_POSITION' then
    civsLevel.RemovePosition[array[2]] = array[2]
   elseif test == '[LEVEL_ADD_POSITION' then
    position = array[2]
    civsLevel.AddPosition[position] = position
    civilization.Positions[position] = {}
    civsAddPosition = civilization.Positions[position]
    civsAddPosition.AllowedCreature = {}
    civsAddPosition.AllowedClass = {}
    civsAddPosition.RejectedCreature = {}
    civsAddPosition.RejectedClass = {}
    civsAddPosition.Responsibility = {}
    civsAddPosition.AppointedBy = {}
    civsAddPosition.Flags = {}
   elseif test == '[ALLOWED_CREATURE' then
    civsAddPosition.AllowedCreature[array[2]] = array[3]
   elseif test == '[REJECTED_CREATURE' then
    civsAddPosition.RejectedCreature[array[2]] = array[3]
   elseif test == '[ALLOWED_CLASS' then
    civsAddPosition.AllowedClass[array[2]] = array[2]
   elseif test == '[REJECTED_CLASS' then
    civsAddPosition.RejectedClass[array[2]] = array[2]
   elseif test == '[NAME' then
    civsAddPosition.Name = array[2]..':'..array[3]
   elseif test == '[NAME_MALE' then
    civsAddPosition.NameMale = array[2]..':'..array[3]
   elseif test == '[NAME_FEMALE' then
    civsAddPosition.NameFemale = array[2]..':'..array[3]
   elseif test == '[SPOUSE' then
    civsAddPosition.Spouse = array[2]..':'..array[3]
   elseif test == '[SPOUSE_MALE' then
    civsAddPosition.SpouseMale = array[2]..':'..array[3]
   elseif test == '[SPOUSE_FEMALE' then
    civsAddPosition.SpouseFemale = array[2]..':'..array[3]
   elseif test == '[NUMBER' then
    civsAddPosition.Number = array[2]
   elseif test == '[SUCCESSION' then
    civsAddPosition.Sucession = array[2]
   elseif test == '[LAND_HOLDER' then
    civsAddPosition.LandHolder = array[2]
   elseif test == '[LAND_NAME' then
    civsAddPosition.LandName = array[2]
   elseif test == '[APPOINTED_BY' then
    civsAddPosition.AppointedBy[array[2]] = array[2]
   elseif test == '[REPLACED_BY' then
    civsAddPosition.ReplacedBy = array[2]
   elseif test == '[RESPONSIBILITY' then
    civsAddPosition.Responsibility[array[2]] = array[2]
   elseif test == '[PRECEDENCE' then
    civsAddPosition.Precedence = array[2]
   elseif test == '[REQUIRES_POPULATION' then
    civsAddPosition.RequiresPopulation = array[2]
   elseif test == '[REQUIRED_BOXES' then
    civsAddPosition.RequiredBoxes = array[2]
   elseif test == '[REQUIRED_CABINETS' then
    civsAddPosition.RequiredCabinets = array[2]
   elseif test == '[REQUIRED_RACKS' then
    civsAddPosition.RequiredRacks = array[2]
   elseif test == '[REQUIRED_STANDS' then
    civsAddPosition.RequiredStands = array[2]
   elseif test == '[REQUIRED_OFFICE' then
    civsAddPosition.RequiredOffice = array[2]
   elseif test == '[REQUIRED_BEDROOM' then
    civsAddPosition.RequiredBedroom = array[2]
   elseif test == '[REQUIRED_DINING' then
    civsAddPosition.RequiredDining = array[2]
   elseif test == '[REQUIRED_TOMB' then
    civsAddPosition.RequiredTomb = array[2]
   elseif test == '[MANDATE_MAX' then
    civsAddPosition.MandateMax = array[2]
   elseif test == '[DEMAND_MAX' then
    civsAddPosition.DemandMax = array[2]
   elseif test == '[COLOR' then
    civsAddPosition.Color = array[2]..':'..array[3]..':'..array[4]
   elseif test == '[SQUAD' then
    civsAddPosition.Squad = array[2]..':'..array[3]..':'..array[4]
   elseif test == '[COMMANDER' then
    civsAddPosition.Commander = array[2]..':'..array[3]
   elseif test == '[FLAGS' then
    civsAddPosition.Flags[array[2]] = 'true'
   else
    if position then civsAddPosition[split(split(data[j],']')[1],'%[')[2]] = 'true' end
   end
  end
 end
 end

 for id,entity in pairs(df.global.world.entities.all) do
  makeEntityTable(id)
 end

 return true
end

function makeClassTable(spellCheck)
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.ClassTable = {}
 
 print('Searching for class files')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/Classes/'}
 local n = 1
 for _,location in ipairs(locations) do
  local path = dir..location
--  print('Looking in '..location)
  for _,fname in pairs(dfhack.internal.getDir(path)) do
   if (split(fname,'_')[1] == 'classes' or fname == 'classes.txt') then
    files[n] = path..fname
    n = n + 1
   end
  end
 end

 if #files >= 1 then
--  print('Class files found:')
--  printall(files)
 else
--  print('No Class files found')
  return false
 end

 if not spellCheck then
--  print('Generating spell tables from class files')
  persistTable.GlobalTable.roses.SpellTable = {}
 end
 
 classes = persistTable.GlobalTable.roses.ClassTable
 for _,file in ipairs(files) do

  local data = {}
  local iofile = io.open(file,"r")
  local lineCount = 1
  while true do
   local line = iofile:read("*line")
   if line == nil then break end
   data[lineCount] = line
   lineCount = lineCount + 1
  end
  iofile:close()

  local dataInfo = {}
  local count = 1
  for i,line in ipairs(data) do
   if split(line,':')[1] == '[CLASS' then
    dataInfo[count] = {split(split(line,':')[2],']')[1],i,0}
    count = count + 1
   end
  end

  for i,x in ipairs(dataInfo) do
   classToken = x[1]
   startLine = x[2]+1
   if i ==#dataInfo then
    endLine = #data
   else
    endLine = dataInfo[i+1][2]-1
   end
   classes[classToken] = {}
   class = classes[classToken]
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    if test == '[NAME' then
     class.Name = split(split(data[j],':')[2],']')[1]
    elseif test == '[LEVELS' then
     class.Levels = split(split(data[j],':')[2],']')[1]
    end
    if class.Name and class.Levels then break end
   end
   class.Spells = {}
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if test == '[AUTO_UPGRADE' then
     class.AutoUpgrade = array[2]
    elseif test == '[EXP' then
     class.Experience = {}
     local temptable = {select(2,table.unpack(array))}
     strint = '1'
     for _,v in pairs(temptable) do
      class.Experience[strint] = v
      strint = tostring(strint+1)
     end
     if tonumber(strint)-1 < tonumber(class.Levels) then
      print('Incorrect amount of experience numbers, must be equal to number of levels. Assuming linear progression for next experience level')
      while (tonumber(strint)-1) < tonumber(class.Levels) do
--    print('Incorrect amount of experience numbers, must be equal to number of levels. Assuming linear progression for next experience level')
       class.Experience[strint] = tostring(2*tonumber(class.Experience[tostring(strint-1)])-tonumber(class.Experience[tostring(strint-2)]))
       strint = tostring(tonumber(strint)+1)
      end
     end
    elseif test == '[REQUIREMENT_CLASS' then
     class.RequiredClass = class.RequiredClass or {}
     class.RequiredClass[array[2]] = array[3]
    elseif test == '[FORBIDDEN_CLASS' then
     class.ForbiddenClass = class.ForbiddenClass or {}
     class.ForbiddenClass[array[2]] = array[3]
    elseif test == '[REQUIREMENT_SKILL' then
     class.RequiredSkill = class.RequiredSkill or {}
     class.RequiredSkill[array[2]] = array[3]
    elseif test == '[REQUIREMENT_TRAIT' then
     class.RequiredTrait = class.RequiredTrait or {}
     class.RequiredTrait[array[2]] = array[3]
    elseif test == '[REQUIREMENT_COUNTER' then
        class.RequiredCounter = class.RequiredCounter or {}
     class.RequiredCounter[array[2]] = array[3]
    elseif test == '[REQUIREMENT_PHYS' then
     class.RequiredPhysical = class.RequiredPhysical or {}
     class.RequiredPhysical[array[2]] = array[3]
    elseif test == '[REQUIREMENT_MENT' then
     class.RequiredMental = class.RequiredMental or {}
     class.RequiredMental[array[2]] = array[3]
    elseif test == '[REQUIREMENT_CREATURE' then
     class.RequiredCreature = class.RequiredCreature or {}
     class.RequiredCreature[array[2]] = array[3]
    elseif test == '[LEVELING_BONUS' then
     class.LevelBonus = class.LevelBonus or {}
     if array[2] == 'PHYSICAL' then
      class.LevelBonus.Physical = class.LevelBonus.Physical or {}
      class.LevelBonus.Physical[array[3]] = array[4]
     elseif array[2] == 'MENTAL' then
      class.LevelBonus.Mental = class.LevelBonus.Mental or {}
      class.LevelBonus.Mental[array[3]] = array[4]
     elseif array[2] == 'SKILL' then
      class.LevelBonus.Skill = class.LevelBonus.Skill or {}
      class.LevelBonus.Skill[array[3]] = array[4]
     elseif array[2] == 'TRAIT' then
      class.LevelBonus.Trait = class.LevelBonus.Trait or {}
      class.LevelBonus.Trait[array[3]] = array[4]
     end
    elseif test == '[BONUS_PHYS' then
     class.BonusPhysical = class.BonusPhysical or {}
     local temptable = {select(3,table.unpack(array))}
     local strint = '1'
     class.BonusPhysical[array[2]] = {}
     for _,v in pairs(temptable) do
      class.BonusPhysical[array[2]][strint] = v
      strint = tostring(strint+1)
     end
     if tonumber(strint)-1 < tonumber(class.Levels)+1 then
--    print('Incorrect amount of physical bonus numbers, must be equal to number of levels + 1. Assuming previous physical bonus')
      while tonumber(strint)-1 < tonumber(class.Levels)+1 do
       class.BonusPhysical[array[2]][strint] = class.BonusPhysical[array[2]][tostring(strint-1)]
       strint = tostring(strint+1)
      end
     end
    elseif test == '[BONUS_TRAIT' then
     class.BonusTrait = class.BonusTrait or {}
     local temptable = {select(3,table.unpack(array))}
     local strint = '1'
     class.BonusTrait[array[2]] = {}
     for _,v in pairs(temptable) do
      class.BonusTrait[array[2]][strint] = v
      strint = tostring(strint+1)
     end
     if tonumber(strint)-1 < tonumber(class.Levels)+1 then
--    print('Incorrect amount of trait bonus numbers, must be equal to number of levels + 1. Assuming previous trait bonus')
      while tonumber(strint)-1 < tonumber(class.Levels)+1 do
       class.BonusTrait[array[2]][strint] = class.BonusTrait[array[2]][tostring(strint-1)]
       strint = tostring(strint+1)
      end
     end
    elseif test == '[BONUS_SKILL' then
     class.BonusSkill = class.BonusSkill or {}
     local temptable = {select(3,table.unpack(array))}
     local strint = '1'
     class.BonusSkill[array[2]] = {}
     for _,v in pairs(temptable) do
      class.BonusSkill[array[2]][strint] = v
      strint = tostring(strint+1)
     end
     if tonumber(strint)-1 < tonumber(class.Levels)+1 then
--    print('Incorrect amount of skill bonus numbers, must be equal to number of levels + 1. Assuming previous skill bonus')
      while tonumber(strint)-1 < tonumber(class.Levels)+1 do
       class.BonusSkill[array[2]][strint] = class.BonusSkill[array[2]][tostring(strint-1)]
       strint = tostring(strint+1)
      end
     end
    elseif test == '[BONUS_MENT' then
     class.BonusMental = class.BonusMental or {}
     local temptable = {select(3,table.unpack(array))}
     local strint = '1'
     class.BonusMental[array[2]] = {}
     for _,v in pairs(temptable) do
      class.BonusMental[array[2]][strint] = v
      strint = tostring(strint+1)
     end
     if tonumber(strint)-1 < tonumber(class.Levels)+1 then
--    print('Incorrect amount of mental bonus numbers, must be equal to number of levels + 1. Assuming previous mental bonus')
      while tonumber(strint)-1 < tonumber(class.Levels)+1 do
       class.BonusMental[array[2]][strint] = class.BonusMental[array[2]][tostring(strint-1)]
       strint = tostring(strint+1)
      end
     end
    elseif test == '[SPELL' then
     spell = array[2]
     if not spellCheck then
      persistTable.GlobalTable.roses.SpellTable[spell] = {}
      spellTable = persistTable.GlobalTable.roses.SpellTable[spell]
      spellTable.Cost = '0'
     else
      spellTable = {}
      spellTable.Cost = '0'
     end
     class.Spells[spell] = {}
     spells = class.Spells[spell]
     spells.RequiredLevel = array[3]
     if spells.RequiredLevel == 'AUTO' then
      spells.RequiredLevel = '0'
      spells.AutoLearn = 'true'
     end
    elseif test == '[SPELL_REQUIRE_PHYS' then
     spellTable.RequiredPhysical = spellTable.RequiredPhysical or {}
     spellTable.RequiredPhysical[array[2]] = array[3]
    elseif test == '[SPELL_REQUIRE_MENT' then
     spellTable.RequiredMental = spellTable.RequiredMental or {}
     spellTable.RequiredMental[array[2]] = array[3]
    elseif test == '[SPELL_FORBIDDEN_SPELL' then
     spellTable.ForbiddenSpell = spellTable.ForbiddenSpell or {}
     spellTable.ForbiddenSpell[array[2]] = array[2]
    elseif test == '[SPELL_FORBIDDEN_CLASS' then
     spellTable.ForbiddenClass = spellTable.ForbiddenClass or {}
     spellTable.ForbiddenClass[array[2]] = array[3]
    elseif test == '[SPELL_UPGRADE' then
     spellTable.Upgrade = array[2]
    elseif test == '[SPELL_COST' then
     spellTable.Cost = array[2]
    elseif test == '[SPELL_EXP_GAIN' then
     spellTable.ExperienceGain = array[2]
    elseif test == '[SPELL_AUTO_LEARN]' then
     spells.AutoLearn = 'true'
    end
   end
  end
 end
 return true
end

function makeEntityTable(entity)

 if tonumber(entity) then
  civid = tonumber(entity)
 else
  civid = entity.id
 end
 key = tostring(civid)
 entity = df.global.world.entities.all[civid]

 local persistTable = require 'persist-table'
 local key = tostring(entity.id)
 local entity = entity.entity_raw.code
 local civilizations = persistTable.GlobalTable.roses.CivilizationTable
 local entityTable = persistTable.GlobalTable.roses.EntityTable
 if entityTable[key] then
  return
 else
  entityTable[key] = {}
  entityTable = entityTable[key]
  entityTable.Kills = {}
  entityTable.Deaths = {}
  entityTable.Trades = '0'
  entityTable.Sieges = '0'
  if civilizations then
   if civilizations[entity] then
    entityTable.Civilization = {}
    entityTable.Civilization.Name = entity
    entityTable.Civilization.Level = '0'
    entityTable.Civilization.CurrentMethod = civilizations[entity].LevelMethod
    entityTable.Civilization.CurrentPercent = civilizations[entity].LevelPercent
    if civilizations[entity].Level then
     if civilizations[entity].Level['0'] then
      for _,mtype in pairs(civilizations[entity].Level['0'].Remove._children) do
       local depth1 = civilizations[entity].Level['0'].Remove[mtype]
       for _,stype in pairs(depth1._children) do
        local depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         local sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,-1,true)
        end
       end
      end
      for _,mtype in pairs(civilizations[entity].Level['0'].Add._children) do
       local depth1 = civilizations[entity].Level['0'].Add[mtype]
       for _,stype in pairs(depth1._children) do
        local depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         local sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,1,true)
        end
       end
      end
     end
    end
   end
  end
 end
end

function makeEventTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.EventTable = {}

 print('Searching for event files')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/Events/','/raw/scripts/files/'}
 local n = 1
 for location in ipairs(locations) do
  local path = dir..location
--  print('Looking in '..location)
  for _,fname in pairs(dfhack.internal.getDir(path)) do
   if (split(fname,'_')[1] == 'events' or fname == 'events.txt') then
    files[n] = path..fname
    n = n + 1
   end
  end
 end

 if #files >= 1 then
--  print('Event files found:')
--  printall(files)
 else
--  print('No Event files found')
  return false
 end

 events = persistTable.GlobalTable.roses.EventTable
 for _,file in ipairs(files) do

  local data = {}
  local iofile = io.open(file,"r")
  local lineCount = 1
  while true do
   local line = iofile:read("*line")
   if line == nil then break end
   data[lineCount] = line
   lineCount = lineCount + 1
  end
  iofile:close()

  local dataInfo = {}
  local count = 1
  for i,line in ipairs(data) do
   if split(line,':')[1] == '[EVENT' then
    dataInfo[count] = {split(split(line,':')[2],']')[1],i,0}
    count = count + 1
   end
  end

 for i,x in ipairs(dataInfo) do
  eventToken = x[1]
  startLine = x[2]+1
  if i ==#dataInfo then
   endLine = #data
  else
   endLine = dataInfo[i+1][2]-1
  end
  events[eventToken] = {}
  event = events[eventToken]
  event.Effect = {}
  event.Required = {}
  event.Delay = {}
  numberOfEffects = 0
  for j = startLine,endLine,1 do
   test = data[j]:gsub("%s+","")
   test = split(test,':')[1]
   array = split(data[j],':')
   for k = 1, #array, 1 do
    array[k] = split(array[k],']')[1]
   end
   if test == '[NAME' then
    event.Name = array[2]
   elseif test == '[CHECK' then
    event.Check = array[2]
   elseif test == '[CHANCE' then
    event.Chance = array[2]
   elseif test == '[DELAY' then
    event.Delay[array[2]] = array[3]
   elseif test == '[REQUIREMENT' then
    if array[2] == 'COUNTER' then
     event.Required.Counter = event.Required.Counter or {}
     event.Required.Counter[array[3]] = array[4]
    elseif array[2] == 'TIME' then
     event.Required.Time = array[3]
    elseif array[2] == 'POPULATION' then
     event.Required.Population = array[3]
    elseif array[2] == 'WEALTH' then
     event.Required.Wealth = event.Required.Wealth or {}
     event.Required.Wealth[array[3]] = array[4]
    elseif array[2] == 'BUILDING' then
     event.Required.Building = event.Required.Building or {}
     event.Required.Building[array[3]] = array[4]
    elseif array[2] == 'SKILL' then
     event.Required.Skill = event.Required.Skill or {}
     event.Required.Skill[array[3]] = array[4]
    elseif array[2] == 'CLASS' then
     event.Required.Class = event.Required.Class or {}
     event.Required.Class[array[3]] = array[4]
    elseif array[2] == 'KILLS' then
     event.Required.Kills = event.Required.Kills or {}
     event.Required.Kills[array[3]] = array[4]
    elseif array[2] == 'DEATHS' then
     event.Required.Deaths = event.Required.Deaths or {}
     event.Required.Deaths[array[3]] = array[4]
    elseif array[2] == 'TRADES' then
     event.Required.Trades = event.Required.Trades or {}
     event.Required.Trades[array[3]] = array[4]
    elseif array[2] == 'SIEGES' then
     event.Required.Sieges = event.Required.Sieges or {}
     event.Required.Sieges[array[3]] = array[4]
    end
   elseif test == '[EFFECT' then
    number = array[2]
    numberOfEffects = numberOfEffects + 1
    event.Effect[number] = {}
    effect = event.Effect[number]
    effect.Arguments = '0'
    effect.Argument = {}
    effect.Required = {}
    effect.Script = {}
    effect.Delay = {}
    effect.Scripts = '0'
   elseif test == '[EFFECT_NAME' then
    effect.Name = array[2]
   elseif test == '[EFFECT_CHANCE' then
    effect.Chance = array[2]
   elseif test == '[EFFECT_CONTINGENT_ON' then
    effect.Contingent = array[2]
   elseif test == '[EFFECT_DELAY' then
    effect.Delay[array[2]] = array[3]
   elseif test == '[EFFECT_REQUIREMENT' then
    if array[2] == 'COUNTER' then
     effect.Required.Counter = effect.Required.Counter or {}
     effect.Required.Counter[array[3]] = array[4]
    elseif array[2] == 'TIME' then
     effect.Required.Time = array[3]
    elseif array[2] == 'POPULATION' then
     effect.Required.Population = array[3]
    elseif array[2] == 'WEALTH' then
     effect.Required.Wealth = effect.Required.Wealth or {}
     effect.Required.Wealth[array[3]] = array[4]
    elseif array[2] == 'BUILDING' then
     effect.Required.Building = effect.Required.Building or {}
     effect.Required.Building[array[3]] = array[4]
    elseif array[2] == 'SKILL' then
     effect.Required.Skill = effect.Required.Skill or {}
     effect.Required.Skill[array[3]] = array[4]
    elseif array[2] == 'CLASS' then
     effect.Required.Class = effect.Required.Class or {}
     effect.Required.Class[array[3]] = array[4]
    elseif array[2] == 'KILLS' then
     effect.Required.Kills = effect.Required.Kills or {}
     effect.Required.Kills[array[3]] = array[4]
    elseif array[2] == 'DEATHS' then
     effect.Required.Deaths = effect.Required.Deaths or {}
     effect.Required.Deaths[array[3]] = array[4]
    elseif array[2] == 'TRADES' then
     effect.Required.Trades = effect.Required.Trades or {}
     effect.Required.Trades[array[3]] = array[4]
    elseif array[2] == 'SIEGES' then
     effect.Required.Sieges = effect.Required.Sieges or {}
     effect.Required.Sieges[array[3]] = array[4]
    end
   elseif test == '[EFFECT_UNIT' then
    effect.Unit = {}
    local temptable = {select(2,table.unpack(array))}
    strint = '1'
    for _,v in pairs(temptable) do
     effect.Unit[strint] = v
     strint = tostring(strint+1)
    end
   elseif test == '[EFFECT_LOCATION' then
    effect.Location = {}
    local temptable = {select(2,table.unpack(array))}
    strint = '1'
    for _,v in pairs(temptable) do
     effect.Location[strint] = v
     strint = tostring(strint+1)
    end
   elseif test == '[EFFECT_BUILDING' then
    effect.Building = {}
    local temptable = {select(2,table.unpack(array))}
    strint = '1'
    for _,v in pairs(temptable) do
     effect.Building[strint] = v
     strint = tostring(strint+1)
    end
   elseif test == '[EFFECT_ITEM' then
    effect.Item = {}
    local temptable = {select(2,table.unpack(array))}
    strint = '1'
    for _,v in pairs(temptable) do
     effect.Item[strint] = v
     strint = tostring(strint+1)
    end
   elseif test == '[EFFECT_ARGUMENT' then
    argnumber = array[2]
    effect.Arguments = tostring(effect.Arguments + 1)
    effect.Argument[argnumber] = {}
    argument = effect.Argument[argnumber]
   elseif test == '[ARGUMENT_WEIGHTING' then
    argument.Weighting = array[2]
   elseif test == '[ARGUMENT_EQUATION' then
    argument.Equation = array[2]
   elseif test == '[ARGUMENT_VARIABLE' then
    argument.Variable = array[2]
   elseif test == '[EFFECT_SCRIPT' then
    effect.Scripts = tostring(effect.Scripts + 1)
    effect.Script[effect.Scripts] = array[2]
   end
  end
  event.Effects = tostring(numberOfEffects)
 end
 end
end

function makeFeatTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.FeatTable = {}
 
 print('Searching for feat files')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/Classes/'}
 local n = 1
 for _,location in ipairs(locations) do
  local path = dir..location
--  print('Looking in '..location)
  for _,fname in pairs(dfhack.internal.getDir(path)) do
   if (split(fname,'_')[1] == 'feats' or fname == 'feats.txt') then
    files[n] = path..fname
    n = n + 1
   end
  end
 end

 if #files >= 1 then
--  print('Feat files found:')
--  printall(files)
 else
--  print('No feat files found')
  return false
 end

 feats = persistTable.GlobalTable.roses.FeatTable
 for _,file in ipairs(files) do

  local data = {}
  local iofile = io.open(file,"r")
  local lineCount = 1
  while true do
   local line = iofile:read("*line")
   if line == nil then break end
   data[lineCount] = line
   lineCount = lineCount + 1
  end
  iofile:close()

  local dataInfo = {}
  local count = 1
  for i,line in ipairs(data) do
   if split(line,':')[1] == '[FEAT' then
    dataInfo[count] = {split(split(line,':')[2],']')[1],i,0}
    count = count + 1
   end
  end

 for i,x in ipairs(dataInfo) do
   featToken = x[1]
   startLine = x[2]+1
   if i ==#dataInfo then
    endLine = #data
   else
    endLine = dataInfo[i+1][2]-1
   end
   feats[featToken] = {}
   feat = feats[featToken]
   feat.Cost = '1'
   feat.Effect = {}
   num = 0
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if test == '[NAME' then
     feat.Name = array[2]
    elseif test == '[DESCRIPTION' then
     feat.Description = array[2]
    elseif test == '[REQUIRED_CLASS' then
     feat.RequiredClass = feat.RequiredClass or {}
     feat.RequiredClass[array[2]] = array[3]
    elseif test == '[FORBIDDEN_CLASS' then
     feat.ForbiddenClass = feat.ForbiddenClass or {}
     feat.ForbiddenClass[array[2]] = array[3]
    elseif test == '[REQUIRED_FEAT' then
     feat.RequiredFeat = feat.RequiredFeat or {}
     feat.RequiredFeat[array[2]] = array[2]
    elseif test == '[FORBIDDEN_FEAT' then
     feat.ForbiddenFeat = feat.ForbiddenFeat or {}
     feat.ForbiddenFeat[array[2]] = array[2]
    elseif test == '[COST' then
     feat.Cost = array[2]
    elseif test == '[EFFECT' then
     feat.Effect[num] = array[2]
     num = num + 1
    end
   end
   feat.Effects = tostring(num)
  end
 end
 return true
end

function makeGlobalTable()
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.GlobalTable = {}
 persistTable.GlobalTable.roses.GlobalTable.Kills = {}
 persistTable.GlobalTable.roses.GlobalTable.Deaths = {}
 persistTable.GlobalTable.roses.GlobalTable.Trades = {}
 persistTable.GlobalTable.roses.GlobalTable.Sieges = {}
end

function makeItemTable(item)
 if tonumber(item) then
  item = df.item.find(tonumber(item))
 end
 itemID = item.id

 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.ItemTable[tostring(itemID)] = {}
 itemTable = persistTable.GlobalTable.roses.ItemTable[tostring(itemID)]

 itemTable.Material = {}
 itemTable.Material.Base = dfhack.matinfo.getToken(item.mat_type,item.mat_index)
 itemTable.Material.Current = dfhack.matinfo.getToken(item.mat_type,item.mat_index)
 itemTable.Material.StatusEffects = {}

 itemTable.Quality = {}
 itemTable.Quality.Base = item.quality
 itemTable.Quality.Current = item.quality
 itemTable.Quality.StatusEffects = {}

 itemTable.Subtype = {}
 itemTable.Subtype.Base = dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id
 itemTable.Subtype.Current = dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id
 itemTable.Subtype.StatusEffects = {}

 itemTable.Stats = {}
 itemTable.Stats.Kills = '0'
end

function makeSpellTable()
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.SpellTable = {}
 
 print('Searching for stand alone spell files')
 local files = {}
 local dir = dfhack.getDFPath()
 local locations = {'/raw/objects/','/raw/systems/Classes/'}
 local n = 1
 for _,location in ipairs(locations) do
  local path = dir..location
--  print('Looking in '..location)
  for _,fname in pairs(dfhack.internal.getDir(path)) do
   if (split(fname,'_')[1] == 'spells' or fname == 'spells.txt') then
    files[n] = path..fname
    n = n + 1
   end
  end
 end

 if #files >= 1 then
--  print('Spell files found:')
--  printall(files)
 else
--  print('No Spell files found')
  return false
 end

 spells = persistTable.GlobalTable.roses.SpellTable
 for _,file in ipairs(files) do

  local data = {}
  local iofile = io.open(file,"r")
  local lineCount = 1
  while true do
   local line = iofile:read("*line")
   if line == nil then break end
   data[lineCount] = line
   lineCount = lineCount + 1
  end
  iofile:close()

  local dataInfo = {}
  local count = 1
  for i,line in ipairs(data) do
   if split(line,':')[1] == '[SPELL' then
    dataInfo[count] = {split(split(line,':')[2],']')[1],i,0}
    count = count + 1
   end
  end

 for i,x in ipairs(dataInfo) do
   spellToken = x[1]
   startLine = x[2]+1
   if i ==#dataInfo then
    endLine = #data
   else
    endLine = dataInfo[i+1][2]-1
   end
   spells[spellToken] = {}
   spell = spells[spellToken]
   spell.Cost = '0'
   spell.Script = {}
   scriptNum = 0
   for j = startLine,endLine,1 do
    test = data[j]:gsub("%s+","")
    test = split(test,':')[1]
    array = split(data[j],':')
    for k = 1, #array, 1 do
     array[k] = split(array[k],']')[1]
    end
    if test == '[NAME' then
     spell.Name = array[2]
    elseif test == '[DESCRIPTION' then
     spell.Description = array[2]
    elseif test == '[SPHERE' then
     spell.Sphere = array[2]
    elseif test == '[SCHOOL' then
     spell.School = array[2]
    elseif test == '[DISCIPLINE' then
     spell.Discipline = array[2]
    elseif test == '[SUBDISCIPLINE' then
     spell.SubDiscipline = array[2]
    elseif test == '[LEVEL' then
     spell.Level = array[2]
    elseif test == '[EFFECT' then
     spell.Effect = array[2]
    elseif test == '[ANNOUNCEMENT' then
     spell.Announcement = array[2]
    elseif test == '[SCRIPT' then
     spell.Script[scriptNum] = array[2]
     scriptNum = scriptNum + 1
    elseif test == '[EXP_GAIN' then
     spell.ExperienceGain = array[2]
    elseif test == '[SKILL_GAIN' then
     spell.SkillGain = spell.SkillGain or {}
     spell.SkillGain[array[2]] = array[3]
    elseif test == '[UPGRADE' then
     spell.Upgrade = array[2]
    elseif test == '[COST' then
     spell.Cost = array[2]
    elseif test == '[CAST_TIME' then
     spell.CastTime = array[2]
    elseif test == '[CAST_EXHAUSTION' then
     spell.CastExhaustion = array[2]
    elseif test == '[REQUIREMENT_PHYS' then
     spell.RequiredPhysical = spell.RequiredPhysical or {}
     spell.RequiredPhysical[array[2]] = array[3]
    elseif test == '[REQUIREMENT_MENT' then
     spell.RequiredMental = spell.RequiredMental or {}
     spell.RequiredMental[array[2]] = array[3]
    elseif test == '[FORBIDDEN_CLASS' then
     spell.ForbiddenClass = spell.ForbiddenClass or {}
     spell.ForbiddenClass[array[2]] = array[3]
    elseif test == '[FORBIDDEN_SPELL' then
     spell.ForbiddenSpell = spell.ForbiddenSpell or {}
     spell.ForbiddenSpell[array[2]] = array[3]
    end
   end
  end
 end
 return true
end

function makeUnitTable(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)] = {}
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 
 unitTable.SyndromeTrack = {}
 
 unitTable.Attributes = {}

 unitTable.Skills = {}

 unitTable.Traits = {}

 unitTable.Resistances = {}

 unitTable.General = {}

 unitTable.Stats = {}
 unitTable.Stats.Kills = '0'
 unitTable.Stats.Deaths = '0'

 unitTable.Classes = {}
 if persistTable.GlobalTable.roses.ClassTable then
  unitTable.Classes.Current = {}
  unitTable.Classes.Current.Name = 'NONE'
  unitTable.Classes.Current.TotalExp = tostring(0)
  unitTable.Classes.Current.FeatPoints = tostring(0)
 end

 unitTable.Spells = {}
 if persistTable.GlobalTable.roses.SpellTable then 
  unitTable.Spells.Active = {}
 end

 unitTable.Feats = {}

 unitTable.Stats = {}
end

function makeUnitTableAttribute(unit,attribute) --Changes needed for the Enhanced System
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.Attributes[attribute] = {}
 if df.physical_attribute_type[attribute] then
  unitTable.Attributes[attribute].Base = tostring(unit.body.physical_attrs[attribute].value)
 elseif df.mental_attribute_type[attribute] then
  unitTable.Attributes[attribute].Base = tostring(unit.status.current_soul.mental_attrs[attribute].value)
 elseif persistTable.GlobalTable.roses.BaseTable.CustomAttributes[attribute] then
  unitTable.Attributes[attribute].Base = tostring(0) --Replace with correct value when Enhanced System is created
 end
 unitTable.Attributes[attribute].Change = tostring(0)
 unitTable.Attributes[attribute].Class = tostring(0)
 unitTable.Attributes[attribute].Item = tostring(0)
 unitTable.Attributes[attribute].StatusEffects = {}
end

function makeUnitTableSkill(unit,skill) --Changes needed for the Enhanced System
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.Skills[skill] = {}
 if df.job_skill[skill] then
  unitTable.Skills[skill].Base = tostring(dfhack.units.getEffectiveSkill(unit,df.job_skill[skill]))
 else
  unitTable.Skills[skill].Base = tostring(0) --Replace with correct value when Enhanced System is created
 end
 unitTable.Skills[skill].Change = tostring(0)
 unitTable.Skills[skill].Class = tostring(0)
 unitTable.Skills[skill].Item = tostring(0)
 unitTable.Skills[skill].StatusEffects = {} 
end

function makeUnitTableTrait(unit,trait)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.Traits[trait] = {}
 unitTable.Traits[trait].Base = tostring(unit.status.current_soul.personality.traits[trait])
 unitTable.Traits[trait].Change = tostring(0)
 unitTable.Traits[trait].Class = tostring(0)
 unitTable.Traits[trait].Item = tostring(0)
 unitTable.Traits[trait].StatusEffects = {}
end

function makeUnitTableResistance(unit,resistance)  --Changes needed for the Enhanced System
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

dfhack.script_environment('functions/misc').changeCounter('UnitTable:!UNIT:Resistances:'..resistance..':Base',0,unit.id) -- Put creatures base resistance here from Enhanced System
dfhack.script_environment('functions/misc').changeCounter('UnitTable:!UNIT:Resistances:'..resistance..':Change',0,unit.id)
dfhack.script_environment('functions/misc').changeCounter('UnitTable:!UNIT:Resistances:'..resistance..':Class',0,unit.id)
dfhack.script_environment('functions/misc').changeCounter('UnitTable:!UNIT:Resistances:'..resistance..':Item',0,unit.id)
dfhack.script_environment('functions/misc').changeCounter('UnitTable:!UNIT:Resistances:'..resistance..':StatusEffects',{},unit.id)
end

function makeUnitTableClass(unit,class)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.Classes[class] = {}
 unitTable.Classes[class].Level = tostring(0)
 unitTable.Classes[class].Experience = tostring(0)
 unitTable.Classes[class].SkillExp = tostring(0)
end

function makeUnitTableSpell(unit,spell)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.Spells[spell] = '0'
end

function makeUnitTableSide(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.General.Side = {}
 unitTable.General.Side.StatusEffects = {}
end

function makeUnitTableStat(unit,stat)  --Changes needed for the Enhanced System
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.Stats[stat] = {}
 unitTable.Stats[stat].Base = '0' -- Put creatures base stats here from Enhanced System
 unitTable.Stats[stat].Change = '0'
 unitTable.Stats[stat].Class = '0'
 unitTable.Stats[stat].Item = '0'
 unitTable.Stats[stat].StatusEffects = {}
end

function makeUnitTableTransform(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.General.Transform = {}
 unitTable.General.Transform.Race = {}
 unitTable.General.Transform.Race.Base = tostring(unit.race)
 unitTable.General.Transform.Race.Current = tostring(unit.race)
 unitTable.General.Transform.Caste = {}
 unitTable.General.Transform.Caste.Base = tostring(unit.caste)
 unitTable.General.Transform.Caste.Current = tostring(unit.caste)
 unitTable.General.Transform.StatusEffects = {}
end

function makeUnitTableSummon(unit)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 
 local persistTable = require 'persist-table'
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
 unitTable.General.Summoned = {}
 unitTable.General.Summoned.Creator = tostring(-1)
 unitTable.General.Summoned.End = tostring(-1)
 unitTable.General.Summoned.Syndrome = tostring(-1)
end
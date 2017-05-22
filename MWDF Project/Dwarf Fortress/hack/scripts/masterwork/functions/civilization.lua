-- Functions to be used with the Civilization System, v42.06a
--[[
 changeLevel(entity,amount,verbose) - Changes the level of the entity
 changeStanding(civ1,civ2,amount,verbose) - Changes the diplomacy standing of the two entities
 checkEntity(id,method,verbose) - Checks if the entity has leveled up
 checkRequirements(entityID,verbose) - Called by checkEntity, returns true if the entity meets the conditions for leveling up
 queueCheck(id,method,verbose) - Sets up the next time check to see if an entity has leveled up
]]
function changeLevel(entity,amount,verbose)
 if tonumber(entity) then civ = df.global.world.entities.all[civid] end
 key = tostring(civ.id)

 local persistTable = require 'persist-table'
 entityTable = persistTable.GlobalTable.roses.EntityTable
 if not entityTable[key] then
  dfhack.script_environment('functions/tables').makeEntityTable(key)
 end
 entityTable = persistTable.GlobalTable.roses.EntityTable[key]
 entity = df.global.world.entities.all[civid].entity_raw.code
 civilizationTable = persistTable.GlobalTable.roses.CivilizationTable[entity]
 if civilizationTable then
  if civilizationTable.Level then
   currentLevel = tonumber(entityTable.Civilization.Level)
   nextLevel = currentLevel + amount
   if nextLevel > tonumber(civilizationTable.Levels) then nextLevel = tonumber(civilizationTable.Levels) end
   if nextLevel < 0 then nextLevel = 0 end
   if amount > 0 then
    for i = currentLevel+1,nextLevel,1 do
     if civilizationTable.Level[tostring(i)] then
      for _,mtype in pairs(civilizationTable.Level[tostring(i)].Remove._children) do
       depth1 = civilizationTable.Level[tostring(i)].Remove[mtype]
       for _,stype in pairs(depth1._children) do
        depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,-1,verbose)
        end
       end
      end
      for _,mtype in pairs(civilizationTable.Level[tostring(i)].Add._children) do
       depth1 = civilizationTable.Level[tostring(i)].Add[mtype]
       for _,stype in pairs(depth1._children) do
        depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,1,verbose)
        end
       end
      end
      for _,position in pairs(civilizationTable.Level[tostring(i)].RemovePosition._children) do
       dfhack.script_environment('functions/entity').changeNoble(key,position,-1,verbose)
      end
      for _,position in pairs(civilizationTable.Level[tostring(i)].AddPosition._children) do
       dfhack.script_environment('functions/entity').changeNoble(key,position,1,verbose)
      end
      if civilizationTable.Level[tostring(i)].LevelMethod then
       entityTable.Civilization.CurrentMethod = civilizationTable.Level[tostring(i)].LevelMethod
       entityTable.Civilization.CurrentPercent = civilizationTable.Level[tostring(i)].Levelchance
      end
     end
    end
   elseif amount <0 then
    for i = currentLevel,nextLevel,-1 do
     if civilizationTable.Level[tostring(i)] then
      for _,mtype in pairs(civilizationTable.Level[tostring(i)].Remove._children) do
       depth1 = civilizationTable.Level[tostring(i)].Remove[mtype]
       for _,stype in pairs(depth1._children) do
        depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,1,verbose)
        end
       end
      end
      for _,mtype in pairs(civilizationTable.Level[tostring(i)].Add._children) do
       depth1 = civilizationTable.Level[tostring(i)].Add[mtype]
       for _,stype in pairs(depth1._children) do
        depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,-1,verbose)
        end
       end
      end
      for _,position in pairs(civilizationTable.Level[tostring(i)].RemovePosition._children) do
       dfhack.script_environment('functions/entity').changeNoble(key,position,1,verbose)
      end
      for _,position in pairs(civilizationTable.Level[tostring(i)].AddPosition._children) do
       dfhack.script_environment('functions/entity').changeNoble(key,position,-1,verbose)
      end
      if civilizationTable.Level[tostring(i)].LevelMethod then
       entityTable.Civilization.CurrentMethod = civilizationTable.Level[tostring(i)].LevelMethod
       entityTable.Civilization.CurrentPercent = civilizationTable.Level[tostring(i)].Levelchance
      end
     end
    end
   end
  end
 end
end

function changeStanding(civ1,civ2,amount,verbose)
 local persistTable = require 'persist-table'
 diplomacyTable = persistTable.GlobalTable.roses.DiplomacyTable
 if diplomacyTable then
  if diplomacyTable[civ1] then
   if diplomacyTable[civ1][civ2] then
    diplomacyTable[civ1][civ2] = tostring(tonumber(diplomacyTable[civ1][civ2]) + amount)
    diplomacyTable[civ2][civ1] = tostring(tonumber(diplomacyTable[civ2][civ1]) + amount)
   end
  end
 end
end

function checkEntity(id,method,verbose)
 local persistTable = require 'persist-table'
 civilizationTable = persistTable.GlobalTable.roses.EntityTable[id].Civilization
 leveled = checkRequirements(id,verbose)
 if leveled then
  changeLevel(id,1,verbose)
  if verbose then print('Civilization leveled up') end
  method = civilizationTable.CurrentMethod
 end
 queueCheck(id,method,verbose)
end

function checkRequirements(entityID,verbose)
 local persistTable = require 'persist-table'
 local utils = require 'utils'
 local split = utils.split_string
 entity = persistTable.GlobalTable.roses.EntityTable[entityID]
 if not entity then return false end
 if entity.Civilization then
  level = entity.Civilization.Level
  name = entity.Civilization.Name
  if not persistTable.GlobalTable.roses.CivilizationTable[name] then
   return false
  else
   civilization = persistTable.GlobalTable.roses.CivilizationTable[name]
  end
  if not civilzation.Level[level] then return false end
 end
 
 check = civilization.Level[level].Required
 if not check then return false end

-- Check for chance occurance
 local rand = dfhack.random.new()
 local rnum = rand:random(100)
 if rnum > chance then
  return false
 end
-- Check for amount of time passed
 if check.Time then
  local x = tonumber(check.Time)
  if df.global.ui.fortress_age < x then
   return false
  end
 end
-- Check for fortress wealth
 if check.Wealth then
  for _,wtype in pairs(check.Wealth._children) do
   local amount = tonumber(check.Wealth[wtype])
   if df.global.ui.tasks.wealth[string.lower(wtype)] then
    if df.global.ui.tasks.wealth[string.lower(wtype)] < amount then
     return false
    end
   end
  end
 end
-- Check for fortress population
 if check.Population then
  local population = 0
  local populations = df.global.world.entities.all[entityID]
  for _,n in pairs(populations) do
   population = population + df.global.world.entity_populations[n].counts
  end
  local x = tonumber(check.Population)
  if population < x then
   return false
  end
 end
-- Check for season
 season = {SPRING=0,SUMMER=1,FALL=2,WINTER=3}
 if check.Season then
  if not season[check.Season] == df.global.cur_season then
   return false
  end
 end
-- Check for trees cut
 if check.TreeCut then
  local x = check.TreeCut
  if df.global.ui.trees_removed < tonumber(x) then
   return false
  end
 end
-- Check for fortress rank
 if check.Rank then
  local x = tonumber(check.Rank)
  if df.global.ui.fortress_rank < x then
   return false
  end
 end
-- Check for progress
 if check.ProgressPopulation then
  local x = tonumber(check.ProgressPopulation)
  if df.global.ui.progress_population < x then
   return false
  end 
 end
 if check.ProgressTrade then
  local x = tonumber(check.ProgressTrade)
  if df.global.ui.progress_trade < x then
   return false
  end 
 end
 if check.ProgressProduction then
  local x = tonumber(check.ProgressProduction)
  if df.global.ui.progress_production < x then
   return false
  end 
 end
-- Check for artifacts
 if check.NumArtifacts then
  local x = tonumber(check.NumArtifacts)
  if df.global.ui.tasks.num_artifacts < x then
   return false
  end 
 end
-- Check for total deaths
 if check.TotDeaths then
  local x = tonumber(check.TotDeaths)
  if df.global.ui.tasks.total_deaths < x then
   return false
  end 
 end
-- Check for insanities
 if check.TotInsanities then
  local x = tonumber(check.TotInsanities)
  if df.global.ui.tasks.total_insanities < x then
   return false
  end 
 end
-- Check for executions
 if check.TotExecutions then
  local x = tonumber(check.TotExecutions)
  if df.global.ui.tasks.total_executions < x then
   return false
  end 
 end 
-- Check for migrant waves
 if check.MigrantWaves then
  local x = tonumber(check.MigrantWaves)
  if df.global.ui.tasks.migrant_wave_idx < x then
   return false
  end 
 end
-- Check for counter
 if check.CounterMax then
  for _,counter in pairs(check.CounterMax._children) do
   a1 = tonumber(check.CounterMax[counter])
   a2 = tonumber(dfhack.script_environment('functions/misc').getCounter(counter))
   if a1 and a2 then
    if a2 > a1 then
     return false
    end
   end
  end
 end
 if check.CounterMin then
  for _,counter in pairs(check.CounterMin._children) do
   a1 = tonumber(check.CounterMin[counter])
   a2 = tonumber(dfhack.script_environment('functions/misc').getCounter(counter))
   if a1 and a2 then
    if a2 < a1 then
     return false
    end
   end
  end
 end
 if check.CounterEqual then
  for _,counter in pairs(check.CounterEqual._children) do
   a1 = tonumber(check.CounterEqual[counter])
   a2 = tonumber(dfhack.script_environment('functions/misc').getCounter(counter))
   if a1 and a2 then
    if not a2 == a1 then
     return false
    end
   end
  end
 end
-- Check for item
 if check.Item then
  for _,itype in pairs(check.Item._children) do
   for _,isubtype in pairs(check.Item[itype]._children) do
    n1 = tonumber(check.Item[itype][isubtype])
    n2 = 0
    for _,item in pairs(df.global.world.items.other[itype]) do
     if item.subtype.ID == isubtype then n2 = n2 + 1 end
    end
    if n2 < n1 then
     return false
    end
   end
  end
 end
-- Check for building
 if check.Building then
  for _,building in pairs(check.Building._children) do
   n1 = tonumber(check.Building[building])
   n2 = 0
   local buildingList = df.global.world.buildings.all
   for i,x in pairs(buildingList) do
    if df.building_workshopst:is_instance(x) or df.building_furnacest:is_instance(x) then
     if x.custom_type >= 0 then
      if df.global.world.raws.buildings.all[x.custom_type].code == builing then
       n2 = n2+1
      end
     end
    end
    if n2 < n1 then
     return false
    end
   end
  end
 end
-- Check for skill
 if check.Skill then
  for _,skill in pairs(check.Skill._children) do
   level = tonumber(check.Skill[skill])
   for _,unit in pairs(df.global.world.units.active) do
    if dfhack.units.getEffectiveSkill(unit,df.job_skill[skill]) < level then
     return false
    end
   end
  end 
 end
-- Check for class
 if check.Class and persistTable.GlobalTable.roses.ClassTable then
  for _,classname in pairs(check.Class._children) do
   level = tonumber(check.Class[classname])
   for _,unit in pairs(df.global.world.units.active) do
    if persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)] then
     if persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)].Classes[classname] then
      if tonumber(persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)].Classes[classname]) < level then
       return false
      end
     else
      return false
     end
    else
     return false
    end
   end
  end
 end
-- Check for kills
 if check.CreatureKills and persistTable.GlobalTable.roses.GlobalTable then
  for _,creature in pairs(check.CreatureKills._children) do
   for _,caste in pairs(check.CreatureKills[creature]._children) do
    n1 = tonumber(check.CreatureKills[creature][caste])
    if caste == 'ALL' or caste == 'TOTAL' then
     n2 = persistTable.GlobalTable.roses.GlobalTable.Kills[creature].Total
    else
     n2 = persistTable.GlobalTable.roses.GlobalTable.Kills[creature][caste]
    end
    if n1 and n2 then
     if tonumber(n2) < n1 then
      return false
     end
    end
   end
  end
 end
 if check.EntityKills and persistTable.GlobalTable.roses.GlobalTable then
  for _,entity in pairs(check.EntityKills._children) do
   n1 = tonumber(check.EntityKills[entity])
   n2 = persistTable.GlobalTable.roses.GlobalTable.Kills[entity]
   if n1 and n2 then
    if tonumber(n2) < n1 then
     return false
    end
   end
  end
 end
-- Check for deaths
 if check.CreatureDeaths and persistTable.GlobalTable.roses.GlobalTable then
  for _,creature in pairs(check.CreatureDeaths._children) do
   for _,caste in pairs(check.CreatureDeaths[creature]._children) do
    n1 = tonumber(check.CreatureDeaths[creature][caste])
    if caste == 'ALL' or caste == 'TOTAL' then
     n2 = persistTable.GlobalTable.roses.GlobalTable.Deaths[creature].Total
    else
     n2 = persistTable.GlobalTable.roses.GlobalTable.Deaths[creature][caste]
    end
    if n1 and n2 then
     if tonumber(n2) < n1 then
      return false
     end
    end
   end
  end
 end
 if check.EntityDeaths and persistTable.GlobalTable.roses.GlobalTable then
  for _,entity in pairs(check.EntityDeaths._children) do
   n1 = tonumber(check.EntityDeaths[entity])
   n2 = persistTable.GlobalTable.roses.GlobalTable.Deaths[entity]
   if n1 and n2 then
    if tonumber(n2) < n1 then
     return false
    end
   end
  end 
 end
-- Check for sieges
 if check.Sieges and persistTable.GlobalTable.roses.GlobalTable then
  for _,civ in pairs(check.Sieges._children) do
   number = tonumber(check.Sieges[civ])
   if persistTable.GlobalTable.roses.GlobalTable.Sieges[civ] then
    if tonumber(persistTable.GlobalTable.roses.GlobalTable.Sieges[civ]) < number then
     return false
    end
   end
  end
 end
-- Check for trades
 if check.Trades and persistTable.GlobalTable.roses.GlobalTable then
  for _,civ in pairs(check.Trades._children) do
   number = tonumber(check.Trades[civ])
   if persistTable.GlobalTable.roses.GlobalTable.Trades[civ] then
    if tonumber(persistTable.GlobalTable.roses.GlobalTable.Trades[civ]) < number then
     return false
    end
   end
  end
 end
-- Check for diplomacy
 if check.Diplomacy and persistTable.GlobalTable.roses.DiplomacyTable then
  for _,dip_string in pairs(check.Diplomacy._children) do
   dip_array = split(dip_string,':')
   civ1,civ2,relation,number = dip_array[1],dip_array[2],dip_array[3],dip_array[4]
   if civ1 and civ2 and relation and number then
    score = tonumber(persistTable.GlobalTable.roses.DiplomacyTable[civ1][civ2])
    if relation == 'GREATER' then
     if score < tonumber(number) then
      return false
     end
    elseif relation == 'LESS' then
     if score > tonumber(number) then
      return false
     end
    end
   end
  end
 end
 return true
end

function queueCheck(id,method,verbose)
 if method == 'YEARLY' then
  curtick = df.global.cur_year_tick
  ticks = 1200*28*3*4-curtick
  if ticks <= 0 then ticks = 1200*28*3*4 end
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'YEARLY',verbose)
                                 end
                )
  checkEntity(id,'YEARLY',verbose)
 elseif method == 'SEASON' then
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'SEASON',verbose)
                                 end
                )
 elseif method == 'MONTHLY' then
  curtick = df.global.cur_year_tick
  moy = curtick/(1200*28)
  ticks = math.ceil(moy)*1200*28 - curtick
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'MONTHLY',verbose)
                                 end
                )
 elseif method == 'WEEKLY' then
  curtick = df.global.cur_year_tick
  woy = curtick/(1200*7)
  ticks = math.ceil(woy)*1200*7 - curtick
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'WEEKLY',verbose)
                                 end
                )
 elseif method == 'DAILY' then
  curtick = df.global.cur_year_tick
  doy = curtick/1200
  ticks = math.ceil(doy)*1200 - curtick
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'DAILY',verbose)
                                 end
                )
 else
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  dfhack.timeout(ticks+1,'ticks',function ()
                                  checkEntity(id,'SEASON',verbose)
                                 end
                )
 end
end

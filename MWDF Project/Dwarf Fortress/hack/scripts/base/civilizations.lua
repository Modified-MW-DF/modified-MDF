--base/civilizations.lua v1.0

local persistTable = require 'persist-table'

function checkmethod(civ)
 print('Checking new leveling method')
 local key = tostring(civ.id)
 local entity = civ.entity_raw.code
 local civilization = persistTable.GlobalTable.roses.CivilizationTable
 if civilization[entity] then
  local method = persistTable.GlobalTable.roses.EntityTable[key]['Civilization']['CurrentMethod']
  local chance = persistTable.GlobalTable.roses.EntityTable[key]['Civilization']['CurrentPercent']
  if method then
--   print('Leveling method = '..method)
   if method == 'YEARLY' then
    curtick = df.global.cur_year_tick
    ticks = 1200*28*3*4-curtick
    if ticks <= 0 then ticks = 1200*28*3*4 end
    dfhack.timeout(ticks+1,'ticks',checklevel(civ,method,chance))
   elseif method == 'SEASON' then
    curtick = df.global.cur_season_tick*10
    ticks = 1200*28*3-curtick
    if ticks <= 0 then ticks = 1200*28*3 end
    dfhack.timeout(ticks+1,'ticks',checklevel(civ,method,chance))
   elseif method == 'MONTHLY' then
    curtick = df.global.cur_year_tick
    moy = curtick/(1200*28)
    ticks = math.ceil(moy)*1200*28 - curtick
    if ticks <= 0 then ticks = 1200*28 end
    dfhack.timeout(ticks+1,'ticks',checklevel(civ,method,chance))
   elseif method == 'WEEKLY' then
    curtick = df.global.cur_year_tick
    woy = curtick/(1200*7)
    ticks = math.ceil(woy)*1200*7 - curtick
    if ticks <= 0 then ticks = 1200*7 end
    dfhack.timeout(ticks+1,'ticks',checklevel(civ,method,chance))
   elseif method == 'DAILY' then
    curtick = df.global.cur_year_tick
    doy = curtick/1200
    ticks = math.ceil(doy)*1200 - curtick
    if ticks <= 0 then ticks = 1200 end
    dfhack.timeout(ticks+1,'ticks',checklevel(civ,method,chance))
   end
  end
 end
end

function checklevel(civ,method,chance)
 return function(levelcheck)
--  print('Checking if civ has leveled up')
  local rando = dfhack.random.new()
  if method == 'KILL' then
   --NOT CURRENTLY IMPLEMENTED
  elseif method == 'INVASION' then
   --NOT CURRENTLY IMPLEMENTED
  elseif method == 'TRADE' then
   --NOT CURRENTLY IMPLEMENTED
  elseif method == 'COUNTER' then
   --NOT CURRENTLY IMPLEMENTED
  else
   rnum = rando:random(100)+1
   if tonumber(chance) >= rnum then dfhack.run_command('civilizations/level-up '..tostring(civ.id)) end
  end
  checkmethod(civ)
 end
end

for i,x in ipairs(df.global.world.entities.all) do
 dfhack.script_environment('civilizations/establish-civ').establishCivilization(x)
end

for i,x in pairs(df.global.world.entities.all) do
-- print('Checking for civilization')
 local key = tostring(x.id)
 local entity = x.entity_raw.code
 local civilization = persistTable.GlobalTable.roses.CivilizationTable
 if civilization[entity] then
--  print('Civilization found')
  local method = persistTable.GlobalTable.roses.EntityTable[key]['Civilization']['CurrentMethod']
  local chance = persistTable.GlobalTable.roses.EntityTable[key]['Civilization']['PercentMethod']
--  print('Leveling method = '..method)
  if method then
   if method == 'YEARLY' then
    curtick = df.global.cur_year_tick
    ticks = 1200*28*3*4-curtick
    if ticks <= 0 then ticks = 1200*28*3*4 end
    dfhack.timeout(ticks+1,'ticks',checklevel(x,method,chance))
   elseif method == 'SEASON' then
    curtick = df.global.cur_season_tick*10
    ticks = 1200*28*3-curtick
    if ticks <= 0 then ticks = 1200*28*3 end
    dfhack.timeout(ticks+1,'ticks',checklevel(x,method,chance))
   elseif method == 'MONTHLY' then
    curtick = df.global.cur_year_tick
    moy = curtick/(1200*28)
    ticks = math.ceil(moy)*1200*28 - curtick
    if ticks <= 0 then ticks = 1200*28 end
    dfhack.timeout(ticks+1,'ticks',checklevel(x,method,chance))
   elseif method == 'WEEKLY' then
    curtick = df.global.cur_year_tick
    woy = curtick/(1200*7)
    ticks = math.ceil(woy)*1200*7 - curtick
    if ticks <= 0 then ticks = 1200*7 end
    dfhack.timeout(ticks+1,'ticks',checklevel(x,method,chance))
   elseif method == 'DAILY' then
    curtick = df.global.cur_year_tick
    doy = curtick/1200
    ticks = math.ceil(doy)*1200 - curtick
    if ticks <= 0 then ticks = 1200 end
    dfhack.timeout(ticks+1,'ticks',checklevel(x,method,chance))
   else
    curtick = df.global.cur_season_tick*10
    ticks = 1200*28*3-curtick
    if ticks <= 0 then ticks = 1200*28*3 end
    dfhack.timeout(ticks+1,'ticks',checklevel(x,method,chance))
   end
  end
 end
end

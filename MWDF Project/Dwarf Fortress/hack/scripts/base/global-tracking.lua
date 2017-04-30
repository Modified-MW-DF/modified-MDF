--base/global-tracking.lua v1.0

local persistTable = require 'persist-table'

if not persistTable.GlobalTable.roses.GlobalTable then
 persistTable.GlobalTable.roses.GlobalTable = {}
 local globalTable = persistTable.GlobalTable.roses.GlobalTable
 globalTable.Counters = {}
 globalTable.Deaths = {}
 globalTable.Deaths.All = '0'
 globalTable.Kills = {}
 globalTable.Kills.All = '0'
 globalTable.Sieges = {}
 globalTable.Trades = {}
end

local events = require "plugins.eventful"
events.enableEvent(events.eventType.UNIT_DEATH,10)
globalTable = persistTable.GlobalTable.roses.GlobalTable
entityTable = persistTable.GlobalTable.roses.EntityTable
unitTable = persistTable.GlobalTable.roses.UnitTable

events.onUnitDeath.tracking=function(unit_id)
 unit = df.unit.find(unit_id)
 creature = df.global.world.raws.creatures.all[unit.race].creature_id
 caste = df.global.world.raws.creatures.all[unit.race].caste[unit.caste].caste_id
 if not globalTable.Deaths[creature] then
  globalTable.Deaths[creature] = {}
  for _,x in pairs(df.global.world.raws.creatures.all[unit.race].caste) do
   globalTable.Deaths[creature][x.caste_id] = '0'
  end
  globalTable.Deaths[creature]['All'] = '0'
 end
 globalTable.Deaths.All = tostring(globalTable.Deaths.All+1)
 globalTable.Deaths[creature][caste] = tostring(globalTable.Deaths[creature][caste]+1)
 globalTable.Deaths[creature]['All'] = tostring(globalTable.Deaths[creature]['All']+1)
 if entityTable then
  entityTable[tostring(unit.civ_id)].Stats.Deaths = tostring(entityTable[tostring(unit.civ_id)].Stats.Deaths + 1)
 end
 if not unitTable[tostring(unit.id)] then
  unitTable[tostring(unit.id)] = {}
  unitTable[tostring(unit.id)].Deaths = '0'
 end
 unitTable[tostring(unit.id)].Deaths = unitTable[tostring(unit.id)].Deaths or '0'
 unitTable[tostring(unit.id)].Deaths = tostring(unitTable[tostring(unit.id)].Deaths + '1')
 
 killer_id = tonumber(unit.relations.last_attacker_id)
 if killer_id >= 0 then
  unit = df.unit.find(killer_id)
  creature = df.global.world.raws.creatures.all[unit.race].creature_id
  caste = df.global.world.raws.creatures.all[unit.race].caste[unit.caste].caste_id
  if not globalTable.Kills[creature] then
   globalTable.Kills[creature] = {}
   for _,x in pairs(df.global.world.raws.creatures.all[unit.race].caste) do
    globalTable.Kills[creature][x.caste_id] = '0'
   end
   globalTable.Kills[creature]['All'] = '0'
  end
  globalTable.Kills.All = tostring(globalTable.Kills.All+1)
  globalTable.Kills[creature][caste] = tostring(globalTable.Kills[creature][caste]+1)
  globalTable.Kills[creature]['All'] = tostring(globalTable.Kills[creature]['All']+1)
  if entityTable then
   entityTable[tostring(unit.civ_id)].Stats.Kills = tostring(entityTable[tostring(unit.civ_id)].Stats.Kills + 1)
  end
  if not unitTable[tostring(unit.id)] then
   unitTable[tostring(unit.id)] = {}
   unitTable[tostring(unit.id)].Kills = '0'
  end
  unitTable[tostring(unit.id)].Kills = unitTable[tostring(unit.id)].Kills or '0'
  unitTable[tostring(unit.id)].Kills = tostring(unitTable[tostring(unit.id)].Kills + '1')
 end
end
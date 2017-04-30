--MUST BE LOADED IN DFHACK.INIT

local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'

validArgs = validArgs or utils.invert({
 'help',
 'all',
 'classSystem',
 'civilizationSystem',
 'eventSystem',
 'forceReload'
})
local args = utils.processArgs({...}, validArgs)

persistTable.GlobalTable.roses = persistTable.GlobalTable.roses or {}
persistTable.GlobalTable.roses.UnitTable = persistTable.GlobalTable.roses.UnitTable or {}
persistTable.GlobalTable.roses.ItemTable = persistTable.GlobalTable.roses.ItemTable or {}
persistTable.GlobalTable.roses.BuildingTable = persistTable.GlobalTable.roses.BuildingTable or {}
persistTable.GlobalTable.roses.EntityTable = persistTable.GlobalTable.roses.EntityTable or {}
persistTable.GlobalTable.roses.CommandDelay = persistTable.GlobalTable.roses.CommandDelay or {}
persistTable.GlobalTable.roses.EnvironmentDelay = persistTable.GlobalTable.roses.EnvironmentDelay or {}
persistTable.GlobalTable.roses.CounterTable = persistTable.GlobalTable.roses.CounterTable or {}
persistTable.GlobalTable.roses.LiquidTable = persistTable.GlobalTable.roses.LiquidTable or {}
if not persistTable.GlobalTable.roses.GlobalTable then dfhack.script_environment('functions/tables').makeGlobalTable() end

local function civilizationNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.CivilizationTable) or #persistTable.GlobalTable.roses.CivilizationTable._children < 1
end
local function classNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.ClassTable) or #persistTable.GlobalTable.roses.ClassTable._children < 1
end
local function eventNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EventTable) or #persistTable.GlobalTable.roses.EventTable._children < 1
end
local function spellNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.SpellTable) or #persistTable.GlobalTable.roses.SpellTable._children < 1
end
local function featNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.FeatTable) or #persistTable.GlobalTable.roses.FeatTable._children < 1
end

dfhack.script_environment('functions/tables').makeBaseTable()

if args.all or args.classSystem then
 if type(args.classSystem) == 'string' then args.classSystem = {args.classSystem} end
 featCheck = false
 spellCheck = false
 classCheck = false
 for _,check in pairs(args.classSystem) do
  if check == 'Feats' then   
   if featNotAlreadyLoaded() or args.forceReload then
    featCheck = dfhack.script_environment('functions/tables').makeFeatTable()
   elseif not featNotAlreadyLoaded() then
    featCheck = true
   end
  elseif check == 'Spells' then
   if spellNotAlreadyLoaded() or args.forceReload then
    spellCheck = dfhack.script_environment('functions/tables').makeSpellTable()
   elseif not spellNotAlreadyLoaded() then
    spellCheck = true
   end  
  end
 end

 if classNotAlreadyLoaded() or args.forceReload then
  classCheck = dfhack.script_environment('functions/tables').makeClassTable(spellCheck)
 elseif not classNotAlreadyLoaded() then
  classCheck = true
 end

 if classCheck then
  print('Class System successfully loaded')
  print('Number of Classes: '..tostring(#persistTable.GlobalTable.roses.ClassTable._children))
  if spellCheck then
   print('Spell SubSystem loaded')
   print('Number of Spells: '..tostring(#persistTable.GlobalTable.roses.SpellTable._children))
  else
   print('Spell SubSystem not loaded')
  end
  if featCheck then
   print('Feat SubSystem loaded')
   print('Number of Feats: '..tostring(#persistTable.GlobalTable.roses.FeatTable._children))
  else
   print('Feat SubSystem not loaded')
  end
 else
  print('Class System not loaded')
 end
end

if args.all or args.civilizationSystem then
 systemCheck = false
 if civilizationNotAlreadyLoaded() or args.forceReload then
  systemCheck = dfhack.script_environment('functions/tables').makeCivilizationTable()
 elseif not civilizationNotAlreadyLoaded() then
  systemCheck = true
 end
 if systemCheck then
  print('Civilization System successfully loaded')
 end
end

if args.all or args.eventSystem then
 systemCheck = false
 if eventNotAlreadyLoaded() or args.forceReload then
  systemCheck = dfhack.script_environment('functions/tables').makeEventTable()
 elseif not eventNotAlreadyLoaded() then
  systemCheck = true
 end
 if systemCheck then
  print('Event System successfully loaded')
 end
end

dfhack.run_command('base/persist-delay')
--dfhack.run_command('base/global-tracking')
dfhack.run_command('base/liquids-update')
dfhack.run_command('base/on-death')
--dfhack.run_command('base/on-time')
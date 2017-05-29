--MUST BE LOADED IN DFHACK.INIT
--MUST BE LOADED AT onLoad.int -due to it needing a map save file to create persist-tables.

local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'

validArgs = validArgs or utils.invert({
 'help',
 'all',
 'classSystem',
 'civilizationSystem',
 'enhancedSystem',
 'eventSystem',
 'forceReload',
 'testRun',
 'verbose'
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
persistTable.GlobalTable.roses.FlowTable = persistTable.GlobalTable.roses.FlowTable or {}
if not persistTable.GlobalTable.roses.GlobalTable then dfhack.script_environment('functions/tables').makeGlobalTable(args.verbose) end

local function civilizationNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.CivilizationTable) or #persistTable.GlobalTable.roses.CivilizationTable._children < 1
end
local function diplomacyNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.DiplomacyTable) or #persistTable.GlobalTable.roses.DiplomacyTable._children < 1
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
local function EBuildingsNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EnhancedBuildingTable) or #persistTable.GlobalTable.roses.EnhancedBuildingTable._children < 1
end
local function ECreaturesNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EnhancedCreatureTable) or #persistTable.GlobalTable.roses.EnhancedCreatureTable._children < 1
end
local function EItemsNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EnhancedItemTable) or #persistTable.GlobalTable.roses.EnhancedItemTable._children < 1
end
local function EMaterialsNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EnhancedMaterialTable) or #persistTable.GlobalTable.roses.EnhancedMaterialTable._children < 1
end

dfhack.script_environment('functions/tables').makeBaseTable(args.testRun,args.verbose)

if args.all or args.classSystem then
 if args.verbose then print('Initializing the Class System') end
 if type(args.classSystem) == 'string' then args.classSystem = {args.classSystem} end
 featCheck = false
 spellCheck = false
 classCheck = false
 for _,check in pairs(args.classSystem) do
  if check == 'Feats' then   
   if featNotAlreadyLoaded() or args.forceReload then
    featCheck = dfhack.script_environment('functions/tables').makeFeatTable(args.testRun,args.verbose)
   elseif not featNotAlreadyLoaded() then
    featCheck = true
    if args.verbose then print('Feat SubSystem already loaded, use -forceReload to force a reload of the system') end
   end
  elseif check == 'Spells' then
   if spellNotAlreadyLoaded() or args.forceReload then
    spellCheck = dfhack.script_environment('functions/tables').makeSpellTable(args.testRun,args.verbose)
   elseif not spellNotAlreadyLoaded() then
    spellCheck = true
    if args.verbose then print('Spell SubSystem already loaded, use -forceReload to force a reload of the system') end
   end  
  end
 end

 if classNotAlreadyLoaded() or args.forceReload then
  classCheck = dfhack.script_environment('functions/tables').makeClassTable(spellCheck,args.testRun,args.verbose)
 elseif not classNotAlreadyLoaded() then
  classCheck = true
  if args.verbose then print('Class System already loaded, use -forceReload to force a reload of the system') end
 end

 if classCheck then
  print('Class System successfully loaded')
  print('Number of Classes: '..tostring(#persistTable.GlobalTable.roses.ClassTable._children))
  if verbose then
   print('Classes:')
   for _,n in pairs(persistTable.GlobalTable.roses.ClassTable._children) do
    print(persistTable.GlobalTable.roses.ClassTable[n])
   end
  end
  if spellCheck then
   print('Spell SubSystem loaded')
   print('Number of Spells: '..tostring(#persistTable.GlobalTable.roses.SpellTable._children))
   if verbose then
    print('Spells:')
    for _,n in pairs(persistTable.GlobalTable.roses.SpellTable._children) do
     print(persistTable.GlobalTable.roses.SpellTable[n])
    end
   end
  else
   print('Spell SubSystem not loaded')
  end
  if featCheck then
   print('Feat SubSystem loaded')
   print('Number of Feats: '..tostring(#persistTable.GlobalTable.roses.FeatTable._children))
   if verbose then
    print('Feats:')
    for _,n in pairs(persistTable.GlobalTable.roses.FeatTable._children) do
     print(persistTable.GlobalTable.roses.FeatTable[n])
    end
   end
  else
   print('Feat SubSystem not loaded')
  end
 else
  print('Class System not loaded')
 end
end

if args.all or args.civilizationSystem then
 if args.verbose then print('Initializing the Civilization System') end
 if type(args.civilizationSystem) == 'string' then args.civilizationSystem = {args.civilizationSystem} end
 diplomacyCheck = false
 civilizationCheck = false
 if civilizationNotAlreadyLoaded() or args.forceReload then
  civilizationCheck = dfhack.script_environment('functions/tables').makeCivilizationTable(args.testRun,args.verbose)
 elseif not classNotAlreadyLoaded() then
  civilizationCheck = true
  if args.verbose then print('Civilization System already loaded, use -forceReload to force a reload of the system') end
 end
 for _,check in pairs(args.civilizationSystem) do
  if check == 'Diplomacy' then   
   if diplomacyNotAlreadyLoaded() then
    diplomacyCheck = dfhack.script_environment('functions/tables').makeDiplomacyTable(args.verbose)
   elseif not diplomacyNotAlreadyLoaded() then
    diplomacyCheck = true
   end
  end
 end

 if civilizationCheck then
  print('Civilization System successfully loaded')
  print('Number of Civilizations: '..tostring(#persistTable.GlobalTable.roses.CivilizationTable._children))
  if verbose then
   print('Civilizations:')
   for _,n in pairs(persistTable.GlobalTable.roses.CivilizationTable._children) do
    print(persistTable.GlobalTable.roses.CivilizationTable[n])
   end
  end  
  if diplomacyCheck then
   print('Diplomacy SubSystem loaded')
  else
   print('Diplomacy SubSystem not loaded')
  end
 else
  print('Civilization System not loaded')
 end
end

if args.all or args.enhancedSystem then
 if args.verbose then print('Initializing the Enhanced System') end
 if type(args.enhancedSystem) == 'string' then args.enhancedSystem = {args.enhancedSystem} end
 for _,check in pairs(args.enhancedSystem) do
  buildingCheck = false
  creatureCheck = false
  itemCheck = false
  materialCheck = false
  if check == 'Buildings' then
   if EBuildingsNotAlreadyLoaded() or args.forceReload then
    buildingCheck = dfhack.script_environment('functions/tables').makeEnhancedBuildingTable(args.testRun,args.verbose)
   elseif not EBuildingsNotAlreadyLoaded() then
    buildingCheck = true
    if args.verbose then print('Enhanced System - Buildings already loaded, use -forceReload to force a reload of the system') end
   end
  elseif check == 'Creatures' then
   if ECreaturesNotAlreadyLoaded() or args.forceReload then
    creatureCheck = dfhack.script_environment('functions/tables').makeEnhancedCreatureTable(args.testRun,args.verbose)
   elseif not ECreaturesNotAlreadyLoaded() then
    creatureCheck = true
    if args.verbose then print('Enhanced System - Creatures already loaded, use -forceReload to force a reload of the system') end
   end
  elseif check == 'Items' then
   if EItemsNotAlreadyLoaded() or args.forceReload then
    itemCheck = dfhack.script_environment('functions/tables').makeEnhancedItemTable(args.testRun,args.verbose)
   elseif not EItemssNotAlreadyLoaded() then
    itemCheck = true
    if args.verbose then print('Enhanced System - Items already loaded, use -forceReload to force a reload of the system') end
   end
  elseif check == 'Materials' then
   if EMaterialsNotAlreadyLoaded() or args.forceReload then
    materialCheck = dfhack.script_environment('functions/tables').makeEnhancedMaterialTable(args.testRun,args.verbose)
   elseif not EMaterialssNotAlreadyLoaded() then
    materialCheck = true
    if args.verbose then print('Enhanced System - Materials already loaded, use -forceReload to force a reload of the system') end
   end
  end
 end
 
 if buildingCheck then
  print('Enhanced System - Buildings successfully loaded')
  print('Number of Enhanced Buildings: '..tostring(#persistTable.GlobalTable.roses.EnhancedBuildingTable._children))
  if verbose then
   print('Enhanced Buildings:')
   for _,n in pairs(persistTable.GlobalTable.roses.EnhancedBuildingTable._children) do
    print(persistTable.GlobalTable.roses.EnhancedBuildingTable[n])
   end
  end
 else
  print('Enhanced System - Buildings not loaded')
 end
 if creatureCheck then
  print('Enhanced System - Creatures successfully loaded')
  print('Number of Enhanced Creatures: '..tostring(#persistTable.GlobalTable.roses.EnhancedCreatureTable._children))
  if verbose then
   print('Enhanced Creatures:')
   for _,n in pairs(persistTable.GlobalTable.roses.EnhancedCreatureTable._children) do
    print(persistTable.GlobalTable.roses.EnhancedCreatureTable[n])
   end
  end
 else
  print('Enhanced System - Creatures not loaded')
 end
 if itemCheck then
  print('Enhanced System - Items successfully loaded')
  print('Number of Enhanced Items: '..tostring(#persistTable.GlobalTable.roses.EnhancedItemTable._children))
  if verbose then
   print('Enhanced Items:')
   for _,n in pairs(persistTable.GlobalTable.roses.EnhancedItemTable._children) do
    print(persistTable.GlobalTable.roses.EnhancedItemTable[n])
   end
  end
 else
  print('Enhanced System - Items not loaded')
 end
 if materialCheck then
  print('Enhanced System - Materials successfully loaded')
  print('Number of Enhanced Materials: '..tostring(#persistTable.GlobalTable.roses.EnhancedMaterialTable._children))
  if verbose then
   print('Enhanced Materials:')
   for _,n in pairs(persistTable.GlobalTable.roses.EnhancedMaterialTable._children) do
    print(persistTable.GlobalTable.roses.EnhancedMaterialTable[n])
   end
  end
 else
  print('Enhanced System - Materials not loaded')
 end
end

if args.all or args.eventSystem then
 if args.verbose then print('Initializing the Event System') end
 systemCheck = false
 if eventNotAlreadyLoaded() or args.forceReload then
  systemCheck = dfhack.script_environment('functions/tables').makeEventTable(args.testRun,args.verbose)
 elseif not eventNotAlreadyLoaded() then
  systemCheck = true
  if args.verbose then print('Event System already loaded, use -forceReload to force a reload of the system') end
 end
 if systemCheck then
  print('Event System successfully loaded')
  print('Number of Events: '..tostring(#persistTable.GlobalTable.roses.EventTable._children))
  if verbose then
   print('Events:')
   for _,n in pairs(persistTable.GlobalTable.roses.EventTable._children) do
    print(persistTable.GlobalTable.roses.EventTable[n])
   end
  end
 else
  print('Event System not loaded')
 end
end

if args.testRun then
 print('Base commands are run seperately for a -testRun')
else
 if args.verbose then
  print('Running base/persist-delay')
  dfhack.run_command('base/persist-delay -verbose')
  print('Running base/liquids-update')
  dfhack.run_command('base/liquids-update -verbose')
  print('Running base/flows-update')
  dfhack.run_command('base/flows-update -verbose')
  print('Running base/on-death')
  dfhack.run_command('base/on-death -verbose')
  print('Running base/on-time')
  dfhack.run_command('base/on-time -verbose')
--  print('Running base/periodic-check')  turned off in masterwork we don't use it.
  dfhack.run_command('base/periodic-check -verbose')
 else
  dfhack.run_command('base/persist-delay')
  dfhack.run_command('base/liquids-update')
  dfhack.run_command('base/flows-update')
  dfhack.run_command('base/on-death')
  dfhack.run_command('base/on-time')
--  dfhack.run_command('base/periodic-check')  turned off in masterwork we don't use it.
 end
end

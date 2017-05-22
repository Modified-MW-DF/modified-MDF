local utils = require 'utils'

input = {...}

validArgs = validArgs or utils.invert({
 'help',
 'verbose',
 'test',
 -- basic inputs
 'sourceUnit',
 'sourceLocation',
 'targetUnit',
 'targetLocation',
 'targetPlan',
 'template',
 'script',
 -- script manipulation inputs
 'chain',
 'value',
 'maxTargets',
 'delay',
 'radius',
 'silence',
 'replace',
 'center',
 'resetCooldown',
 -- unit based inputs
 'checkUnit',
 'reflect',
 'exclude',
 'requiredClass',
 'requiredCreature',
 'requiredSyndrome',
 'requiredToken',
 'requiredNoble',
 'requiredProfession',
 'requiredEntity',
 'requiredPathing',
 'immuneClass',
 'immuneCreature',
 'immuneSyndrome',
 'immuneToken',
 'immuneNoble',
 'immuneProfession',
 'immuneEntity',
 'immunePathing',
 'maxAttribute',
 'minAttribute',
 'gtAttribute',
 'ltAttribute',
 'maxSkill',
 'minSkill',
 'gtSkill',
 'ltSkill',
 'maxTrait',
 'minTrait',
 'gtTrait',
 'ltTrait',
 'maxAge',
 'minAge',
 'gtAge',
 'ltAge',
 'maxSpeed',
 'minSpeed',
 'gtSpeed',
 'ltSpeed',
 -- location based inputs
 'checkLocation',
 'requiredTree',
 'requiredPlant',
 'requiredGrass',
 'requiredInorganic',
 'requiredFlow',
 'requiredLiquid',
 'forbiddenTree',
 'forbiddenPlant',
 'forbiddenGrass',
 'forbiddenInorganic',
 'forbiddenFlow',
 'forbiddenLiquid',
 -- item based inputs
 'checkItem',
 'requiredItem',
 'requiredMaterial',
 'requiredCorpse',
 'forbiddenItem',
 'forbiddenMaterial',
 'forbiddenCorpse',
})
local args = utils.processArgs(input, validArgs)

num = 0
if args.checkUnit then num = num + 1 end
if args.checkLocation then num = num + 1 end
if args.checkItem then num = num + 1 end
if not num == 1 then 
 if args.verbose then print('One and only one check required') end
 return
end

if args.template then
 local persistTable = require 'persist-table'
 if persistTable.GlobalTable.roses then
  templateTable = persistTable.GlobalTable.roses.WrapperTemplates
 else
  if args.verbose then print('Roses persist-tables not loaded') end
  return
 end
 if templateTable[args.template] then
  str = templateTable[args.template].Input
  temp = table.concat(input,' ')
  temp = temp:gsub('-template '..args.template,str)
  dfhack.run_command('wrapper'..temp)
  return
 else
  if args.verbose then print('No valid wrapper template for -template') end
  return
 end
end

if not args.script then
 if args.verbose then print('No script provided to run') end
 return
end
if not string.find(args.script[1],' ') then args.script = {table.concat(args.script, ' ')} end

sourceUnit = nil
sourceLocation = nil
if args.sourceUnit and tonumber(args.sourceUnit) and df.unit.find(tonumber(args.sourceUnit)) then
 sourceUnit = df.unit.find(tonumber(args.sourceUnit))
 sourceLocation = sourceUnit.pos
elseif args.sourceLocation then
 sourceLocation = {}
 sourceLocation.x = args.sourceLocation[1]
 sourceLocation.y = args.sourceLocation[2]
 sourceLocation.z = args.sourceLocation[3]
end

-- Check if the casting unit is silenced
if args.silence and sourceUnit then
 if dfhack.script_environment('functions/unit').checkClass(sourceUnit,args.silence) then
  if args.verbose then print('unit is prevented from using interaction (SILENCED)') end
  return
 end
end

args.chain = tonumber(args.chain) or 0
args.maxTargets = tonumber(args.maxTargets) or 0
args.delay = tonumber(args.delay) or 0
 
if args.center then
 centerUnit = sourceUnit
 centerLocation = sourceLocation
elseif (args.targetUnit and tonumber(args.targetUnit) and df.unit.find(tonumber(args.targetUnit))) then
 centerUnit = df.unit.find(tonumber(args.targetUnit))
 centerLocation = centerUnit.pos
elseif args.targetLocation then
 centerUnit = nil
 centerLocation = {}
 centerLocation.x = args.targetLocation[1]
 centerLocation.y = args.targetLocation[2]
 centerLocation.z = args.targetLocation[3]
end

if args.checkUnit then
 if not centerUnit then 
  if args.verbose then print('No valid center unit declared. Use either -targetUnit or -center arguments') end
  return
 end
 
 for count = 0, args.chain, 1 do
  if count >= 0 then
   -- Step 1: Get all units within a specified radius of the center unit (which is the source unit if -center is used, or the target unit if -targetUnit is used)
   targetList,n = dfhack.script_environment('functions/wrapper').checkUnitLocation(centerUnit,args.radius)
   -- Step 2: Trim the target list down to units that meet the -checkUnit declaration
   targetList,n = dfhack.script_environment('functions/wrapper').checkTarget(sourceUnit,targetList,args.checkUnit,args.verbose)
   -- Step 3: Determine eligible targets from list based on age/speed/attributes/skills/etc... Any comparisons are made between the source unit and perspective target
   selected = {}
   for n,unit in pairs(targetList) do
    selected[n] = dfhack.script_environment('functions/wrapper').isSelectedUnit(sourceUnit,unit,args)
   end
   -- Step 4: Pick targets from the eligible list (number of targets picked ranges between 1 and args.maxTargets). If -exclude is included, the sourceUnit will be removed from the eligible target list
   targets,i = {},0
   for n,unit in pairs(targetList) do
    if args.exclude then
     if unit == sourceUnit then selected[n] = false end
    end
    if selected[n] then     
     i = i + 1
     targets[i] = unit
    end
   end
   if i == 0 then
    if args.verbose then print('No valid targets found') end
    return
   end
   if args.maxTargets == 0 or args.maxTargets >= i then
    targets = targets
   else
    targets = dfhack.script_environment('functions/misc').permute(targets)
    targets = {selected(#targets-args.maxTargets+1,table.unpack(targets))}
   end    
   -- Step 5: Assign the script to each target in the target list (check for reflections here)
   for _,unit in ipairs(targets) do
    targetUnit = unit
    save = sourceUnit
    if args.reflect then
     if dfhack.script_environment('functions/unit').checkClass(unit,args.reflect) then
      sourceUnit = unit
      targetUnit = save        
     end
    end
    if args.replace then
     if dfhack.script_environment('functions/unit').checkClassSyndrome(targetUnit,args.replace) then
      dfhack.script_environment('functions/unit').changeSyndrome(targetUnit,args.replace,'terminateClass')
     end
    end
    for _,script in ipairs(args.script) do
     script = script:gsub('TARGET_UNIT_ID',tostring(targetUnit.id))
     script = script:gsub('SOURCE_UNIT_ID',tostring(sourceUnit.id))
     script = script:gsub('CENTER_UNIT_ID',tostring(centerUnit.id))
     script = script:gsub('TARGET_UNIT_LOCATION',"[ "..tostring(targetUnit.pos.x).." "..tostring(targetUnit.pos.y).." "..tostring(targetUnit.pos.z).." ]")
     script = script:gsub('CENTER_UNIT_LOCATION',"[ "..tostring(centerUnit.pos.x).." "..tostring(centerUnit.pos.y).." "..tostring(centerUnit.pos.z).." ]")
     script = script:gsub('SOURCE_UNIT_LOCATION',"[ "..tostring(sourceUnit.pos.x).." "..tostring(sourceUnit.pos.y).." "..tostring(sourceUnit.pos.z).." ]")
     script = script:gsub('TARGET_UNIT_DESTINATION',"[ "..tostring(targetUnit.path.dest.x).." "..tostring(targetUnit.path.dest.y).." "..tostring(targetUnit.path.dest.z).." ]")
     script = script:gsub('CENTER_UNIT_DESTINATION',"[ "..tostring(centerUnit.path.dest.x).." "..tostring(centerUnit.path.dest.y).." "..tostring(centerUnit.path.dest.z).." ]")
     script = script:gsub('SOURCE_UNIT_DESTINATION',"[ "..tostring(sourceUnit.path.dest.x).." "..tostring(sourceUnit.path.dest.y).." "..tostring(sourceUnit.path.dest.z).." ]")
     if args.value then
      if type(args.value) ~= 'table' then args.value = {args.value} end
      for n,equation in pairs(args.value) do
       script = script:gsub('VALUE_'..tostring(n),dfhack.script_environment('functions/wrapper').getValue(equation,targetUnit,sourceUnit,centerUnit,targetList,selected))
      end
     end
     if args.delay == 0 then
      dfhack.run_command(script)
     else
      dfhack.script_environment('persist-delay').delayCommand(script)
     end
    end
    sourceUnit = save
   end
   centerUnit = targets[1]
  end
 end
end

if args.checkLocation then
 if not centerLocation then
  if args.verbose then print('No valid center location declared. Use -targetUnit, -targetLocation or -center arguments') end
  return
 end
 
 for count = 0, args.chain, 1 do
  if count >= 0 then
  -- Step 1: Get all location positions within a specified radius of the center location (which is the source unit location if -center is used, the target unit location if -targetUnit is used or the target location if -targetLocation is used)
   if args.targetPlan then
    positions = dfhack.script_environment('functions/map').getPositionPlan(args.targetPlan,centerUnit,sourceUnit)
   else
    if args.radius then
     positions = dfhack.script_environment('functions/map').getFillPosition(centerLocation,args.radius)
    else
     positions = {centerLocation}
    end
   end
   -- Step 2: Determine which positions to target based on -checkLocation
   positionList,n = dfhack.script_environment('functions/wrapper').checkPosition(sourceLocation,positions,args.checkLocation,args.verbose)
   -- Step 3: Determine eligible targets from list based on what is at the tile
   selected = {}
   for n,pos in pairs(positionList) do
    selected[n] = dfhack.script_environment('functions/wrapper').isSelectedLocation(sourceLocation,pos,args)
   end
   -- Step 4: Pick targets from the eligible list (number of targets picked ranges between 1 and args.maxTargets).
   if n == 0 then
    if args.verbose then print('No valid positions found') end
    return
   end
   if args.maxTargets == 0 or args.maxTargets >= n then
    targets = positionList
   else
    targets = dfhack.script_environment('functions/misc').permute(positionList)
    targets = {selected(#targets-args.maxTargets+1,table.unpack(targets))}
   end    
   -- Step 5: Assign the script to each target in the target list (no reflections or replacements for location based spells)
   for _,position in ipairs(targets) do
    for _,script in ipairs(args.script) do
     script = script:gsub('TARGET_POSITION',"[ "..tostring(position.x).." "..tostring(position.y).." "..tostring(position.z).." ]")
     if args.value then
      if type(args.value) ~= 'table' then args.value = {args.value} end
      for n,equation in pairs(args.value) do
       script = script:gsub('VALUE_'..tostring(n),dfhack.script_environment('functions/wrapper').getValue(equation,nil,sourceUnit,nil,nil,nil))
      end
     end
     if args.delay == 0 then
      dfhack.run_command(script)
     else
      dfhack.script_environment('persist-delay').delayCommand(script)
     end
    end
   end
   centerLocation = targets[1]
  end
 end 
else
 if args.verbose then print('Must have either checkUnit or checkLocation declared') end
 return
end

if args.checkItem then
 if centerUnit then
  center = centerUnit.pos
 elseif centerLocation then
  center = centerLocation
 else
  if args.verbose then print('No valid center unit or location declared. Use either -targetUnit, -targetLocation, or -center arguments') end
  return
 end
 
 for count = 0, args.chain, 1 do
  if count >= 0 then
   -- Step 1: Get all items within a specified radius of the center unit or center location
   targetList,n = dfhack.script_environment('functions/wrapper').checkItemLocation(center,args.radius)
   -- Step 2: Trim the target list down to items that meet the -checkItem declaration
   targetList,n = dfhack.script_environment('functions/wrapper').checkItem(sourceUnit,targetList,args.checkItem,args.verbose)
   -- Step 3: Determine eligible targets from list based on type/subtype/material/etc...
   selected = {}
   for n,item in pairs(targetList) do
    selected[n] = dfhack.script_environment('functions/wrapper').isSelectedItem(sourceUnit,item,args)
   end
   -- Step 4: Pick targets from the eligible list (number of targets picked ranges between 1 and args.maxTargets). If -exclude is included, the sourceUnit will be removed from the eligible target list
   targets,i = {},0
   for n,item in pairs(targetList) do
    if selected[n] then     
     i = i + 1
     targets[i] = item
    end
   end
   if i == 0 then
    if args.verbose then print('No valid items found') end
    return
   end
   if args.maxTargets == 0 or args.maxTargets >= i then
    targets = targets
   else
    targets = dfhack.script_environment('functions/misc').permute(targets)
    targets = {selected(#targets-args.maxTargets+1,table.unpack(targets))}
   end    
   -- Step 5: Assign the script to each target in the target list (no reflections for item based spells)
   for _,item in ipairs(targets) do
    for _,script in ipairs(args.script) do
     script = script:gsub('TARGET_ITEM_ID',tostring(item.id))
     if args.value then
      if type(args.value) ~= 'table' then args.value = {args.value} end
      for n,equation in pairs(args.value) do
       script = script:gsub('VALUE_'..tostring(n),dfhack.script_environment('functions/wrapper').getValue(equation,targetUnit,sourceUnit,centerUnit,targetList,selected))
      end
     end
     if args.delay == 0 then
      dfhack.run_command(script)
     else
      dfhack.script_environment('persist-delay').delayCommand(script)
     end
    end
    sourceUnit = save
   end
   center = targets[1]
  end
 end
end

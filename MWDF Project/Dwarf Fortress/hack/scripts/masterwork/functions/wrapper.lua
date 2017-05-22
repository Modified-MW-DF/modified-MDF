-- Functions used in the wrapper script, v42.06a
--[[
 checkPosition(source,targetList,target,verbose) - Base check for location based checks, compares the relative positions between the source and target (e.g. ABOVE, BELOW, etc...), returns a table of target locations
 checkTree(source,pos,argument,relation,verbose) - Various checks for whether there is a tree at the specified position, returns true/false
 checkPlant(source,pos,argument,relation,verbose) - Various checks for whether there is a plant at the specified position, returns true/false
 checkGrass(source,pos,argument,relation,verbose) - Various checks for whether there is grass at the specified position, returns true/false
 checkInorganic(source,pos,argument,relation,verbose) - Various checks for whether there is an inorganic at the specified position, returns true/false
 checkLiquid(source,pos,argument,relation,verbose) - Various checks for whether there is liquid at the specified position, returns true/false
 isSelectedLocation(source,pos,args) - The wrapper function for location based checks, calls all the various checks (not the base)

 checkTarget(source,targetList,target,verbose) - Base check for unit based checks, compares the relative relationship between the source and target (e.g. ENEMY, PET, etc...), returns a table of target units
 checkUnitLocation(source,radius,verbose) - Checks if the unit is within a specified distance of the source unit
 checkAttribute(source,unit,args.maxAttribute,relation,args.verbose) - Various checks for a units attributes, returns true/false
 checkSkill(source,unit,args.maxSkill,relation,args.verbose) - Various checks for a units skill, returns true/false
 checkTrait(source,unit,args.maxTrait,relation,args.verbose) - Various checks for a units trait, returns true/false
 checkAge(source,unit,args.maxAge,relation,args.verbose) - Various checks for a units age, returns true/false
 checkSpeed(source,unit,args.gtSpeed,relation,args.verbose) - Various checks for a units speed, returns true/false
 checkClass(source,unit,args.requiredClass,relation,args.verbose) - Various checks for a units SYN_CLASS and CREATURE_CLASS, returns true/false
 checkCreature(source,unit,args.requiredCreature,relation,args.verbose) - Various checks for a units race and caste, returns true/false
 checkSyndrome(source,unit,args.requiredSyndrome,relation,args.verbose) - Various checks for a units syndromes, returns true/false
 checkToken(source,unit,args.requiredToken,relation,args.verbose) - Various checks for a units tokens, returns true/false
 checkNoble(source,unit,args.requiredNoble,relation,args.verbose) - Various checks for a units noble position, returns true/false
 checkProfession(source,unit,args.requiredProfesion,relation,args.verbose) - Various checks for a units profession, returns true/false
 checkEntity(source,unit,args.requiredEntity,relation,args.verbose) - Various checks for a units entity, returns true/false
 checkPathing(source,unit,args.requiredPathing,relation,args.verbose) - Various checks for a units pathing, returns true/false
 isSelectedUnit(source,target,args) - The wrapper function for unit based checks, calls all the various checks (not the base)
 
 checkItem(source,targetList,target,verbose) - Base check for item based checks, compares the items to various targets (e.g. ARTIFACT, PROJECTILE, etc...), returns a table of target items
 checkItemLocation(center,radius,verbose) - Checks if the item is within a specified distance of the center location
 checkItemType(source,pos,args.requiredItem,relation,args.verbose) - Various checks for an items type, returns true/false
 checkMaterial(source,pos,args.requiredMaterial,relation,args.verbose) - Various checks for an items material, returns true/false
 checkCorpse(source,pos,args.requiredCorpse,relation,args.verbose) - Various checks for if an item is a corpse, returns true/false
 isSelectedItem(source,item,args) - The wrapper function for item based checks, calls all the various checks (not the base)

 getValue(equation,target,source,center,targetList,selected,verbose) - Get the value of an equation, this function is old and will be replaced by functions/misc.fillEquation
]]
---------------------------------------------------------------------------------------------
-- position based checks and conditions
---- get list of positions meeting major criteria of -checkLocation
function checkPosition(source,targetList,target,verbose) -- checks list of positions for major condition
 if not target then target = 'all' end
 n = 0
 list = {}
 target = string.upper(target)
 for i,pos in pairs(targetList) do
  block = dfhack.maps.ensureTileBlock(pos)
  occupancy = block.occupancy[pos.x%16][pos.y%16]
  designation = block.designation[pos.x%16][pos.y%16]
  tiletype = dfhack.maps.getTileType(pos)
  type_mat = df.tiletype_material[df.tiletype.attrs[tiletype].material]
  if target == 'ABOVE' then
   if pos.z > source.pos.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'BELOW' then
   if pos.z < source.pos.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'LEVEL' then
   if pos.z == source.pos.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'LEVELABOVE'then
   if pos.z >= source.pos.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'LEVELBELOW' then
   if pos.z <= source.pos.z then
    n = n + 1
    list[n] = pos
   end
  elseif target == 'NOTLEVEL' then
   if not pos.z == source.pos.z then
    n = n + 1
    list[n] = pos
   end
  else
   n = #targetList
   list = targetList
   break
  end
 end
 return list,n
end

---- check individual positions for targeting criteria
function checkTree(source,pos,argument,relation,verbose) -- checks for a tree at target position
 tiletype = dfhack.maps.getTileType(pos)
 type_mat = df.tiletype_material[df.tiletype.attrs[tiletype].material]
 if type_mat ~= 'TREE' then
  if relation == 'required' then
   return false
  elseif relation == 'forbidden' then
   return true
  end
 end
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  arg = string.upper(arg)
  if arg == 'ANY' then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end   
  else
   tree_mat = dfhack.script_environment('functions/map').getTreeMaterial(pos)
   if tree_mat.plant.id == arg then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end
   end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

function checkPlant(source,pos,argument,relation,verbose) -- checks for a plant at target position
 tiletype = dfhack.maps.getTileType(pos)
 type_mat = df.tiletype_material[df.tiletype.attrs[tiletype].material]
 if type_mat ~= 'PLANT' then
  if relation == 'required' then
   return false
  elseif relation == 'forbidden' then
   return true
  end
 end
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  arg = string.upper(arg)
  if arg == 'ANY' then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end   
  else
   shrub_mat = dfhack.script_environment('functions/map').getShrubMaterial(pos)
   if shrub_mat.plant.id == arg then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end
   end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

function checkGrass(source,pos,argument,relation,verbose) -- checks for grass at target position
 tiletype = dfhack.maps.getTileType(pos)
 type_mat = df.tiletype_material[df.tiletype.attrs[tiletype].material]
 if type_mat ~= 'GRASS_LIGHT' and type_mat ~= 'GRASS_DARK' and type_mat ~= 'GRASS_DEAD' and type_mat ~= 'GRASS_DRY' then
  if relation == 'required' then
   return false
  elseif relation == 'forbidden' then
   return true
  end
 end
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  arg = string.upper(arg)
  if arg == 'ANY' then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end   
  else
   grass_mat = dfhack.script_environment('functions/map').getGrassMaterial(pos)
   if grass_mat.plant.id == arg then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end
   end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

function checkInorganic(source,pos,argument,relation,verbose) -- not done
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

function checkFlow(source,pos,argument,relation,verbose) -- checks for flow at given position
 flow,flowtype = dfhack.script_environment('functions/map').getFlow(pos)
 if not flow then
  if relation == 'required' then
   return false
  elseif relation == 'forbidden' then
   return true
  end
 end
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  arg = string.upper(arg)
  if arg == 'ANY' then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end   
  else
   if arg == flowtype then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end
   end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

function checkLiquid(source,pos,argument,relation,verbose) -- checks for liquid at given position
 liquidtype = string.upper(argument)
 block = dfhack.maps.ensureTileBlock(pos)
 designation = block.designation[pos.x%16][pos.y%16]
 if liquidtype == 'ANY' then
  if designation.flow_size > 0 then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end
  end
 elseif liquidtype == 'WATER' then
  if designation.flow_size > 0 and not designation.liquid_type then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end
  end
 elseif liquidtype == 'MAGMA' then
  if designation.flow_size > 0 and designation.liquid_type then
   if relation == 'required' then
    return true
   elseif relation == 'forbidden' then
    return false
   end
  end 
 end
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

---- base call for all position targeting checks
function isSelectedLocation(source,pos,args)
 local selected = true
 if args.test then test = true end
 
 if args.requiredTree and (selected or test) then
  selected = checkTree(source,pos,args.requiredTree,'required',args.verbose)
 end
 if args.forbiddenTree and (selected or test) then
  selected = checkTree(source,pos,args.forbiddenTree,'forbidden',args.verbose)
 end
 
 if args.requiredPlant and (selected or test) then
  selected = checkPlant(source,pos,args.requiredPlant,'required',args.verbose)
 end
 if args.forbiddenPlant and (selected or test) then
  selected = checkPlant(source,pos,args.forbiddenPlant,'forbidden',args.verbose)
 end
 
 if args.requiredGrass and (selected or test) then
  selected = checkTree(source,pos,args.requiredGrass,'required',args.verbose)
 end
 if args.forbiddenGrass and (selected or test) then
  selected = checkGrass(source,pos,args.forbiddenGrass,'forbidden',args.verbose)
 end
 
 if args.requiredInorganic and (selected or test) then
  selected = checkInorganic(source,pos,args.requiredInorganic,'required',args.verbose)
 end
 if args.forbiddenInorganic and (selected or test) then
  selected = checkInorganic(source,pos,args.forbiddenInorganic,'forbidden',args.verbose)
 end

 if args.requiredFlow and (selected or test) then
  selected = checkFlow(source,pos,args.requiredFlow,'required',args.verbose)
 end
 if args.forbiddenFlow and (selected or test) then
  selected = checkFlow(source,pos,args.forbiddenFlow,'forbidden',args.verbose)
 end
 
 if args.requiredLiquid and (selected or test) then
  selected = checkLiquid(source,pos,args.requiredLiquid,'required',args.verbose)
 end
 if args.forbiddenLiquid and (selected or test) then
  selected = checkLiquid(source,pos,args.forbiddenLiquid,'forbidden',args.verbose)
 end
 
 return selected
end

-- unit based checks and conditions
---- get list of units meeting major criteria of location and -checkUnit
function checkUnitLocation(center,radius,verbose) -- checks for units within radius of center
 if radius then
  rx = tonumber(radius.x) or tonumber(radius[1]) or 0
  ry = tonumber(radius.y) or tonumber(radius[2]) or 0
  rz = tonumber(radius.z) or tonumber(radius[3]) or 0
 else
  rx = 0
  ry = 0
  rz = 0
 end
 local targetList = {}
 local selected = {}
 n = 1
 unitList = df.global.world.units.active
 if rx < 0 and ry < 0 and rz < 0 then
  targetList[n] = center
 else
  local xmin = center.pos.x - rx
  local ymin = center.pos.y - ry
  local zmin = center.pos.z - rz
  local xmax = center.pos.x + rx
  local ymax = center.pos.y + ry
  local zmax = center.pos.z + rz
  targetList[n] = center
  for i,unit in ipairs(unitList) do
   if unit.pos.x <= xmax and unit.pos.x >= xmin and unit.pos.y <= ymax and unit.pos.y >= ymin and unit.pos.z <= zmax and unit.pos.z >= zmin and unit ~= center then
    n = n + 1
	targetList[n] = unit
   end
  end
 end
 return targetList,n
end

function checkTarget(source,targetList,target,verbose) -- checks list of units for major condition
 if not target then target = 'all' end
 n = 0
 list = {}
 target == string.upper(target)
 for i,unit in pairs(targetList) do
  if target == 'ENEMY' then
   if unit.invasion_id > 0 then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'FRIENDLY' then
   if unit.invasion_id == -1 and unit.civ_id ~= -1 then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'CIV' then
   if source.civ_id == unit.civ_id then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'RACE' then
   if source.race == unit.race then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'CASTE' then
   if source.race == unit.race and source.caste == unit.caste then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'GENDER' then
   if source.sex == unit.sex then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'WILD' then
   if unit.training_level == 9 and unit.civ_id == -1 then
    n = n + 1
    list[n] = unit
   end
  elseif target == 'DOMESTIC' then
   if unit.training_level == 7 and unit.civ_id == source.civ_id then
    n = n + 1
    list[n] = unit
   end
  else
   n = #targetList
   list = targetList
   break
  end
 end
 return list,n
end

---- check individual units for targeting criteria
function checkAge(source,target,argument,relation,verbose) -- checks age of target unit
 local selected = true
 sage = dfhack.units.getAge(source)
 tage = dfhack.units.getAge(target)
 value = tonumber(argument)
 if relation == 'max' then
  if tage > value then return false end
 elseif relation == 'min' then
  if tage < value then return false end
 elseif relation == 'greater' then
  if tage/sage < value then return false end
 elseif relation == 'less' then
  if sage/tage < value then return false end
 end
 return selected
end

function checkAttribute(source,target,argument,relation,verbose) -- checks attributes of target unit
 local utils = require 'utils'
 local split = utils.split_string
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  attribute = split(x,':')[1]
  value = tonumber(split(x,':')[2])
  sattribute = dfhack.script_environment('functions/unit').getUnit(source,'Attributes',attribute)
  tattribute = dfhack.script_environment('functions/unit').getUnit(target,'Attributes',attribute)
  if relation == 'max' then
   if tattribute > value then return false end
  elseif relation == 'min' then
   if tattribute < value then return false end
  elseif relation == 'greater' then
   if tattribute/sattribute < value then return false end
  elseif relation == 'less' then
   if sattribute/tattribute < value then return false end
  end
 end
 return true
end

function checkClass(source,target,argument,relation,verbose) -- checks classes (creature and sndrome) of target unit
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = dfhack.script_environment('functions/unit').checkClass(target,x)
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkCreature(source,target,argument,relation,verbose) -- checks creature and caste of target unit
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = dfhack.script_environment('functions/unit').checkCreatureRace(target,x)
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkEntity(source,target,argument,relation,verbose) -- checks entity of target unit
-- sentity = df.global.world.entities[source.civ_id].entity_raw.code
 if target.civ_id < 0 then return false end
 tentity = df.global.world.entities[target.civ_id].entity_raw.code
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = x == tentity
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkNoble(source,target,argument,relation,verbose) -- checks noble positions of target unit
-- snoble = dfhack.units.getNoblePositions(source)
 tnoble = dfhack.units.getNoblePositions(target)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  if tnoble then
   for j,y in pairs(tnoble) do
    position = y.position.code
    selected = position == x
    if relation == 'required' then
	 if selected then return true end
    elseif relation == 'immune' then
     if selected then return false end
    end
   end
  else
   if relation == 'required' then
    return false
   elseif relation == 'immune' then
    return true
   end   
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkPathing(source,target,argument,relation,verbose) -- checks pathing of target unit
 tgoal = target.path.goal
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  n = df.unit_path_goal[x]
  selected = n == tgoal
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkProfession(source,target,argument,relation,verbose) -- checks profession of target unit
-- sprof = source.profession
 tprof = target.profession
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  n = df.profession[x]
  selected = n == tprof
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkSkill(source,target,argument,relation,verbose) -- checks skills of target unit
 local utils = require 'utils'
 local split = utils.split_string
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  skill = split(x,':')[1]
  value = tonumber(split(x,':')[2])
  sskill = dfhack.script_environment('functions/unit').getUnit(source,'Skills',skill)
  tskill = dfhack.script_environment('functions/unit').getUnit(target,'Skills',skill)
  if relation == 'max' then
   if tskill > value then return false end
  elseif relation == 'min' then
   if tskill < value then return false end
  elseif relation == 'greater' then
   if tskill/sskill < value then return false end
  elseif relation == 'less' then
   if sskill/tskill < value then return false end
  end
 end
 return true
end

function checkSpeed(source,target,argument,relation,verbose) -- checks speed of target unit (using dfhack.units.computeMovementSpeed())
 sspeed = dfhack.units.computeMovementSpeed(source)
 tspeed = dfhack.units.computeMovementSpeed(target)
 value = tonumber(argument)
 if relation == 'max' then
  if tspeed > value then return false end
 elseif relation == 'min' then
  if tspeed < value then return false end
 elseif relation == 'greater' then
  if tspeed/sspeed < value then return false end
 elseif relation == 'less' then
  if sspeed/tspeed < value then return false end
 end
 return true
end

function checkSyndrome(source,target,argument,relation,verbose) -- checks syndromes (names) of target unit
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = dfhack.script_environment('functions/unit').checkCreatureSyndrome(target,x)
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkToken(source,target,argument,relation,verbose) -- checks tokens of target unit (e.g. MEGABEAST, FLIER, etc...)
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in ipairs(argument) do
  selected = dfhack.script_environment('functions/unit').checkCreatureToken(target,x)
  if relation == 'required' then   
   if selected then return true end
  elseif relation == 'immune' then
   if selected then return false end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'immune' then
  return true
 end
end

function checkTrait(source,target,argument,relation,verbose) -- checks traits of target unit
 local utils = require 'utils'
 local split = utils.split_string
 if type(argument) ~= 'table' then argument = {argument} end
 for i,x in pairs(argument) do
  trait = split(x,':')[1]
  value = tonumber(split(x,':')[2])
  strait = dfhack.script_environment('functions/unit').getUnit(source,'Traits',trait)
  ttrait = dfhack.script_environment('functions/unit').getUnit(target,'Traits',trait)
  if relation == 'max' then
   if ttrait > value then return false end
  elseif relation == 'min' then
   if ttrait < value then return false end
  elseif relation == 'greater' then
   if ttrait/strait < value then return false end
  elseif relation == 'less' then
   if strait/ttrait < value then return false end
  end
 end
 return true
end

---- base call for all unit targeting checks
function isSelectedUnit(source,unit,args)
 local selected = true
 if args.test then test = true end

 if args.maxAttribute and (selected or test) then
  selected = checkAttribute(source,unit,args.maxAttribute,'max',args.verbose)
 end
 if args.minAttribute and (selected or test) then
  selected = checkAttribute(source,unit,args.minAttribute,'min',args.verbose)
 end
 if args.gtAttribute and (selected or test) then
  selected = checkAttribute(source,unit,args.gtAttribute,'greater',args.verbose)
 end
 if args.ltAttribute and (selected or test) then
  selected = checkAttribute(source,unit,args.ltAttribute,'less',args.verbose)
 end
 
 if args.maxSkill and (selected or test) then
  selected = checkSkill(source,unit,args.maxSkill,'max',args.verbose)
 end
 if args.minSkill and (selected or test) then
  selected = checkSkill(source,unit,args.minSkill,'min',args.verbose)
 end
 if args.gtSkill and (selected or test) then
  selected = checkSkill(source,unit,args.gtSkill,'greater',args.verbose)
 end
 if args.ltSkill and (selected or test) then
  selected = checkSkill(source,unit,args.ltSkill,'less',args.verbose)
 end
 
 if args.maxTrait and (selected or test) then
  selected = checkTrait(source,unit,args.maxTrait,'max',args.verbose)
 end
 if args.mintrait and (selected or test) then
  selected = checkTrait(source,unit,args.minTrait,'min',args.verbose)
 end
 if args.gtTrait and (selected or test) then
  selected = checkTrait(source,unit,args.gtTrait,'greater',args.verbose)
 end
 if args.ltTrait and (selected or test) then
  selected = checkTrait(source,unit,args.ltTrait,'less',args.verbose)
 end
 
 if args.maxAge and (selected or test) then
  selected = checkAge(source,unit,args.maxAge,'max',args.verbose)
 end
 if args.minAge and (selected or test) then
  selected = checkAge(source,unit,args.minAge,'min',args.verbose)
 end
 if args.gtAge and (selected or test) then
  selected = checkAge(source,unit,args.gtAge,'greater',args.verbose)
 end
 if args.ltAge and (selected or test) then
  selected = checkAge(source,unit,args.ltAge,'less',args.verbose)
 end
 
 if args.maxSpeed and (selected or test) then
  selected = checkSpeed(source,unit,args.maxSpeed,'max',args.verbose)
 end
 if args.minSpeed and (selected or test) then
  selected = checkSpeed(source,unit,args.minSpeed,'min',args.verbose)
 end
 if args.gtSpeed and (selected or test) then
  selected = checkSpeed(source,unit,args.gtSpeed,'greater',args.verbose)
 end
 if args.ltSpeed and (selected or test) then
  selected = checkSpeed(source,unit,args.ltSpeed,'less',args.verbose)
 end
 
 if args.requiredClass and (selected or test) then
  selected = checkClass(source,unit,args.requiredClass,'required',args.verbose)
 end 
 if args.immuneClass and (selected or test) then
  selected = checkClass(source,unit,args.immuneClass,'immune',args.verbose)
 end 
 
 if args.requiredCreature and (selected or test) then
  selected = checkCreature(source,unit,args.requiredCreature,'required',args.verbose)
 end 
 if args.immuneCreature and (selected or test) then
  selected = checkCreature(source,unit,args.immuneCreature,'immune',args.verbose)
 end
 
 if args.requiredSyndrome and (selected or test) then
  selected = checkSyndrome(source,unit,args.requiredSyndrome,'required',args.verbose)
 end 
 if args.immuneSyndrome and (selected or test) then
  selected = checkSyndrome(source,unit,args.immuneSyndrome,'immune',args.verbose)
 end

 if args.requiredToken and (selected or test) then
  selected = checkToken(source,unit,args.requiredToken,'required',args.verbose)
 end 
 if args.immuneToken and (selected or test) then
  selected = checkToken(source,unit,args.immuneToken,'immune',args.verbose)
 end
 
 if args.requiredNoble and (selected or test) then
  selected = checkNoble(source,unit,args.requiredNoble,'required',args.verbose)
 end 
 if args.inoble and (selected or test) then
  selected = checkNoble(source,unit,args.inoble,'immune',args.verbose)
 end
 
 if args.requiredProfesion and (selected or test) then
  selected = checkProfession(source,unit,args.requiredProfesion,'required',args.verbose)
 end 
 if args.immuneProfession and (selected or test) then
  selected = checkProfession(source,unit,args.immuneProfession,'immune',args.verbose)
 end
 
 if args.requiredEntity and (selected or test) then
  selected = checkEntity(source,unit,args.requiredEntity,'required',args.verbose)
 end 
 if args.immuneEntity and (selected or test) then
  selected = checkEntity(source,unit,args.immuneEntity,'immune',args.verbose)
 end

 if args.requiredPathing and (selected or test) then
  selected = checkPathing(source,unit,args.requiredPathing,'required',args.verbose)
 end 
 if args.immunePathing and (selected or test) then
  selected = checkPathing(source,unit,args.immunePathing,'immune',args.verbose)
 end 
 
 return selected
end

-- item based checks and conditions ----
function checkItemLocation(center,radius,verbose) -- checks for units within radius of center
 if radius then
  rx = tonumber(radius.x) or tonumber(radius[1]) or 0
  ry = tonumber(radius.y) or tonumber(radius[2]) or 0
  rz = tonumber(radius.z) or tonumber(radius[3]) or 0
 else
  rx = 0
  ry = 0
  rz = 0
 end
 local targetList = {}
 local selected = {}
 n = 0
 itemList = df.global.world.items.all
 if rx < 0 and ry < 0 and rz < 0 then
  return targetList, n
 else
  local xmin = center.x - rx
  local ymin = center.y - ry
  local zmin = center.z - rz
  local xmax = center.x + rx
  local ymax = center.y + ry
  local zmax = center.z + rz
  for i,item in ipairs(itemList) do
   pos = {}
   pos.x, pos.y, pos.z = dfhack.items.getPosition(item)
   if pos.x <= xmax and pos.x >= xmin and pos.y <= ymax and pos.y >= ymin and pos.z <= zmax and pos.z >= zmin then
    n = n + 1
	targetList[n] = item
   end
  end
 end
 return targetList,n
end

function checkItem(source,targetList,target,verbose) -- check list of items for major condition
 if not target then target = 'all' end
 n = 0
 list = {}
 target == string.upper(target)
 for i,item in pairs(targetList) do
  if target == 'INVENTORY' then
   if item.flags.in_inventory then
    n = n + 1
    list[n] = item
   end
  elseif target == 'ONGROUND' then
   if item.flags.on_ground then
    n = n + 1
    list[n] = item
   end
  elseif target == 'ARTIFACT' then
   if item.flags.artifact then
    n = n + 1
    list[n] = item
   end
  elseif target == 'ONFIRE' then
   if item.flags.on_fire then
    n = n + 1
    list[n] = item
   end
  elseif target == 'PROJECTILE' then
   if dfhack.items.getGeneralRef(item,df.general_ref_type['PROJECTILE']) then
    n = n + 1
    list[n] = item
   end
  else
   n = #targetList
   list = targetList
   break
  end
 end
 return list,n
end

function checkItemType(source,item,argument,relation,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  temp = string.upper(arg)
  splitArg = split(temp,':')
  if #splitArg = 1 then
   if item:getType() == dfhack.items.findType(temp) then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  elseif #splitArg = 2 then
   if item:getType() == dfhack.items.findType(temp) and item:getSubtype() == dfhack.items.findSubType(temp) then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

function checkMaterial(source,item,argument,relation,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  temp = string.upper(arg)
  splitArg = split(temp,':')
  if #splitArg = 1 then
   if item.mat_type() == dfhack.matinfo.find(temp)['type'] then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  elseif #splitArg = 2 then
   if item.mat_type() == dfhack.matinfo.find(temp)['type'] and item.mat_index() == dfhack.matinfo.find(temp)['index'] then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end

function checkCorpse(source,item,argument,relation,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 if not df.item_corpsest:is_instance(item) then
  if relation == 'required' then
   return false
  elseif relation == 'forbidden' then
   return true
  end
 end
 if type(argument) ~= 'table' then argument = {argument} end
 for i,arg in ipairs(argument) do
  temp = string.upper(arg)
  splitArg = split(temp,':')
  if #splitArg = 1 then
   if df.global.world.raws.creatures.all[item.race].creature_id == splitArg[1] then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  elseif #splitArg = 2 then
   if df.global.world.raws.creatures.all[item.race].creature_id == splitArg[1] and df.global.world.raws.creatures.all[item.race].caste[item.caste].caste_id == splitArg[2] then
    if relation == 'required' then
     return true
    elseif relation == 'forbidden' then
     return false
    end      
   end
  end
 end
 if relation == 'required' then
  return false
 elseif relation == 'forbidden' then
  return true
 end
end


function isSelectedItem(source,item,args)
 local selected = true
 if args.test then test = true end
 
 if args.requiredItem and (selected or test) then
  selected = checkItemType(source,pos,args.requiredItem,'required',args.verbose)
 end
 if args.forbiddenItem and (selected or test) then
  selected = checkItemType(source,pos,args.forbiddenItem,'forbidden',args.verbose)
 end

 if args.requiredMaterial and (selected or test) then
  selected = checkMaterial(source,pos,args.requiredMaterial,'required',args.verbose)
 end
 if args.forbiddenMaterial and (selected or test) then
  selected = checkMaterial(source,pos,args.forbiddenMaterial,'forbidden',args.verbose)
 end

 if args.requiredCorpse and (selected or test) then
  selected = checkCorpse(source,pos,args.requiredCorpse,'required',args.verbose)
 end
 if args.forbiddenCorpse and (selected or test) then
  selected = checkCorpse(source,pos,args.forbiddenCorpse,'forbidden',args.verbose)
 end

 return selected
end

function getValue(equation,target,source,center,targetList,selected,verbose)
 local utils = require 'utils'
 local split = utils.split_string
 
 check = {'source','SOURCE','target','TARGET'}
 for _,unit in pairs(check) do
  if unit == 'SOURCE' or unit == 'source' then unitID = source.id end
  if unit == 'TARGET' or unit == 'target' then unitID = target.id end
  while equation:find(unit) do
   look = string.match(equation..'+',unit..".(.-)[+%-*/]")
   array = split(look,"%.")
   if string.upper(array[1]) == 'ATTRIBUTE' then
    total = dfhack.script_environment('functions/unit').trackAttribute(unitID,string.upper(array[2]),nil,nil,nil,nil,"get")
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   elseif string.upper(array[1]) == 'SKILL' then
    total = dfhack.script_environment('functions/unit').trackSkill(unitID,string.upper(array[2]),nil,nil,nil,nil,"get")
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   elseif string.upper(array[1]) == 'TRAIT' then
    total = dfhack.script_environment('functions/unit').trackTrait(unitID,string.upper(array[2]),nil,nil,nil,nil,"get")
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   elseif string.upper(array[1]) == 'COUNTER' then
    total = dfhack.script_environment('functions/unit').getCounter(unitID,string.lower(array[2]))
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   elseif string.upper(array[1]) == 'RESISTANCE' then
    total = dfhack.script_environment('functions/unit').trackResistance(unitID,look,nil,nil,nil,nil,"get")
    equation = equation:gsub(string.match(equation..'+',"("..unit..".-)[+%-*/]"),tostring(total))
   end
  end
 end
 
 equals = assert(load("return "..equation))
 value = equals()
 return value
end


--scripts/modtools/building-trigger.lua
--author expwnent (outsideonly) modified to building-trigger by Roses
--enables various restrictions on buildings

local eventful = require 'plugins.eventful'
local utils = require 'utils'

buildingLocation = buildingLocation or utils.invert({'EITHER','OUTSIDE_ONLY','INSIDE_ONLY'})
buildingLiquid = buildingLiquid or utils.invert({'EITHER','MAGMA','WATER'})
registeredBuildings = registeredBuildings or {}
checkEvery = checkEvery or 100
timeoutId = timeoutId or nil

eventful.enableEvent(eventful.eventType.UNLOAD,1)
eventful.onUnload.outsideOnly = function()
 registeredBuildings = {}
 checkEvery = 100
 timeoutId = nil
end

local function destroy(building)
 if #building.jobs > 0 and building.jobs[0] and building.jobs[0].job_type == df.job_type.DestroyBuilding then
  return
 end
 local b = dfhack.buildings.deconstruct(building)
 if b then
  --TODO: print an error message to the user so they know
  return
 end
-- building.flags.almost_deleted = 1
end

local function checkBuildings()
 local toDestroy = {}
 local function forEach(building)
  local ok = false
  if building:getCustomType() < 0 then
   --TODO: support builtin building types if someone wants
   print('vanilla buildings not currently supported')
   return
  end
  local pos = df.coord:new()
  pos.x = building.centerx
  pos.y = building.centery
  pos.z = building.z
  local outside = dfhack.maps.getTileBlock(pos).designation[pos.x%16][pos.y%16].outside
  local def = df.global.world.raws.buildings.all[building:getCustomType()]
  local blocation = registeredBuildings[def.code].location
  local bnumber = registeredBuildings[def.code].number
  local bliquid = registeredBuildings[def.code].liquid
  local bscript = registeredBuildings[def.code].script
  if btype then
--   print('outside: ' .. outside==true .. ', type: ' .. btype)
  end

  if not blocation and not bnumber and not bliquid then
   registeredBuildings[def.code] = nil
   of = true
  end
  
  if blocation == buildingLocation.EITHER then
   of = true
  elseif blocation == buildingLocation.OUTSIDE_ONLY then
   if outside then
    ok = true
   end
  else
   if not outside then
    ok = true
   end
  end
  if bnumber then
   local number = 0
   for _,k in ipairs(df.global.world.buildings.all) do
    if k.custom_type == building.custom_type then number = number + 1 end
   end
   if bnumber > number then ok = true end
  end
  if bliquid then
   for i = building.x1-1,building.x2+1,1 do
    for j = building.y1-1,building.y2+1,1 do
	 local designation = dfhack.maps.getTileBlock(i,j,building.z-1).designation[i%16][j%16]
	 if designation.flow_size > 3 then
	  if bliquid == buildingLiquid.EITHER then
	   ok = true
	  elseif bliquid == buildingLiquid.MAGMA then
	   if designation.liquid_type then
	    ok = true
	   end
	  else
	   if not designation.liquid_type then
	    ok = true
	   end
	  end
	 end
	end
   end
  end
  if ok then
   if bscript then
    dfhack.run_script(bscript)
    return
   else
    return
  else	
   table.insert(toDestroy,building)
  end
 end
 for _,building in ipairs(df.global.world.buildings.all) do
  forEach(building)
 end
 for _,building in ipairs(toDestroy) do
  destroy(building)
 end
 if timeoutId then
  dfhack.timeout_active(timeoutId,nil)
  timeoutId = nil
 end
 timeoutId = dfhack.timeout(checkEvery, 'ticks', checkBuildings)
end

eventful.enableEvent(eventful.eventType.BUILDING, 100)
eventful.onBuildingCreatedDestroyed.outsideOnly = function(buildingId)
 checkBuildings()
end

validArgs = validArgs or utils.invert({
 'help',
 'clear',
 'checkEvery',
 'building',
 'location''
 'number',
 'liquid',
})
local args = utils.processArgs({...}, validArgs)
if args.help then
 print([[scripts/modtools/building-trigger
arguments
    -help
        print this help message
    -clear
        clears the list of registered buildings
    -checkEvery n
        set how often existing buildings are checked for whether they are in the appropriate location to n ticks
    -location [EITHER, OUTSIDE_ONLY, INSIDE_ONLY]
        specify what sort of location restriction to put on the building
    -liquid [EITHER, MAGMA, WATER]
        specify what sort of liquid restriction to put on the building
    -number #
        specify maximum number of buildings of this type allowed
    -building name
        specify the id of the building
	-script [ command line entry ]
	    script to be run when building is built
]])
 return
end

if args.clear then
 registeredBuildings = {}
end

if args.checkEvery then
 if not tonumber(args.checkEvery) then
  error('Invalid checkEvery.')
 end
 checkEvery = tonumber(args.checkEvery)
end

if not args.building then
 return
end

if not args.location and not args.number and not args.liquid then
 print 'building-trigger: please specify some type'
 return
end

if not buildingLocation[args.location] then
 error('Invalid location type: ' .. args.location)
 return
end
if not buildingLiquid[args.liquid] then
 error('Invalid liquid type: ' .. args.liquid)
 return
end
registeredBuildings[args.building] = {}
if args.location then registeredBuildings[args.building].location = buildingLocation[args.location] end
if args.liquid then registeredBuildings[args.building].liquid = buildingLiquid[args.liquid] end
registeredBuildings[args.building].number = args.number
registeredBuildings[args.building].script = args.script

checkBuildings()


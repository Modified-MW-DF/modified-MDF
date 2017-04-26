--teleport.lua v1.0
--[[
teleport - moves a unit and/or item from one point to another, multiple locations accepted
	type - the type of thing to teleport
		unit - teleports all units in a radius (includes equiped items)
		item - teleports all items in a radius (does not include equiped items)
		both - teleports all units and items in a radius
	ID # - the target units id number
		\UNIT_ID - when triggering with a syndrome
		\WORKER_ID - when triggering with a reaction
	direction - where it teleports the items/units
		1******* - teleports to the building TELEPORT_1
		2******* - teleports to the building TELEPORT_2
		target - teleports to the target unit
		self**,****** - teleports to the origin unit
		idle - teleports to a random idle location on the map
		building - teleports to random buildings
			workshop - teleports to a random workshop
			furnace - teleports to a random furnace
			CUSTOM_BUILDING_TOKEN - teleports to a random specific building
		room - teleports to a random room on the map
	radius - teleports all items/units in a given radius, corresponding to x, y, and z
		#/#/#
	(OPTIONAL) ID # - the origin units id number, required for the relative propel type
EXAMPLE: teleport unit \WORKER_ID 1 10/10/0
--]]

args={...}

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function isSelected(unit,Target,rx,ry,rz)
	local pos = Target.pos

	local mapx, mapy, mapz = dfhack.maps.getTileSize()
	local xmin = unit.pos.x - rx
	local xmax = unit.pos.x + rx
	local ymin = unit.pos.y - ry
	local ymax = unit.pos.y + ry
	local zmin = unit.pos.z
	local zmax = unit.pos.z + rz
	if xmin < 1 then xmin = 1 end
	if ymin < 1 then ymin = 1 end
	if xmax > mapx then xmax = mapx-1 end
	if ymax > mapy then ymax = mapy-1 end
	if zmax > mapz then zmax = mapz-1 end

	if pos.x < xmin or pos.x > xmax then return false end
	if pos.y < ymin or pos.y > ymax then return false end
	if pos.z < zmin or pos.z > zmax then return false end

	return true
end

local ttype = args[1]
local unit = df.unit.find(tonumber(args[2]))
local dir = args[3]
local radius = args[4]
local self = df.unit.find(tonumber(args[2]))
if #args == 5 then self = df.unit.find(tonumber(args[5])) end
local radiusa = split(radius,'/')
local rx = tonumber(radiusa[1])
local ry = tonumber(radiusa[2])
local rz = tonumber(radiusa[3])
local locx,locy,locz = 0,0,0

if dir == '1' or dir == '2' then
	pers,status = dfhack.persistent.get('teleport')
	if dir == '1' and pers.ints[7] == 1 then
		locx = pers.ints[1]
		locy = pers.ints[2]
		locz = pers.ints[3]
	elseif dir == '2' and pers.ints[7] == 1 then
		locx = pers.ints[4]
		locy = pers.ints[5]
		locz = pers.ints[6]
	end
elseif dir == 'target' or dir == 'self' then
	if dir == 'target' then
		locx = unit.pos.x
		locy = unit.pos.y
		locz = unit.pos.z
	else
		if unit == self then print('No valid !SELF unit, using target instead') end
		locx = self.pos.x
		locy = self.pos.y
		locz = self.pos.z
	end
else
	local array = {}
	local a = 1
	local dira = split(dir,'/')
	if dira[1] == 'idle' then
		local unitList = df.global.world.units.active
		for i,x in ipairs(unitList) do
			if x.idle_area.x > 0 then
				array[a] = tostring(x.idle_area.x)..'_'..tostring(x.idle_area.y)..'_'..tostring(x.idle_area.z)
				a = a + 1
			end
		end
	elseif dira[1] == 'building' then
		local bldgList = df.global.world.buildings.all
		for i,bldg in ipairs(bldgList) do
			if dira[2] == 'workshop' then
				if df.building_workshopst:is_instance(bldg) then
					array[a] = tostring(bldg.centerx)..'_'..tostring(bldg.centery)..'_'..tostring(bldg.z)
					a = a + 1
				end
			elseif dira[2] == 'furnace' then
				if df.building_furnacest:is_instance(bldg) then
					array[a] = tostring(bldg.centerx)..'_'..tostring(bldg.centery)..'_'..tostring(bldg.z)
					a = a + 1
				end
			else
				if df.building_workshopst:is_instance(bldg) or df.building_furnacest:is_instance(bldg) then
					local btype = bldg.custom_type
					local all_bldgs = df.global.world.raws.buildings.all
					if btype >= 0 then
						if all_bldgs[btype].code == dira[2] then
							array[a] = tostring(bldg.centerx)..'_'..tostring(bldg.centery)..'_'..tostring(bldg.z)
							a = a + 1
						end
					end
				end
			end
		end
	elseif dira[1] == 'room' then
		local bldgList = df.global.world.buildings.all
		for i,bldg in ipairs(bldgList) do
			if bldg.is_room then
				array[a] = tostring(bldg.centerx)..'_'..tostring(bldg.centery)..'_'..tostring(bldg.z)
				a = a + 1
			end
		end
	else
		print('No valid teleport location specified, aborting')
	end
	if #array > 0 then
		local rando = dfhack.random.new()
		local roll = rando:random(#array)+1
		locx = tonumber(split(array[roll],'_')[1])
		locy = tonumber(split(array[roll],'_')[2])
		locz = tonumber(split(array[roll],'_')[3])
	end
end

if locx <= 0 or locy <= 0 or locz <= 0 or locx == nil then
	print('No valid teleport location found, aborting')
	return
end

if ttype == 'unit' or ttype == 'both' then
	local unitList = df.global.world.units.active
	for i = #unitList - 1, 0, -1 do
		local unitTarget = unitList[i]
		if isSelected(unit,unitTarget,rx,ry,rz) then
			local unitoccupancy = dfhack.maps.getTileBlock(unitTarget.pos).occupancy[unitTarget.pos.x%16][unitTarget.pos.y%16]
			unitTarget.pos.x = locx
			unitTarget.pos.y = locy
			unitTarget.pos.z = locz
			if not unit.flags1.on_ground then unitoccupancy.unit = false else unitoccupancy.unit_grounded = false end
		end
	end
end
if ttype == 'item' or ttype == 'both' then
	local itemList = df.global.world.items.all
	for i = #itemList - 1, 0, -1 do
		local itemTarget = itemList[i]
		if isSelected(unit,itemTarget,rx,ry,rz) then
			local pos = {}
			pos.x = pers.locx
			pos.y = pers.locy
			pos.z = pers.locz
			dfhack.items.moveToGround(itemTarget, pos)
		end
	end
end

--map based functions, version 42.06a
--[[
 changeInorganic(x,y,z,inorganic,dur) - Changes the inorganic of the specified position
 changeTemperature(x,y,z,temperature,dur) - Changes the temperature of the specified position (doesn't really work well since the game constantly reupdates temperatures)
 checkBounds(pos) - Checks if a position is within the map bounds, returns the closest position to the input that is within the bounds
 getEdgesPosition(pos,radius) - Get all the x,y,z positions along the edge of a pos + radius
 getFillPosition(pos,radius) - Get all the x,y,z positions within a pos + radius
 getPositionPlan(file,target,origin) - Get the x,y,z positions from an external text file
 getPositionCenter(radius) - Get a random position with a center radius of the center of the map
 getPositionEdge() - Get a random position along the edge of the map
 getPositionRandom() - Get a random position on the map
 getPositionCavern(number) - Get a random position in a specified cavern layer
 getPositionSurface(pos) - Return the surface z position given an x and y
 getPositionSky(pos) - Return a random z position in the sky given an x and y
 getPositionUnderground(pos) - Return a random z position underground given an x and y
 getPositionLocationRandom(pos,radius) - Get a random position within a certain radius of the given x,y,z
 getPositionUnitRandom(unit,radius) - Get a random position within a certain radius of the given unit
 spawnFlow(edges,offset,flowType,inorganic,density,static) - Spawn a flow using a number of variables
 spawnLiquid(edges,offset,depth,magma,circle,taper) - Spawn a liquid using a number of variables
 getFlow(pos) - Get any flows at the given position
 getTree(pos,array) - Get any tree (or a tree in a specific array) at a given position
 getShrub(pos,array) - Get any shrub (or a shrub in a specific array) at a given position
 removeTree(pos) - Remove the tree at the given position
 removeShrub(pos) - Remove the shrub at the given position
 getTreeMaterial(pos) - Get the material of the tree at the given position
 getShrubMaterial(pos) - Get the material of the shrub at the given position
 getGrassMaterial(pos) - Get the material of the grass at the given position
 getTreePositions(tree) - Get all x,y,z positions of a given tree
 flowSource(n) - Create a flow source (continually creates the flow)
 liquidSource(n) - Create a liquid source (continually creates liquid)
 liquidSink(n) - Create a liquid sink (continually removes liquid)
 findLocation(search) - Find a location on the map from the declared search parameters. See the find functions ReadMe for more information regarding search strings.
]]
---------------------------------------------------------------------------------------
function changeInorganic(x,y,z,inorganic,dur)
 pos = {}
 if y == nil and z == nil then
  pos.x = x.x or x[1]
  pos.y = x.y or x[2]
  pos.z = x.z or x[3]
 else
  pos.x = x
  pos.y = y
  pos.z = z
 end
 local block=dfhack.maps.ensureTileBlock(pos)
 local current_inorganic = 'clear'
 if inorganic == 'clear' then
  for k = #block.block_events-1,0,-1 do
   if df.block_square_event_mineralst:is_instance(block.block_events[k]) then
    block.block_events:erase(k)
   end
  end
  return
 else
  if tonumber(inorganic) then
   inorganic = tonumber(inorganic)
  else
   inorganic = dfhack.matinfo.find(inorganic).index
  end
  ev=df.block_square_event_mineralst:new()
  ev.inorganic_mat=inorganic
  ev.flags.cluster_one=true
  block.block_events:insert("#",ev)
  dfhack.maps.setTileAssignment(ev.tile_bitmask,pos.x%16,pos.y%16,true)
 end
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/map','changeInorganic',{pos.x,pos.y,pos.z,current_inorganic,0}) end
end

function changeTemperature(x,y,z,temperature,dur)
 pos = {}
 if y == nil and z == nil then
  pos.x = x.x or x[1]
  pos.y = x.y or x[2]
  pos.z = x.z or x[3]
 else
  pos.x = x
  pos.y = y
  pos.z = z
 end
 local block = dfhack.maps.ensureTileBlock(pos)
 local current_temperature = block.temperature_2[pos.x%16][pos.y%16]
 block.temperature_1[pos.x%16][pos.y%16] = temperature
-- if dur > 0 then
  block.temperature_2[pos.x%16][pos.y%16] = temperature
  block.flags.update_temperature = false
-- end
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/map','changeTemperature',{pos.x,pos.y,pos.z,current_temperature,0}) end
end

function checkBounds(pos)
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 if pos.x < 1 then pos.x = 1 end
 if pos.x > mapx-1 then pos.x = mapx-1 end
 if pos.y < 1 then pos.y = 1 end
 if pos.y > mapy-1 then pos.y = mapy-1 end
 if pos.z < 1 then pos.z = 1 end
 if pos.z > mapz-1 then pos.z = mapz-1 end
 return pos
end

function getEdgesPosition(pos,radius)
 local edges = {}
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xpos = pos.x or pos[1]
 local ypos = pos.y or pos[2]
 local zpos = pos.z or pos[3]
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 edges.xmin = xpos - rx
 edges.xmax = xpos + rx
 edges.ymin = ypos - ry
 edges.ymax = ypos + ry
 edges.zmax = zpos + rz
 edges.zmin = zpos - rz
 if edges.xmin < 1 then edges.xmin = 1 end
 if edges.ymin < 1 then edges.ymin = 1 end
 if edges.zmin < 1 then edges.zmin = 1 end
 if edges.xmax > mapx then edges.xmax = mapx-1 end
 if edges.ymax > mapy then edges.ymax = mapy-1 end
 if edges.zmax > mapz then edges.zmax = mapz-1 end
 return edges
end

function getFillPosition(pos,radius)
 local positions = {}
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xpos = pos.x or pos[1]
 local ypos = pos.y or pos[2]
 local zpos = pos.z or pos[3]
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 n = 0
 for k = 0,rz,1 do
  for j = 0,ry,1 do
   for i = 0,rx,1 do
    n = n+1
    positions[n] = {x = xpos+i, y = ypos+j, z = zpos+k}
    if positions[n].x < 1 then positions[n].x = 1 end
    if positions[n].y < 1 then positions[n].y = 1 end
    if positions[n].z < 1 then positions[n].z = 1 end
    if positions[n].x > mapx then positions[n].x = mapx-1 end
    if positions[n].y > mapy then positions[n].y = mapy-1 end
    if positions[n].z > mapz then positions[n].z = mapz-1 end
   end
  end
 end
 return positions,n
end

function getPositionPlan(file,target,origin)
 local xtar = target.x or target[1]
 local ytar = target.y or target[2]
 local ztar = target.z or target[3]
 local utils = require 'utils'
 local split = utils.split_string
 local iofile = io.open(file,"r")
 local data = iofile:read("*all")
 iofile:close()
 local splitData = split(data,',')
 local x = {}
 local y = {}
 local t = {}
 local xi = 0
 local yi = 1
 local xT = -1
 local yT = -1
 local xS = -1
 local yS = -1
 local xC = -1
 local yC = -1
 local n = 0
 local locations = {}
 for i,v in ipairs(splitData) do
  if split(v,'\n')[1] ~= v then
   xi = 1
   yi = yi + 1
  else
   xi = xi + 1
  end
  if v == 'T' or v == '\nT' then
   xT = xi
   yT = yi
  end
  if v == 'S' or v == '\nS' then
   xS = xi
   yS = yi
  end
  if v == 'C' or v == '\nC' then
   xC = xi
   yC = yi
  end
  if v == 'T' or v == '\nT' or v == '1' or v == '\n1' or v == 'C' or v == '\nC' then
   t[i] = true
  else
   t[i] = false
  end
  x[i] = xi
  y[i] = yi
 end
 if origin then
  xorg = origin.x or origin[1]
  yorg = origin.y or origin[2]
  zorg = origin.z or origin[3]
  xdis = math.abs(xorg-xtar)
  ydis = math.abs(yorg-ytar)
  if ztar ~= zorg then return locations,n end
  if xdis ~= 0 then
   xface = (xorg-xtar)/math.abs(xorg-xtar)
  else
   xface = 0
  end
  if ydis ~= 0 then
   yface = (yorg-ytar)/math.abs(yorg-ytar)
  else
   yface = 0
  end
  if xface == 0 and yface == 0 then
   xface = 0
   yface = 1
  end
  if xT == -1 and xS > 0 then
   for i,v in ipairs(x) do
    if t[i] then
     n = n + 1
	 xO = x[i] - xS
	 yO = y[i] - yS
	 xpos = -yface*xO+xface*yO
	 ypos = xface*xO+yface*yO
	 locations[n] = {x = xorg + xpos, y = yorg + ypos, z = zorg}
	 if (xface == 1 and yface == 1) or (xface == -1 and yface == 1) or (xface == 1 and yface == -1) or (xface == -1 and yface == -1) then
	  if xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0 then
       n = n + 1
	   if yO < 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos + (xface-yface)*xface*xface/2, y = yorg + ypos + (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO < 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos + (xface+yface)*xface*xface/2, y = yorg + ypos + (xface-yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos - (xface-yface)*xface*xface/2, y = yorg + ypos - (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos - (xface+yface)*xface*xface/2, y = yorg + ypos - (xface-yface)*xface*yface/2, z = zorg}
	   end
	  end
	 end
    end
   end
  elseif xT > 0 and xS == -1 then
   for i,v in ipairs(x) do
    if t[i] then
     n = n + 1
	 xO = x[i] - xT
	 yO = y[i] - yT
	 xpos = -yface*xO+xface*yO
	 ypos = xface*xO+yface*yO
	 locations[n] = {x = xorg + xpos, y = yorg + ypos, z = zorg}
	 if (xface == 1 and yface == 1) or (xface == -1 and yface == 1) or (xface == 1 and yface == -1) or (xface == -1 and yface == -1) then
	  if xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0 then
       n = n + 1
	   if yO < 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos + (xface-yface)*xface*xface/2, y = yorg + ypos + (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO < 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos + (xface+yface)*xface*xface/2, y = yorg + ypos + (xface-yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos - (xface-yface)*xface*xface/2, y = yorg + ypos - (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos - (xface+yface)*xface*xface/2, y = yorg + ypos - (xface-yface)*xface*yface/2, z = zorg}
	   end
	  end
	 end
    end
   end
  elseif xT > 0 and xS > 0 then -- For now just use the same case as above, in the future should add a way to check for both
   for i,v in ipairs(x) do
    if t[i] then
     n = n + 1
	 xO = x[i] - xT
	 yO = y[i] - yT
	 xpos = -yface*xO+xface*yO
	 ypos = xface*xO+yface*yO
	 locations[n] = {x = xorg + xpos, y = yorg + ypos, z = zorg}
	 if (xface == 1 and yface == 1) or (xface == -1 and yface == 1) or (xface == 1 and yface == -1) or (xface == -1 and yface == -1) then
	  if xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0 then
       n = n + 1
	   if yO < 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos + (xface-yface)*xface*xface/2, y = yorg + ypos + (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO < 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos + (xface+yface)*xface*xface/2, y = yorg + ypos + (xface-yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos - (xface-yface)*xface*xface/2, y = yorg + ypos - (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos - (xface+yface)*xface*xface/2, y = yorg + ypos - (xface-yface)*xface*yface/2, z = zorg}
	   end
	  end
	 end
    end
   end
  end
 else
  for i,v in ipairs(x) do
   if t[i] then
    n = n + 1
    locations[n] = {x = xtar + x[i] - xT, y = ytar + y[i] - yT, z = ztar}
   end
  end
 end
 return locations,n
end

function getPositionCenter(radius)
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 if tonumber(radius) then
  radius = tonumber(radius)
 else
  radius = 0
 end
 x = math.floor(mapx/2)
 y = math.floor(mapy/2)
 pos.x = rand:random(radius) + (rand:random(2)-1)*x
 pos.y = rand:random(radius) + (rand:random(2)-1)*y
 pos.z = rand:random(mapz)
 return pos
end

function getPositionEdge()
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 roll = rand:random(2)
 if roll == 1 then
  pos.x = 2
 else
  pos.x = mapx-1
 end
 roll = rand:random(2)
 if roll == 1 then
  pos.y = 2
 else
  pos.y = mapy-1
 end
 pos.z = rand:random(mapy)
 return pos
end

function getPositionRandom()
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 pos.x = rand:random(mapx)
 pos.y = rand:random(mapy)
 pos.z = rand:random(mapz)
 return pos
end

function getPositionCavern(number)
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
    for i = 1,mapx,1 do
     for j = 1,mapy,1 do
      for k = 1,mapz,1 do
       if dfhack.maps.getTileFlags(i,j,k).subterranean then
        if dfhack.maps.getTileBlock(i,j,k).global_feature >= 0 then
         for l,v in pairs(df.global.world.features.feature_global_idx) do
          if v == dfhack.maps.getTileBlock(i,j,k).global_feature then
           feature = df.global.world.features.map_features[l]
           if feature.start_depth == tonumber(quaternary) or quaternary == 'NONE' then
            if df.tiletype.attrs[dfhack.maps.getTileType(i,j,k)].caption == 'stone floor' then
             n = n+1
             targetList[n] = {x = i, y = j, z = k}
            end
           end
          end
         end
        end
       else
        break
       end
      end
     end
    end
 pos = dfhack.script_environment('functions/misc').permute(targetList)
 return pos[1]
end

function getPositionSurface(location)
 local pos = {}
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 pos.x = location.x or location[1]
 pos.y = location.y or location[2]
 pos.z = mapz - 1
 local j = 0
 while dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-j).designation[pos.x%16][pos.y%16].outside do
  j = j + 1
 end
 pos.z = pos.z - j
 pos = checkBounds(pos)
 return pos
end

function getPositionSky(location)
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 pos.x = location.x or location[1]
 pos.y = location.y or location[2]
 pos.z = mapz - 1
 local j = 0
 while dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-j).designation[pos.x%16][pos.y%16].outside do
  j = j + 1
 end
 pos.z = rand:random(mapz-j)+j
 pos = checkBounds(pos)
 return pos
end

function getPositionUnderground(location)
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 pos.x = location.x or location[1]
 pos.y = location.y or location[2]
 pos.z = mapz - 1
 local j = 0
 while dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-j).designation[pos.x%16][pos.y%16].outside do
  j = j + 1
 end
 pos.z = rand:random(j-1)
 pos = checkBounds(pos)
 return pos
end

function getPositionLocationRandom(location,radius)
 lx = location.x or location[1]
 ly = location.y or location[2]
 lz = location.z or location[3]
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xmin = lx - rx
 local ymin = ly - ry
 local zmin = lz - rz
 local xmax = lx + rx
 local ymax = ly + ry
 local zmax = lz + rz
 pos.x = rand:random(xmax-xmin) + xmin
 pos.y = rand:random(ymax-ymin) + ymin
 pos.z = rand:random(zmax-zmin) + zmin
 pos = checkBounds(pos)
 return pos
end

function getPositionUnitRandom(unit,radius)
 if tonumber(unit) then unit = df.unit.find(tonumber(unit)) end
 local pos = {}
 local rand = dfhack.random.new()
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xmin = unit.pos.x - rx
 local ymin = unit.pos.y - ry
 local zmin = unit.pos.z - rz
 local xmax = unit.pos.x + rx
 local ymax = unit.pos.y + ry
 local zmax = unit.pos.z + rz
 pos.x = rand:random(xmax-xmin) + xmin
 pos.y = rand:random(ymax-ymin) + ymin
 pos.z = rand:random(zmax-zmin) + zmin
 pos = checkBounds(pos)
 return pos
end

function spawnFlow(edges,offset,flowType,inorganic,density,static)
 local ox = offset.x or offset[1] or 0
 local oy = offset.y or offset[2] or 0
 local oz = offset.z or offset[3] or 0
 if edges.xmin then
  xmin = edges.xmin + ox
  xmax = edges.xmax + ox
  ymin = edges.ymin + oy
  ymax = edges.ymax + oy
  zmin = edges.zmin + oz
  zmax = edges.zmax + oz
 else
  xmin = edges.x + ox or edges[1] + ox
  ymin = edges.y + oy or edges[2] + oy
  zmin = edges.z + oz or edges[3] + oz
  xmax = edges.x + ox or edges[1] + ox
  ymax = edges.y + oy or edges[2] + oy
  zmax = edges.z + oz or edges[3] + oz
 end
 for x = xmin, xmax, 1 do
  for y = ymin, ymax, 1 do
   for z = zmin, zmax, 1 do
    block = dfhack.maps.ensureTileBlock(x,y,z)
	dsgn = block.designation[x%16][y%16]
	if not dsgn.hidden then
     flow = dfhack.maps.spawnFlow({x=x,y=y,z=z},flowType,0,inorganic,density)
     if static then flow.expanding = false end
	end
   end
  end
 end
end

function spawnLiquid(edges,offset,depth,magma,circle,taper)
 local ox = offset.x or offset[1] or 0
 local oy = offset.y or offset[2] or 0
 local oz = offset.z or offset[3] or 0
 if edges.xmin then
  xmin = edges.xmin + ox
  xmax = edges.xmax + ox
  ymin = edges.ymin + oy
  ymax = edges.ymax + oy
  zmin = edges.zmin + oz
  zmax = edges.zmax + oz
 else
  xmin = edges.x + ox or edges[1] + ox
  ymin = edges.y + oy or edges[2] + oy
  zmin = edges.z + oz or edges[3] + oz
  xmax = edges.x + ox or edges[1] + ox
  ymax = edges.y + oy or edges[2] + oy
  zmax = edges.z + oz or edges[3] + oz
 end
 for x = xmin, xmax, 1 do
  for y = ymin, ymax, 1 do
   for z = zmin, zmax, 1 do
    if circle then
     if (math.abs(x-(xmax+xmin)/2)+math.abs(y-(ymax+ymin)/2)+math.abs(z-(zmax+zmin)/2)) <= math.sqrt((xmax-xmin)^2/4+(ymax-ymin)^2/4+(zmax-zmin)^2/4) then
      block = dfhack.maps.ensureTileBlock(x,y,z)
      dsgn = block.designation[x%16][y%16]
      if not dsgn.hidden then
       if taper then
        size = math.floor(depth-((xmax-xmin)*math.abs((xmax+xmin)/2-x)+(ymax-ymin)*math.abs((ymax+ymin)/2-y)+(zmax-zmin)*math.abs((zmax+zmin)/2-z))/depth)
        if size < 0 then size = 0 end
       else
        size = depth
       end
       dsgn.flow_size = size
       if magma then dsgn.liquid_type = true end
       flow = block.liquid_flow[x%16][y%16]
       flow.temp_flow_timer = 10
       flow.unk_1 = 10
       block.flags.update_liquid = true
       block.flags.update_liquid_twice = true
      end
     end
    else
     block = dfhack.maps.ensureTileBlock(x,y,z)
     dsgn = block.designation[x%16][y%16]
     if not dsgn.hidden then
      if taper then
       size = math.floor(depth-((xmax-xmin)*math.abs((xmax+xmin)/2-x)+(ymax-ymin)*math.abs((ymax+ymin)/2-y)+(zmax-zmin)*math.abs((zmax+zmin)/2-z))/depth)
       if size < 0 then size = 0 end
      else
       size = depth
      end
      flow = block.liquid_flow[x%16][y%16]
      flow.temp_flow_timer = 10
      flow.unk_1 = 10
      dsgn.flow_size = size
      if magma then dsgn.liquid_type = true end
      block.flags.update_liquid = true
      block.flags.update_liquid_twice = true
     end
    end
   end
  end
 end
end

function getFlow(pos)
 flowtypes = {
              MIASMA,
              MIST,
              MIST2,
              DUST,
              LAVAMIST,
              SMOKE,
              DRAGONFIRE,
              FIREBREATH,
              WEB,
              UNDIRECTEDGAS,
              UNDIRECTEDVAPOR,
              OCEANWAVE,
              SEAFOAM
             }

 block = dfhack.maps.ensureTileBlock(pos)
 flows = block.flows
 flowID = -1
 for i,flow in pairs(flows) do
  if flow.pos.x == pos.x and flow.pos.y == pos.y and flow.pos.z == pos.z then
   flowID = i
   break
  end
 end
 if flowID == -1 then
  return false, false
 else
  return flows[flowID], flowtypes[flows[flowID]['type']]
 end
end

function getTree(pos,array)
 if not array then array = df.global.world.plants.all end
 for i,tree in pairs(array) do
  if tree.tree_info ~= nil then
   local x1 = tree.pos.x - math.floor(tree.tree_info.dim_x / 2)
   local x2 = tree.pos.x + math.floor(tree.tree_info.dim_x / 2)
   local y1 = tree.pos.y - math.floor(tree.tree_info.dim_y / 2)
   local y2 = tree.pos.y + math.floor(tree.tree_info.dim_y / 2)
   local z1 = tree.pos.z
   local z2 = tree.pos.z + tree.tree_info.body_height
   if ((pos.x >= x1 and pos.x <= x2) and (pos.y >= y1 and pos.y <= y2) and (pos.z >= z1 and pos.z <= z2)) then
    body = tree.tree_info.body[pos.z - tree.pos.z]:_displace((pos.y - y1) * tree.tree_info.dim_x + (pos.x - x1))
    if not body.blocked then
     if body.trunk or body.thick_branches_1 or body.thick_branches_2 or body.thick_branches_3 or body.thick_branches_4 or body.branches or body.twigs then
      return i,tree
     end
    end
   end
  end
 end
 return nil
end

function getShrub(pos,array)
 if not array then array = df.global.world.plants.all end
 for i,shrub in pairs(array) do
  if not shrub.tree_info then
   if pos.x == shrub.pos.x and pos.y == shrub.pos.y and pos.z == shrub.pos.z then
    return i,shrub
   end
  end
 end
end

function removeTree(pos)
 --erase from plants.all (but first get the tree positions)
 nAll,tree = getTree(pos,df.global.world.plants.all)
 positions = getTreePositions(tree)
 base = tree.pos.z
 --erase from plants.tree_dry
 nDry = getTree(pos,df.global.world.plants.tree_dry)
 --erase from plants.tree_wet
 nWet = getTree(pos,df.global.world.plants.tree_wet)
 --erase from map_block_columns
 x_column = math.floor(pos.x/16)
 y_column = math.floor(pos.y/16)
 --need to get 1st of 9 map block columns for plant information
 map_block_column = df.global.world.map.column_index[x_column-x_column%3][y_column-y_column%3]
 nBlock = getTree(pos,map_block_column.plants)
 print(nAll,nDry,nWet,nBlock)
 if nAll then df.global.world.plants.all:erase(nAll) end
 if nDry then df.global.world.plants.tree_dry:erase(nDry) end
 if nWet then df.global.world.plants.tree_wet:erase(nWet) end
 if nBlock then map_block_column.plants:erase(nBlock) end
 
 --Now change tiletypes for tree positions
 for _,position in ipairs(positions) do
  block = dfhack.maps.ensureTileBlock(position)
  if position.z == base then
   block.tiletype[position.x%16][position.y%16] = 350
  else
   block.tiletype[position.x%16][position.y%16] = df.tiletype['OpenSpace']
  end
  block.designation[position.x%16][position.y%16].outside = true
 end
end

function removeShrub(pos)
 --erase from plants.all
 n = getShrub(pos,df.global.world.plants.all)
 if n then df.global.world.plants.all:erase(n) end
 --erase from plants.shrub_dry
 n = getShrub(pos,df.global.world.plants.shrub_dry)
 if n then df.global.world.plants.shrub_dry:erase(n) end
 --erase from plants.tree_wet
 n = getShrub(pos,df.global.world.plants.shrub_wet)
 if n then df.global.world.plants.shrub_wet:erase(n) end
 --erase from map_block_columns
 x_column = math.floor(pos.x/16)
 y_column = math.floor(pos.y/16)
 --need to get 1st of 9 map block columns for plant information
 map_block_column = df.global.world.map.column_index[x_column-x_column%3][y_column-y_column%3]
 n = getTree(pos,map_block_column.plants)
 if n then map_block_column:erase(n) end
end

function getTreeMaterial(pos)
 _,tree = getTree(pos)
 material = dfhack.matinfo.decode(419, tree.material)
 return material
end

function getShrubMaterial(pos)
 _,shrub = getShrub(pos)
 material = dfhack.matinfo.decode(419, shrub.material)
 return material
end

function getGrassMaterial(pos)
 events = dfhack.maps.ensureTileBlock(pos).block_events
 for _,event in ipairs(events) do
  if df.block_square_event_grassst:is_instance(event) then
   if event.amount[pos.x%16][pos.y%16] > 0 then
    return dfhack.matinfo.decode(419,event.plant_index)
   end
  end
 end
end

function getTreePositions(tree)
 n = 0
 nTrunk = 0
 nTwigs = 0
 nBranches = 0
 nTBranches = 0
 positions = {}
 positionsTrunk = {}
 positionsTwigs = {}
 positionsBranches = {}
 positionsTBranches = {}
 local x1 = tree.pos.x - math.floor(tree.tree_info.dim_x / 2)
 local x2 = tree.pos.x + math.floor(tree.tree_info.dim_x / 2)
 local y1 = tree.pos.y - math.floor(tree.tree_info.dim_y / 2)
 local y2 = tree.pos.y + math.floor(tree.tree_info.dim_y / 2)
 local z1 = tree.pos.z
 local z2 = tree.pos.z + math.floor(tree.tree_info.body_height / 2)
 for x = x1,x2 do
  for y = y1,y2 do
   for z = z1,z2 do
    pos = {x=x,y=y,z=z}
    body = tree.tree_info.body[pos.z-z1]:_displace((pos.y - y1) * tree.tree_info.dim_x + (pos.x - x1))
    if body.trunk then
     n = n + 1
     positions[n] = pos
     nTrunk = nTrunk + 1
     positionsTrunk[nTrunk] = pos
    elseif body.twigs then
     n = n + 1
     positions[n] = pos
     nTwigs = nTwigs + 1
     positionsTwigs[nTwigs] = pos
    elseif body.branches then
     n = n + 1
     positions[n] = pos
     nBranches = nBranches + 1
     positionsBranches[nBranches] = pos
    elseif body.thick_branches_1 or body.thick_branches_2 or body.thick_branches_3 or body.thick_branches_4 then
     n = n + 1
     positions[n] = pos
     nTBranches = nTBranches + 1
     positionsTBranches[nTBranches] = pos
    end
   end
  end
 end
 return positions,positionsTrunk,positionsTBranches,positionsBranches,positionsTwigs
end

function flowSource(n)
 local persistTable = require 'persist-table'
 flowTable = persistTable.GlobalTable.roses.FlowTable
 flow = flowTable[n]
 if flow then
  x = tonumber(flow.x)
  y = tonumber(flow.y)
  z = tonumber(flow.z)
  density = tonumber(flow.Density)
  inorganic = tonumber(flow.Inorganic)
  flowType = tonumber(flow.FlowType)
  check = tonumber(flow.Check)
  dfhack.maps.spawnFlow({x,y,z},flowType,0,inorganic,density)
  dfhack.timeout(check,'ticks',
                 function ()
                  dfhack.script_environment('functions/map').flowSource(n)
                 end
                )
 end                
end

function liquidSource(n)
 local persistTable = require 'persist-table'
 liquidTable = persistTable.GlobalTable.roses.LiquidTable
 liquid = liquidTable[n]
 if liquid then
  x = tonumber(liquid.x)
  y = tonumber(liquid.y)
  z = tonumber(liquid.z)
  depth = tonumber(liquid.Depth)
  magma = liquid.Magma
  check = tonumber(liquid.Check)
  block = dfhack.maps.ensureTileBlock(x,y,z)
  dsgn = block.designation[x%16][y%16]
  flow = block.liquid_flow[x%16][y%16]
  flow.temp_flow_timer = 10
  flow.unk_1 = 10
  if dsgn.flow_size < depth then dsgn.flow_size = depth end
  if magma then dsgn.liquid_type = true end
  block.flags.update_liquid = true
  block.flags.update_liquid_twice = true
  dfhack.timeout(check,'ticks',
                 function ()
                  dfhack.script_environment('functions/map').liquidSource(n)
                 end
                )
 end                
end

function liquidSink(n)
 local persistTable = require 'persist-table'
 liquidTable = persistTable.GlobalTable.roses.LiquidTable
 liquid = liquidTable[n]
 if liquid then
  x = tonumber(liquid.x)
  y = tonumber(liquid.y)
  z = tonumber(liquid.z)
  depth = tonumber(liquid.Depth)
  magma = liquid.Magma
  check = tonumber(liquid.Check)
  block = dfhack.maps.ensureTileBlock(x,y,z)
  dsgn = block.designation[x%16][y%16]
  flow = block.liquid_flow[x%16][y%16]
  flow.temp_flow_timer = 10
  flow.unk_1 = 10
  if dsgn.flow_size > depth then dsgn.flow_size = depth end
  if magma then dsgn.liquid_type = true end
  block.flags.update_liquid = true
  block.flags.update_liquid_twice = true
  dfhack.timeout(check,'ticks',
                 function ()
                  dfhack.script_environment('functions/map').liquidSink(n)
                 end
                )
 end            
end

function findLocation(search)
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local x_map, y_map, z_map = dfhack.maps.getTileSize()
 x_map = x_map - 1
 y_map = y_map - 1
 z_map = z_map - 1
 local targetList = {}
 local target = nil
 local found = false
 local n = 1
 local rando = dfhack.random.new()
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   n = 1
   targetList = {{x = rando:random(x_map-1)+1,y = rando:random(y_map-1)+1,z = rando:random(z_map-1)+1}}
  elseif secondary == 'SURFACE' then
   if tertiary == 'ALL' or tertiary == 'NONE' then
    targetList[n] = getPositionRandom()
    targetList[n] = getPositionSurface(targetList[n])
   elseif tertiary == 'EDGE' then
    targetList[n] = getPositionEdge()
    targetList[n] = getPositionSurface(targetList[n])
   elseif tertiary == 'CENTER' then
    targetList[n] = getPositionCenter(quaternary)
    targetList[n] = getPositionSurface(targetList[n])
   end
  elseif secondary == 'UNDERGROUND' then
   if tertiary == 'ALL' or tertiary == 'NONE' then
    targetList[n] = getPositionRandom()
    targetList[n] = getPositionUnderground(targetList[n])
   elseif tertiary == 'CAVERN' then
    targetList[n] = getPositionCavern(quaternary)
   end
  elseif secondary == 'SKY' then
   if tertiary == 'ALL' or tertiary == 'NONE' then
    targetList[n] = getPositionRandom()
    targetList[n] = getPositionSky(targetList[n])
   elseif tertiary == 'EDGE' then
    targetList[n] = getPositionEdge()
    targetList[n] = getPositionSky(targetList[n])
   elseif tertiary == 'CENTER' then
    targetList[n] = getPositionCenter(quaternary)
    targetList[n] = getPositionSky(targetList[n])
   end
  end
 end
 target = targetList[1]
 return {target}
end

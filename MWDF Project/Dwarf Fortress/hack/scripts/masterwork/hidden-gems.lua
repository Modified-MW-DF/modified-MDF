--[[ 
hidden-gems.lua - this is a script that randomly produces masterwork gems as 
digging of a layer stone is completed.

  this is a rewrite of a script from TESB by Dirst.
  this rewrite was produced by Amostubal for DF 43.05 masterwork edition.
     
  Additional credits to other script writters include Putnam and Max for their
  assistance with TESB and GetLayerMat() and GetVeinMat() are from Milo 
  Christiansen's "Rubble Tile Material Getter", but with simpler inputs and 
  outputs suited to this context.  Find the original module at 
  http://www.bay12forums.com/smf/index.php?topic=150776
--]]

--[[
 Left this in as it was in Dirst's original and I'm not sure how much 
 of Milo's work remains after the fix and rewrite of this script.
--]]
  
--[[
Rubble Tile Material Getter DFHack Lua Module

Copyright 2015 Milo Christiansen

This software is provided 'as-is', without any express or implied warranty. In
no event will the authors be held liable for any damages arising from the use of
this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to
the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim
that you wrote the original software. If you use this software in a product, an
acknowledgment in the product documentation would be appreciated but is not
required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
]]

local usage = [====[

warpstone
====================
the script that processes whether a completed dig produces a warpstone.

Usage::
    - help
        produces this help screen.
    - layer X
        sets the percentage chance of a gem appearing in any layer stone.
        needs to be between 0 and 1.
    - stable X
        sets the percentage chance of a gem appearing in any stable warpstone.
        needs to be between 0 and 1.

if no argument is passed, this will produce a status of the mod.

]====]

local utils = require('utils')
local hiddengems_version= "1.00"
local debug=false

function GetLayerMat(pos)
  local region_info = dfhack.maps.getRegionBiome(dfhack.maps.getTileBiomeRgn(pos))
  local map_block = dfhack.maps.ensureTileBlock(pos)
  
  local biome = df.world_geo_biome.find(region_info.geo_index)
  
  local layer_index = map_block.designation[pos.x%16][pos.y%16].geolayer_index
  local layer_mat_index = biome.layers[layer_index].mat_index
  
  return layer_mat_index
end

function GetVeinMat(pos)
  local region_info = dfhack.maps.getRegionBiome(dfhack.maps.getTileBiomeRgn(pos))
  local map_block = dfhack.maps.ensureTileBlock(pos)
  
  local events = {}
  for _, event in ipairs(map_block.block_events) do
    if getmetatable(event) == "block_square_event_mineralst" then
      if dfhack.maps.getTileAssignment(event.tile_bitmask, pos.x, pos.y) then
        table.insert(events, event)
      end
    end
  end
  
  if #events == 0 then
    return nil
  end
  
  local event_priority = function(event)
    if event.flags.cluster then
      return 1
    elseif event.flags.vein then
      return 2
    elseif event.flags.cluster_small then
      return 3
    elseif event.flags.cluster_one then
      return 4
    else
      return 5
    end
  end
  
  local priority = events[1]
  for _, event in ipairs(events) do
    if event_priority(event) >= event_priority(priority) then
      priority = event
    end
  end
  
  return priority.inorganic_mat
end

-- List of layer stones that can contain Living Stone or Hidden Gems
stone_list = { "ANDESITE", "BASALT", "CHALK",
  "CHERT", "CLAYSTONE", "CONGLOMERATE",
  "DACITE", "DIORITE", "DOLOMITE",
  "GABBRO", "GNEISS", "GRANITE",
  "LIMESTONE", "MARBLE", "MUDSTONE",
  "PHYLLITE", "QUARTZITE", "RHYOLITE",
  "ROCK_SALT", "SANDSTONE", "SCHIST",
  "SHALE", "SILTSTONE", "SLATE",
  "WARPSTONE_STABLE", "RUINS" }

-- List of digging jobs that can result in Living Stone or Hidden Gems
digging_list = utils.invert({ "CarveDownwardStaircase", "CarveFortification", 
  "CarveRamp", "CarveUpDownStaircase", "CarveUpwardStaircase", "Dig", 
  "DigChannel", "RemoveStairs" })

caste_list = {}

-- Lists indexed by material ID numbers
for mat = 1, #stone_list do
  local index = dfhack.matinfo.find(stone_list[mat]).index
  caste_list[index] = stone_list[mat]
  if debug then print("placed in caste_list[",index,"] <- ",stone_list[mat]) end
end

local validArgs = validArgs or utils.invert({
  'help',
  'warpstone',
  'warpstoneVein',
  'tears',
  'blood',
  'relic',
  'fossil',
  'treasure',
  'ruinsVein'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
  print(usage)
  return
end

-- Load the config from the persistent tables.
local config = dfhack.persistent.get("HIDDENGEMS/config")
local warpstone_prob_layer
local warpstone_prob_stable
local tears_prob_layer
local blood_prob_layer
local relic_prob_layer
local fossil_prob_layer
local treasure_prob_layer
local treasure_prob_ruins

if config then
  if config.value > hiddengems_version then
    dfhack.color(12)
	dfhack.println("Cannot read configiration from version "..config.value..".")
    return
  end  -- load the config or replace with variables if given.
  dfhack.println("loading from config.")
  -- split config.ints[3]
  local value_1,value_2 = math.modf(config.ints[3]/10000)
  value_1=value_1/10000
  value_2=(math.floor(value_2*10000))/10000
  warpstone_prob_layer = tonumber(args.warpstone) or config.ints[1]/10000
  warpstone_prob_stable = tonumber(args.warpstoneVein) or config.ints[2]/10000
  tears_prob_layer = tonumber(args.tears) or tonumber(value_1)
  blood_prob_layer = tonumber(args.blood) or tonumber(value_2)
  relic_prob_layer = tonumber(args.relic) or config.ints[4]/10000
  fossil_prob_layer = tonumber(args.fossil) or config.ints[5]/10000
  treasure_prob_layer = tonumber(args.treasure) or config.ints[6]/10000
  treasure_prob_ruins = tonumber(args.ruinsVein) or config.ints[7]/10000
else  -- no config so load variables given or set to 0.
  dfhack.println("no config.")
  warpstone_prob_layer = tonumber(args.warpstone) or 0
  warpstone_prob_stable = tonumber(args.warpstoneVein) or 0
  tears_prob_layer = tonumber(args.tears) or 0
  blood_prob_layer = tonumber(args.blood) or 0
  relic_prob_layer = tonumber(args.relic) or 0
  fossil_prob_layer = tonumber(args.fossil) or 0
  treasure_prob_layer = tonumber(args.treasure) or 0
  treasure_prob_ruins = tonumber(args.ruinsVein) or 0
end

--[[ Persist tables can't have more than 7 entries in ints, so have to combine
     2 of these to make it work correctly.
--]]
local toa_boa_combine = math.floor((math.floor(tears_prob_layer*10000)+blood_prob_layer)*10000)
local variable_probabilites = {
  math.floor(warpstone_prob_layer*10000),  --1
  math.floor(warpstone_prob_stable*10000), --2
  toa_boa_combine,                         --3
  math.floor(relic_prob_layer*10000),      --4
  math.floor(fossil_prob_layer*10000),     --5
  math.floor(treasure_prob_layer*10000),   --6
  math.floor(treasure_prob_ruins*10000) }  --7

--save the config in the persistent tables.
dfhack.persistent.save({key="HIDDENGEMS/config",value=hiddengems_version,ints=variable_probabilites})

local rng = dfhack.random.new()

-- cleaned this part to only that which is necessary for the script.
jobCheck = require('plugins.eventful')
jobCheck.onJobCompleted.hiddengems=function(job)
  if digging_list[df.job_type[job.job_type]] then -- Will be nil if not on the list
    local pos = job.pos

    -- WARPSTONE_STABLE and RUINS is a Vein, so we check for a vein of it. we can't check for layer, because layer tells you the layer of the floor no matter the vein.
	if caste_list[GetVeinMat(pos)] and (not dfhack.maps.getTileBlock(pos).occupancy[pos.x%16][pos.y%16].item) then
      if debug then print("we hit vein: ",GetVeinMat(pos)," which should be:",caste_list[GetVeinMat(pos)]) end

      -- So first lets see if its WARPSTONE_STABLE
      if rng:drandom()<warpstone_prob_stable and caste_list[GetVeinMat(pos)]=='WARPSTONE_STABLE' then
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck warpstone!",6,1)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material INORGANIC:WARPSTONE -item ROUGH:NONE"
        dfhack.run_command_silent(command)

      -- well if its not the WARPSTONE_STABLE it should be RUINS, but we test for it anyways.
      elseif rng:drandom()<treasure_prob_ruins and caste_list[GetVeinMat(pos)]=='RUINS' then

        -- So its positive and half of them should be relics..
		if rng:drandom()<.5 then
          dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck a relic!",6,1)
          local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
          command = command .. " -material INORGANIC:RELICT -item ROUGH:NONE"
          dfhack.run_command_silent(command)

        -- otherwise its a treasure
		else
          dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck an old chest!",6,1)
          local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
          command = command .. " -material INORGANIC:TREASURE -item ROUGH:NONE"
          dfhack.run_command_silent(command)
        end

      end

    -- Now we handle finding things inside of layerstone, first by checking for layerstone:
    elseif caste_list[GetLayerMat(pos)] and (not GetVeinMat(pos)) and (not dfhack.maps.getTileBlock(pos).occupancy[pos.x%16][pos.y%16].item) then
      if debug then print("we hit layer: ",GetLayerMat(pos)," which should be:",caste_list[GetLayerMat(pos)]) end

      --[[ We have to figure them individually, because any other way would 
           require a whole new level of math on top of the current version.
           That would add additional complexity that is not needed.  the only
           issue is that one single dig of a layer square may make more than 1
           of the 6 gems appear.
      --]]

      -- warpstone in layers  
      if rng:drandom()<warpstone_prob_layer then
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck warpstone!",6,1)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material INORGANIC:WARPSTONE -item ROUGH:NONE"
        dfhack.run_command_silent(command)
      end

      -- blood of armok in layers  
      if rng:drandom()<warpstone_prob_layer then
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck blood of armok!",6,1)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material INORGANIC:BLOOD_OF_ARMOK -item ROUGH:NONE"
        dfhack.run_command_silent(command)
      end

      -- tears of armok in layers  
      if rng:drandom()<warpstone_prob_layer then
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck tears of armok!",6,1)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material INORGANIC:TEARS_OF_ARMOK -item ROUGH:NONE"
        dfhack.run_command_silent(command)
      end

      -- fossils in layers  
      if rng:drandom()<warpstone_prob_layer then
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck a fossil!",6,1)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material INORGANIC:FOSSIL -item ROUGH:NONE"
        dfhack.run_command_silent(command)
      end

      -- treasures in layers  
      if rng:drandom()<warpstone_prob_layer then
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck an old chest!",6,1)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material INORGANIC:TREASURE -item ROUGH:NONE"
        dfhack.run_command_silent(command)
      end

      -- relics in layers  
      if rng:drandom()<warpstone_prob_layer then
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck a relic!",6,1)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material INORGANIC:RELICT -item ROUGH:NONE"
        dfhack.run_command_silent(command)
      end

    end
  end
end

--if not ... then
  print('hidden gems version: ', hiddengems_version)
  print('  chance of warpstone gem in layer stone: ', warpstone_prob_layer)
  print('  chance of blood of armok in layer stone: ', blood_prob_layer)
  print('  chance of tears of armok in layer stone: ', tears_prob_layer)
  print('  chance of fossils in layer stone: ', fossil_prob_layer)
  print('  chance of treasures in layer stone: ', treasure_prob_layer)
  print('  chance of relics in layer stone: ', relic_prob_layer)
  print('  chance of warpstone gem in weak warpstone veins: ', warpstone_prob_stable)
  print('  chance of relics/treasures in collapsed brick: ', treasure_prob_ruins)
  print(" type 'hidden-gems -help' for additional mod info' ") 
--end





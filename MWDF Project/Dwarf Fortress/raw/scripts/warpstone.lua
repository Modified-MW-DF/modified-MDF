--[[ 
Warpstone.lua - this is a script that randomly produces a warpstone gem as 
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
local warpstone_version= "1.00"
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
  "WARPSTONE_STABLE" }

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
  'layer',
  'stable'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
  print(usage)
  return
end

-- Load the config from the persistent tables.
local config = dfhack.persistent.get("WARPSTONE/config")
local gem_prob_layer
local gem_prob_stable

if config then
  if config.value > warpstone_version then
    dfhack.color(12)
	dfhack.println("Cannot read configiration from version "..config.value..".")
    return
  end  -- load the config or replace with variables if given.
  gem_prob_layer = tonumber(args.layer) or config.ints[1]/10000
  gem_prob_stable = tonumber(args.stable) or config.ints[2]/10000
else  -- no config so load variables given or set to 0.
  gem_prob_layer = tonumber(args.layer) or 0
  gem_prob_stable = tonumber(args.stable) or 0
end

--save the config in the persistent tables.
dfhack.persistent.save({key="WARPSTONE/config",value=warpstone_version,ints={math.floor(gem_prob_layer*10000),math.floor(gem_prob_stable*10000)}})

local rng = dfhack.random.new()

-- cleaned this part to only that which is necessary for the script.
jobCheck = require('plugins.eventful')
jobCheck.onJobCompleted.warpstone1=function(job)
  if digging_list[df.job_type[job.job_type]] then -- Will be nil if not on the list
    local pos = job.pos
    -- WARPSTONE_STABLE is a Vein, so we check for a vein of it. we can't check for layer, because layer tells you the layer of the floor no matter the vein.
	if caste_list[GetVeinMat(pos)] and (not dfhack.maps.getTileBlock(pos).occupancy[pos.x%16][pos.y%16].item) then
      if debug then print("we hit vein: ",GetVeinMat(pos)," which should be:",caste_list[GetVeinMat(pos)]) end
      if rng:drandom()<gem_prob_stable then
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck warpstone!",6,1)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material INORGANIC:WARPSTONE -item ROUGH:NONE"
        dfhack.run_command_silent(command)
      end
    -- the rest of the warpstone gems appear in layer stones.
    elseif caste_list[GetLayerMat(pos)] and (not GetVeinMat(pos)) and (not dfhack.maps.getTileBlock(pos).occupancy[pos.x%16][pos.y%16].item) then
      if debug then print("we hit layer: ",GetLayerMat(pos)," which should be:",caste_list[GetLayerMat(pos)]) end
      if rng:drandom()<gem_prob_layer then
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck warpstone!",6,1)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material INORGANIC:WARPSTONE -item ROUGH:NONE"
        dfhack.run_command_silent(command)
      end
    end
  end
end

if not ... then
  print('warpstone status:')
  print('  chance of warpstone gem in layer stone: ', gem_prob_layer)
  print('  chance of warpstone gem in stable warpstone: ', gem_prob_stable)
end





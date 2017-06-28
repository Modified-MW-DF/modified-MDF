local usage = [====[

Utility for The Earth Strikes Back! mod that allows the earth to actually 
strike back.  Every time a layer stone tile is mined, it might turn out to 
be "living stone" or a "hidden gem."

Since this script needs to monitor all job completions, it *also* listens for
completed buildings to turn Tributes into the correct subtype.  That 
functionality incudes elements of Putnam's building/subtype-change script.

  arguments
    -living
      Probability of layer stone turning out to be "living stone" that 
      spawns an Awakened Stone or Wyrm (and possibly some Pet Rocks)
      Defaults to .0005
    -gem
      Probability of layer stone turning out to be a "hidden gem"
      Defaults to .002
    -grace_period
      The number of tiles of layer stone that can be mined without the
      risk of spawning an Awakened Stone or Wyrm
      Defaults to 250
    -help
      Show this help

Made by Dirst for The Earth Strikes Back! mod, but possible due to extensive 
help from Putnam and Max.  GetLayerMat() and GetVeinMat() are from Milo 
Christiansen's "Rubble Tile Material Getter", but with simpler inputs and 
outputs suited to this context.  Find the original module at 
http://www.bay12forums.com/smf/index.php?topic=150776
]====]

local utils = require('utils')
local tesb_version = "2.14"

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

-- Identify custom_type for Tribute and Altar
local tribute_type
local altar_type
for _,x in ipairs(df.global.world.raws.buildings.all) do
  if x.code == "TESB_TRIBUTE" then
    tribute_type = x.id
  elseif x.code == "TESB_ALTAR" then
    altar_type = x.id
  end
end

function specificWorkshop(workshop_id,stone)
  local workshop = df.building.find(tonumber(workshop_id))
  if workshop.custom_type ~= tribute_type then
    print('Specified worshop is not a Tribute')
  else
    local tribute = "TESB_TRIBUTE_"..string.upper(stone)
    for _,x in ipairs(df.global.world.raws.buildings.all) do
      if x.code == tribute then ctype = x.id end
    end
    workshop.custom_type = ctype
  end
end

function specificAltar(workshop_id,stone)
  local workshop = df.building.find(tonumber(workshop_id))
  if workshop.custom_type ~= altar_type then
    print('Specified worshop is not an Altar')
  else
    local altar = "TESB_ALTAR_"..string.upper(stone)
    for _,x in ipairs(df.global.world.raws.buildings.all) do
      if x.code == altar then ctype = x.id end
    end
    workshop.custom_type = ctype
  end
end

-- List of layer stones that can contain Living Stone or Hidden Gems
stone_list = { "ANDESITE", "BASALT", "CHALK",
  "CHERT", "CLAYSTONE", "CONGLOMERATE",
  "DACITE", "DIORITE", "DOLOMITE",
  "GABBRO", "GNEISS", "GRANITE",
  "LIMESTONE", "MARBLE", "MUDSTONE",
  "PHYLLITE", "QUARTZITE", "RHYOLITE",
  "ROCK_SALT", "SANDSTONE", "SCHIST",
  "SHALE", "SILTSTONE", "SLATE" 
}

-- List of Hidden Gems, in layer stone order
gem_list = { "HIDDEN QUARTZ", "HIDDEN SUNSTONE", "HIDDEN WHITE OPAL", 
  "HIDDEN WAX OPAL", "HIDDEN MILK OPAL", "HIDDEN PINFIRE OPAL",
  "HIDDEN PYRITE", "HIDDEN SPINEL", "HIDDEN BLACK OPAL",
  "HIDDEN AMETHYST", "HIDDEN GARNET", "HIDDEN EMERALD",
  "HIDDEN ONYX", "HIDDEN BERYL", "HIDDEN FIRE OPAL", 
  "HIDDEN ZIRCON", "HIDDEN TOURMALINE", "HIDDEN TURQUOISE",
  "HIDDEN CHERRY OPAL", "HIDDEN AMBER OPAL", "HIDDEN AQUAMARINE",
  "HIDDEN SHELL OPAL", "HIDDEN BONE OPAL", "HIDDEN PYROPE" 
}

-- List of digging jobs that can result in Living Stone or Hidden Gems
digging_list = utils.invert({ "CarveDownwardStaircase", "CarveFortification", 
  "CarveRamp", "CarveUpDownStaircase", "CarveUpwardStaircase", "Dig", 
  "DigChannel", "RemoveStairs" }
)
  
-- List of associated Spheres for each stone type
--[[
Sedimentary stones are in the EARTH and MINERALS Spheres.  Rock salt is also in the SALT Sphere.
Metamorphic stones are in the EARTH and MOUNTAINS Spheres.
Igneous intrusive stones are in the MOUNTAINS and CAVERNS Spheres.
Igneous extrusive stones are in the MOUNTAINS and VOLCANOS Spheres.
Flux stones are in the MINERALS and METALS Spheres.
]]

sphere_list = { ANDESITE = {MOUNTAINS = true, VOLCANOS = true}, 
  BASALT = {MOUNTAINS = true, VOLCANOS = true}, 
  CHALK = {MINERALS = true, METALS = true}, 
  CHERT = {EARTH = true, MINERALS = true}, 
  CLAYSTONE = {EARTH = true, MINERALS = true},
  CONGLOMERATE = {EARTH = true, MINERALS = true}, 
  DACITE = {MOUNTAINS = true, VOLCANOS = true}, 
  DIORITE = {CAVERNS = true, MOUNTAINS = true}, 
  DOLOMITE = {MINERALS = true, METALS = true}, 
  GABBRO = {CAVERNS = true, MOUNTAINS = true}, 
  GNEISS = {EARTH = true, MOUNTAINS = true}, 
  GRANITE = {CAVERNS = true, MOUNTAINS = true}, 
  LIMESTONE = {MINERALS = true, METALS = true}, 
  MARBLE = {MINERALS = true, METALS = true}, 
  MUDSTONE = {EARTH = true, MINERALS = true}, 
  PHYLLITE = {EARTH = true, MOUNTAINS = true}, 
  QUARTZITE = {EARTH = true, MOUNTAINS = true},
  RHYOLITE = {MOUNTAINS = true, VOLCANOS = true}, 
  ROCK_SALT = {EARTH = true, MINERALS = true, SALT = true}, 
  SANDSTONE = {EARTH = true, MINERALS = true}, 
  SCHIST = {EARTH = true, MOUNTAINS = true}, 
  SHALE = {EARTH = true, MINERALS = true}, 
  SILTSTONE = {EARTH = true, MINERALS = true},
  SLATE = {EARTH = true, MOUNTAINS = true}
}

temple_list = { ANDESITE = "IGNEOUS_EXT", 
  BASALT = "IGNEOUS_EXT", 
  CHALK = "FLUX", 
  CHERT = "SEDIMENTARY", 
  CLAYSTONE = "SEDIMENTARY",
  CONGLOMERATE = "SEDIMENTARY", 
  DACITE = "IGNEOUS_EXT", 
  DIORITE = "IGNEOUS_INT", 
  DOLOMITE = "FLUX", 
  GABBRO = "IGNEOUS_INT", 
  GNEISS = "METAMORPHIC", 
  GRANITE = "IGNEOUS_INT", 
  LIMESTONE = "FLUX", 
  MARBLE = "FLUX", 
  MUDSTONE = "SEDIMENTARY", 
  PHYLLITE = "METAMORPHIC", 
  QUARTZITE = "METAMORPHIC",
  RHYOLITE = "IGNEOUS_EXT", 
  ROCK_SALT = "ROCK_SALT", 
  SANDSTONE = "SEDIMENTARY", 
  SCHIST = "METAMORPHIC", 
  SHALE = "SEDIMENTARY", 
  SILTSTONE = "SEDIMENTARY",
  SLATE = "METAMORPHIC"
}

hiddenGem_list = {}
caste_list = {}
workshop_list = {}

-- Lists indexed by material ID numbers
for mat = 1, #stone_list do
  local index = dfhack.matinfo.find(stone_list[mat]).index
  hiddenGem_list[index] = gem_list[mat]
  caste_list[index] = stone_list[mat]
  workshop_list[index] = stone_list[mat]
end

local validArgs = validArgs or utils.invert({
  'help',
  'living',
  'gem',
  'grace_period'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
  print(usage)
  return
end

-- Load configuration data
--  Value is a string holding the TESB version of the data structure
--  ints[1] is "-living" parameter
--  ints[2] is "-gem" parameter 
local config = dfhack.persistent.get("TESB/config")
local living_prob
local gem_prob
if config then
  if config.value > tesb_version then
    dfhack.color(12)
    dfhack.println("Cannot read configuration from version "..config.value..".")
    return
  end
  living_prob = tonumber(args.living) or config.ints[1]/10000
  gem_prob = tonumber(args.gem) or config.ints[2]/10000
else
  living_prob = tonumber(args.living) or .002
  gem_prob = tonumber(args.gem) or .005
end
dfhack.persistent.save({key="TESB/config",value=tesb_version,ints={math.floor(living_prob*10000),math.floor(gem_prob*10000)}})
-- Load grace period data
--  Value is a string holding the TESB version of the data structure
--  ints[1] is "-grace_period" parameter
--  ints[2] is the number of tiles mined
local grace = dfhack.persistent.get("TESB/grace")
local grace_total
local grace_count
if grace then
  if config.value > tesb_version then
    dfhack.color(12)
    dfhack.println("Cannot read grace period data from version "..grace.value..".")
    return
  end
  grace_total = tonumber(args.grace_period) or grace.ints[1]
  grace_count = grace.ints[2]
else
  grace_total = tonumber(args.grace_period) or 250
  grace_count = 0
  --print("No saved grace data.")
end
grace_total = math.min(grace_total,30000)
dfhack.persistent.save({key="TESB/grace",value=tesb_version,ints={grace_total,grace_count}})

local rng = dfhack.random.new()
jobCheck = require('plugins.eventful')
jobCheck.onJobCompleted.tesbJobMonitor = function(job)
  if digging_list[df.job_type[job.job_type]] then -- Will be nil if not on the list
    local pos = job.pos
    if caste_list[GetLayerMat(pos)] and (not GetVeinMat(pos)) then
      if grace_count < 30000 then grace_count = grace_count + 1 end
      if grace_count > grace_total and rng:drandom()<living_prob then
        local command = "tesb-wake -caste " .. caste_list[GetLayerMat(pos)] .. " -location "
        command = command .. "[ " .. pos.x .. " " .. pos.y .. " " .. pos.z .. " ]"
        command = command .. " -miner " .. job.general_refs[0].unit_id
        if rng:drandom()<living_prob^.5 then
          command = command .. " -wyrm"
        end
        dfhack.run_command(command)
      elseif rng:drandom()<(gem_prob*math.min(1,(grace_count/grace_total))) then
        local gem = hiddenGem_list[GetLayerMat(pos)]
        local gem_name = dfhack.matinfo.find(gem).material.state_name.Solid
        dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck " .. gem_name .. "!",6,1)
        --dfhack.gui.showAnnouncement("You have struck " .. gem_name .. "!",15)
        local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
        command = command .. " -material \"INORGANIC:" .. gem .. "\""
        command = command .. " -item ROUGH:NONE"
        dfhack.run_command_silent(command)
      end
      dfhack.persistent.save({key="TESB/grace",value=tesb_version,ints={grace_total,grace_count}})
    end
  elseif job.job_type == 68 then -- ConstructBuilding
    -- check that it's a generic Tribute or generic Altar
    local workshop = df.building.find(job.general_refs[0].building_id)
    if workshop and workshop.construction_stage == 3 and workshop.mat_type == 0 and not workshop.design then
      local workshop_mat = workshop_list[workshop.mat_index]  -- Will be nil if not on the list
      -- Generic Tribute
      if workshop.custom_type == tribute_type and workshop_mat then
        workshop_mat_index = workshop.mat_index
        if workshop.contained_items[0].item.mat_index == workshop_mat_index and 
            workshop.contained_items[1].item.mat_index == workshop_mat_index and 
            workshop.contained_items[2].item.mat_index == workshop_mat_index then
          specificWorkshop(workshop.id,workshop_mat) -- All three blocks valid
        else
          specificWorkshop(workshop.id,'INACTIVE') -- First block valid, but not a set of 3
        end
      elseif workshop.custom_type == tribute_type then
        specificWorkshop(workshop.id,'INACTIVE') -- First block invalid
      -- Generic Altar
      elseif workshop.custom_type == altar_type and #workshop.parents>0 then
        local valid = false
        for _,parent in ipairs(workshop.parents) do
          local temple = df.global.world.world_data.active_site[0].buildings[parent.location_id]
          -- Need to find a way to test that it's really a temple!
          local deity_id = temple.deity
          local hf_id = temple.deity + 1
          while deity_id ~= df.global.world.history.figures[hf_id].id do
            if deity_id < df.global.world.history.figures[hf_id].id then
              hf_id = hf_id - 1
            else
              hf_id = hf_if + 1
            end
          end
          local hf = df.global.world.history.figures[hf_id]
          for _,sphere in ipairs(hf.info.spheres) do
            if sphere_list[workshop_mat][df.sphere_type[sphere]] then valid = true end
          end
        end
        if valid == true then
          specificAltar(workshop.id,workshop_mat) -- Valid material in an appropriate temple
        else
          specificAltar(workshop.id,'INACTIVE_'..temple_list[workshop_mat]) -- Valid material not in an appropriate temple
        end
      elseif workshop.custom_type == altar_type and temple_list[workshop_mat] then
        specificAltar(workshop.id,'INACTIVE_'..temple_list[workshop_mat]) -- Valid material but not in any temple
      elseif workshop.custom_type == altar_type then
        specificAltar(workshop.id,'INACTIVE') -- Invalid material
      end
    end
  end
end

dfhack.run_command("tesb-info")
dfhack.print(" ")
dfhack.print("Use ")
dfhack.color(10)
dfhack.print("tesb-info")
dfhack.color(-1)
dfhack.println(" for current grace period and probabilities.")

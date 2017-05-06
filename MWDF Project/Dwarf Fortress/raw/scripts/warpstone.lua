--[[
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
		-help
			Show help

Made by Dirst for The Earth Strikes Back! mod, but possible due to extensive 
help from Putnam and Max.  GetLayerMat() and GetVeinMat() are from Milo 
Christiansen's "Rubble Tile Material Getter", but with simpler inputs and 
outputs suited to this context.  Find the original module at 
http://www.bay12forums.com/smf/index.php?topic=150776
]]

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

-- Identify custom_type for Tribute
local tribute_type
for _,x in ipairs(df.global.world.raws.buildings.all) do
	if x.code == "TESB_TRIBUTE" then tribute_type = x.id end
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

-- List of layer stones that can contain Living Stone or Hidden Gems
stone_list = { "ANDESITE", "BASALT", "CHALK", "CHERT", "CLAYSTONE",
	"CONGLOMERATE", "DACITE", "DIORITE", "DOLOMITE", "GABBRO", "GNEISS", 
	"GRANITE", "LIMESTONE", "MARBLE", "MUDSTONE", "PHYLLITE", "QUARTZITE",
	"RHYOLITE", "ROCK_SALT", "SANDSTONE", "SCHIST", "SHALE", "SILTSTONE",
	"SLATE" }

-- List of Hidden Gems, in layer stone order
gem_list = { "WARPSTONE" }

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

local utils = require('utils')

local validArgs = validArgs or utils.invert({
    'help',
    'living',
    'gem',
})

local args = utils.processArgs({...}, validArgs)

if args.help then
print([[scripts/tesb-onscreen-mining.lua
Utility for The Earth Strikes Back! mod that allows the earth to actually 
strike back.  Every time a layer stone tile is mined, it might turn out to 
be "living stone" or a "hidden gem."

Since this script needs to monitor all job completions, it *also* listens for
completed buildings to turn Tributes into the correct subtype.

arguments
    -living
        Probability of layer stone tile turning out to be "living stone" 
        that spawns an Awakened Stone or Wyrm (and possibly some Pet Rocks)
        Defaults to .002
    -gem
        Probability of layer stone turning out to be a "hidden gem"
        Defaults to .005
    -help
        Show this help
]])
return
end

local living_prob = tonumber(args.living) or .002
local gem_prob = tonumber(args.gem) or .005
local rng = dfhack.random.new()

jobCheck = require('plugins.eventful')
jobCheck.onJobCompleted.warpstone1=function(job)
	if job.job_type >= 3 and job.job_type <= 7 then -- Mining, digging stairs, etc.
		local pos = job.pos
		if caste_list[GetLayerMat(pos)] and (not GetVeinMat(pos)) and (not dfhack.maps.getTileBlock(pos).occupancy[pos.x%16][pos.y%16].item) then
			if rng:drandom()<living_prob then
				local command = "tesb-wake -caste " .. caste_list[GetLayerMat(pos)] .. " -location "
				command = command .. "[ " .. pos.x .. " " .. pos.y .. " " .. pos.z .. " ]"
				command = command .. " -miner " .. job.general_refs[0].unit_id
				if rng:drandom()<living_prob^.5 then
					command = command .. " -wyrm"
				end
				dfhack.run_command(command)
			elseif rng:drandom()<gem_prob then
				local gem = hiddenGem_list[GetLayerMat(pos)]
				local gem_name = dfhack.matinfo.find(gem).material.state_name.Solid
				dfhack.gui.makeAnnouncement(5,{false,false,false,true},pos,"You have struck " .. gem_name .. "!",6,1)
				--dfhack.gui.showAnnouncement("You have struck " .. gem_name .. "!",15)
				local command = "modtools/create-item -creator " .. job.general_refs[0].unit_id
				command = command .. " -material \"INORGANIC:" .. gem .. "\""
				command = command .. " -item ROUGH:NONE"
				dfhack.run_command_silent(command)
			end
		end
	elseif job.job_type == 68 then -- ConstructBuilding
		-- check that it's a generic Tribute
		local workshop = df.building.find(job.general_refs[0].building_id)
		if workshop and workshop.construction_stage == 3 and workshop.mat_type == 0 and not workshop.design then
			local workshop_mat = workshop_list[workshop.mat_index]  -- Will be nil if not on the list
			if workshop.custom_type == tribute_type and workshop_mat then
				workshop_mat_index = workshop.mat_index
				if workshop.contained_items[0].item.mat_index == workshop_mat_index and 
						workshop.contained_items[1].item.mat_index == workshop_mat_index and 
						workshop.contained_items[2].item.mat_index == workshop_mat_index then
					specificWorkshop(workshop.id,workshop_mat)
				end
			end
		end
	end
end




--Lets you make reactions that require water or magma under the workshop.  Reactions must start with LUA_HOOK_USEWATER or LUA_HOOK_USEMAGMA.
local eventful = require 'plugins.eventful'
local utils = require 'utils'
local debug = false

local function starts(String, Start)
	return string.sub(String, 1, string.len(Start)) == Start
end

-- Check for a liquid under the workshop at this unit's location. If found, take one level and return true.
function takeLiquid(unit, type, isCheckOnly)
	local building = dfhack.buildings.findAtTile(unit.pos)
	local pos = {}
	local liquidType = (type == 'magma')

	if not building then
		return false
	end

	pos.x1 = building.x1
	pos.x2 = building.x2
	pos.y1 = building.y1
	pos.y2 = building.y2
	pos.z = building.z

	for x = pos.x1-1, pos.x2+1, 1 do
		for y = pos.y1-1, pos.y2+1, 1 do
			baseBlock = dfhack.maps.ensureTileBlock(x,y,pos.z)
			liquidBlock = dfhack.maps.ensureTileBlock(x,y,pos.z-1)

			if liquidBlock.designation[x%16][y%16].flow_size > 0 and liquidBlock.designation[x%16][y%16].liquid_type == liquidType then
				if not isCheckOnly then
					liquidBlock.designation[x%16][y%16].flow_size = liquidBlock.designation[x%16][y%16].flow_size - 1
				end

				return true
			end
		end
	end

	return false
end

-- Perform the same search as takeLiquid but do not take it
function hasLiquid(unit, type)
	return takeLiquid(unit, type, true)
end

-- Remove the results from the reaction so none is created.
local function setReactionProducts(reaction, active)
	local probability = 100
	if not active then
		probability = 0
	end

	for i=0, #reaction.products-1, 1 do
		reaction.products[i].probability = probability
	end
end

-- Announce the canceled reaction and preserve the reagents.
local function cancelReaction(liquid, reaction, unit, input_reagents)
	local i

	dfhack.gui.showAnnouncement( dfhack.TranslateName(unit.name).." cancels "..reaction.name..": Needs "..liquid.." under the workshop." , COLOR_RED, true)

	for i=0, #input_reagents-1, 1 do
		input_reagents[i].flags.PRESERVE_REAGENT = true
	end
	
	setReactionProducts(reaction, false)
end

-- Try to take the liquid, if it fails, cancel the reaction. liquid should be set to 'water' or 'magma'
local function useliquid(liquid, reaction, unit, input_reagents)
	if takeLiquid(unit, liquid) then
		setReactionProducts(reaction, true)
		return true
	end

	cancelReaction(liquid, reaction, unit, input_reagents)

	return false
end

-- Use magma
function usemagma(reaction, unit, input_reagents)
	return useliquid('magma', reaction, unit, input_reagents)
end

-- Use water
function usewater(reaction, unit, input_reagents)
	return useliquid('water', reaction, unit, input_reagents)
end

-- Use both water and magma
function useboth(reaction, unit, input_reagents)
	if hasLiquid(unit, 'water') and hasLiquid(unit, 'magma') then
		takeLiquid(unit, 'water')
		takeLiquid(unit, 'magma')
		setReactionProducts(reaction, true)
		return true;
	end

	cancelReaction('both water and magma', reaction, unit, input_reagents)

	return false
end

-- Main reaction complete effect
eventful.onReactionCompleting.waterwell = function(reaction, reaction_product, unit, input_items, input_reagents, output_items, call_native)
	if starts(reaction.code,'LUA_HOOK_USEWATER') then
		call_native = usewater(reaction, unit, input_reagents)
	elseif starts(reaction.code,'LUA_HOOK_USEMAGMA') then
		call_native = usemagma(reaction, unit, input_reagents)
	elseif starts(reaction.code,'LUA_HOOK_USELIQUIDS') then
		call_natice = useboth(reaction, unit, input_reagents)
	end
end

if debug then
	print('Use Liquid Reactions: Loaded.')
end

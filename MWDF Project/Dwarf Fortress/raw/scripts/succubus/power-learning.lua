-- Test if the succubus is able to learn a power

local eventful = require 'plugins.eventful'
local utils = require 'utils'

--http://lua-users.org/wiki/StringRecipes  (removed indents since I am not using them)
function wrap(str, limit)--, indent, indent1)
	--indent = indent or ""
	--indent1 = indent1 or indent
	local limit = limit or 72
	local here = 1 ---#indent1
	return str:gsub("(%s+)()(%S+)()",	--indent1..str:gsub(
							function(sp, st, word, fi)
								if fi-here > limit then
									here = st -- - #indent
									return "\n"..word --..indent..word
								end
							end)
end

-- Simulate a canceled reaction message, save the reagents
local function cancelReaction(reaction, unit, input_reagents, message)
	local lines = utils.split_string(wrap(
			string.format("%s, %s cancels %s: %s.", dfhack.TranslateName(dfhack.units.getVisibleName(unit)), dfhack.units.getProfessionName(unit), reaction.name, message)
		) , NEWLINE)
	for _, v in ipairs(lines) do
		dfhack.gui.showAnnouncement(v, COLOR_RED)
	end

	for _, v in ipairs(input_reagents or {}) do
		v.flags.PRESERVE_REAGENT = true
	end

end

-- Make sure that there is not already a power on the unit.
function hasSyndromeClass(unit, isMajor)
	local synClass
	if(isMajor) then
		synClass = 'MAJOR_POWER'
	else
		synClass = 'MINOR_POWER'
	end

	for i,unitSyndrome in ipairs(unit.syndromes.active) do
		local syndrome = df.syndrome.find(unitSyndrome.type)
			for _,class in ipairs(syndrome.syn_class) do
				if class.value == synClass then
					return true
				end
			end
		end
	return false
end

-- Adds the power on the unit
function activatePower(unit, code)
	local synName

	if code == 'LUA_HOOK_SUCCUBUS_UPGRADE_FIRE_SECRET' then
		synName = 'Pyromaniac (fireballs, directed ash, firejet)'
		synMessageName = 'the secrets of hellfire'
	elseif code == 'LUA_HOOK_SUCCUBUS_UPGRADE_LUST_SECRET' then
		synName = 'Courtesan (pheromones, entice)'
		synMessageName = 'the secrets of lust'
	elseif code == 'LUA_HOOK_SUCCUBUS_UPGRADE_PHASING' then
		synName = 'Phasing'
		synMessageName = 'dimensional phasing'
	end

	dfhack.run_script('modtools/add-syndrome', '-target', unit.id, '-syndrome', synName, '-resetPolicy', 'DoNothing')
	announcement(unit, synMessageName)
end

-- Adds a message telling the user that this was a success.
function announcement(unit, synName)
	local lines = utils.split_string(wrap(
			string.format("%s has learned %s.", dfhack.TranslateName(dfhack.units.getVisibleName(unit)), synName)
		) , NEWLINE)
	for _, v in ipairs(lines) do
		dfhack.gui.showAnnouncement(v, COLOR_WHITE)
	end
end

eventful.onReactionComplete.succubusPower = function(reaction, reaction_product, unit, input_items, input_reagents, output_items, call_native)
	local isMajor, message

	if 
		reaction.code == 'LUA_HOOK_SUCCUBUS_UPGRADE_FIRE_SECRET' or
		reaction.code == 'LUA_HOOK_SUCCUBUS_UPGRADE_LUST_SECRET'
	then
		isMajor = true
		message = 'already have a major power'
	elseif
		reaction.code == 'LUA_HOOK_SUCCUBUS_UPGRADE_PHASING'
	then
		isMajor = false
		message = 'already have a minor power'
	else
		-- Not a reaction handled by this script, abort
		return
	end

	if hasSyndromeClass(unit, isMajor) then
		cancelReaction(reaction, unit, input_reagents, message)
		return
	end

	activatePower(unit, reaction.code)
end

print("Succubus power reactions: Loaded.")

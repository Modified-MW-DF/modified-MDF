-- Check periodically for intelligents pets without historical figures
--[[
	In some cases, intelligent creatures will go in your fort without proper data to act as a citizen.
	As a result, they cannot join your military or perform labor.

	This script uses create-unit to general an historical figure for them.

	Only act on living, sane and non civ race creatures.

	@todo Check for intelligence, it currently create nemesis for all pets.
	@author Boltgun
]]

local createUnit = dfhack.script_environment('modtools/create-unit')
local debug = false

-- Create an historical figure out of an unit, related to the curent fort.
function createHistFig(unit)
	createUnit.createNemesis(unit, df.global.ui.civ_id, df.global.ui.group_id)
end

function scanForPetsWithNoNemesis()
	local cAffected = 0
	local unitList = df.global.world.units.active
	local unit, i

	for i = #unitList - 1, 0, -1 do
		unit = unitList[i]

		local raws = df.creature_raw.find(unit.race)
		local caste = raws.caste[unit.caste]
		local intelligent = caste.flags.CAN_LEARN or caste.flags.CAN_SPEAK

		if(
			intelligent and -- Must have at least partial intelligence
			not unit.flags1.merchant and -- Not a merchant
			unit.civ_id == df.global.ui.civ_id and -- In current civ
			not dfhack.units.isDwarf(unit) and -- Fort citizen
			dfhack.units.isAlive(unit) and -- Alive, not zombie
			dfhack.units.isSane(unit) and -- Not be CRAZED
			not unit.flags2.underworld and -- Not a clown from the circus
			not dfhack.units.getNemesis(unit) -- Have no nemesis
		) then
			createHistFig(unit)
			cAffected = cAffected + 1
		end	
	end

	if(debug) then
		print("smartpets: "..cAffected.." creature(s) fixed")
	end
end

if df.global.gamemode == df.game_mode.DWARF then
	if(debug) then
		print("smartpets: scanning for intelligent citizens without nemesis...")
	end

	scanForPetsWithNoNemesis()
	dfhack.timeout(3, 'days', function() dfhack.run_script('fix/smartpets') end)
end

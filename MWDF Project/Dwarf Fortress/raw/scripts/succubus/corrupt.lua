-- Sets the units within line of sight of the unit as non hostiles, members of your civ and transform them
--[[
	This script is called by the conversion dens.
	It will perform makeown on the target unit and perform some more fix to prevent loyalty cascades.
	It will also remove flags related to invasions and mounting.
	Merchants will give up trading and their dragged animals join as well, their wagons will be scuttled.
	The targets will be let out of their cages

	These units should be ready to act as citizen once transformed.

	If you wish to implement this feature to your race, add a creature to caste set at the end of the file.

	arguments
	    -help
	        print this help message
	    -unit <number>
	        The unit at the source of the corruption
	    -set <string>
	        One of the available creature sets, currently only succubus

	@requires fov
	@author Boltgun
]]
if not dfhack.isMapLoaded() then qerror('Map is not loaded.') end

-- Dependancies
local utils = require 'utils'
local mo = require 'makeown'
local fov = dfhack.script_environment('modtools/fov')
local teleport = dfhack.script_environment('teleport')
local createUnit = dfhack.script_environment('modtools/create-unit')
-- The range of the check FOV
local range = 10

-- Will print debug messages if set to true
local debug = true

-- Announcement to help understand what is happenning
local announceMerchant = false
local announceFailure = true

-- Misc
local unitSource, targetRace, creatureSet, popId

--
-- Functions
--

-- Announcement of a hint if you corrupted a merchant
local function marchantAnnouncement()
	if not announceMerchant then return end
	dfhack.timeout(
		3,
		'ticks',
		function() 
			dfhack.gui.showAnnouncement("You corrupted merchants. Deconstruct the trade depot to seize the goods.", COLOR_WHITE) 
		end
	)
end

-- Announcement of a hint if you ran the den without targets
local function failureAnnouncement()
	if not announceFailure then return end
	dfhack.timeout(
		3,
		'ticks',
		function() 
			dfhack.gui.showAnnouncement("There were no valid target for corruption.", COLOR_WHITE) 
		end
	)
end

-- Check boundaries and field of view, z level must be the same
local function validateCoords(unit, view)
	local pos = {dfhack.units.getPosition(unit)}

	if 
		pos[1] < view.xmin or pos[1] > view.xmax or
		pos[2] < view.ymin or pos[2] > view.ymax or
		view.z ~= pos[3]
	then
		return false
	end

	return view[pos[2]][pos[1]] > 0
end

-- Check if the unit is seen and belong to the set
local function isSelected(unit, view)
	local creatureId = tostring(df.global.world.raws.creatures.all[unit.race].creature_id)

	if nil ~= creatureSet[creatureId] and
		not dfhack.units.isDead(unit) and
		not dfhack.units.isOpposedToLife(unit) then
			return validateCoords(unit, view)
	end

	return false
end

-- Find targets within the LOS of the creature
local function findLos(unitSource)
	local view = fov.get_fov(range, unitSource.pos)
	local i, hf, k, v
	local unitList = df.global.world.units.active

	-- Check through the list for the right units
	for i = #unitList - 1, 0, -1 do
		unitTarget = unitList[i]
		if isSelected(unitTarget, view) then
			corrupt(unitTarget)
			announceFailure = false
		end
	end

	-- Post process
	marchantAnnouncement()
	failureAnnouncement()
end

-- Erase the enemy links
function clearEnemy(unit)
	hf = utils.binsearch(df.global.world.history.figures, unit.hist_figure_id, 'id')

	if not hf then return end

	for k, v in ipairs(hf.entity_links) do
		if df.histfig_entity_link_enemyst:is_instance(v) and
			(v.entity_id == df.global.ui.civ_id or v.entity_id == df.global.ui.group_id)
		then
			newLink = df.histfig_entity_link_former_prisonerst:new()
			newLink.entity_id = v.entity_id
			newLink.link_strength = v.link_strength
			hf.entity_links[k] = newLink
			v:delete()
			if debug then print('deleted enemy link') end
		end
	end

	-- Make DF forget about the calculated enemies (ported from fix/loyaltycascade)
	if not (unit.enemy.enemy_status_slot == -1) then
		i = unit.enemy.enemy_status_slot
		unit.enemy.enemy_status_slot = -1
        
        --[[cache = df.world.enemy_status_cache
        cache.slot_used[i] = false
		cache.rel_map[i].map! { -1 }
        cache.rel_map[i].map! { -1 }
        cache.rel_map.each { |a| a[i] = -1 }
        cache.next_slot = i if cache.next_slot > i]]

		if debug then print('enemy cache removed') end
	end
end

-- Clears dragging and riding of mounts/wagons, draggees also join your civ
function clearMerchant(unit)
	local draggee

	-- Free the draggee as well and makeown + tame it
	if -1 ~= unit.relationship_ids.draggee_id then
		dragee = utils.binsearch(df.global.world.units.active, unit.relationship_ids.draggee_id, 'id')

		if dragee then
			mo.make_own(dragee)
			dragee.relationship_ids.dragger_id = -1
			dragee.flags1.tame = true
			dragee.training_level = df.animal_training_level.Domesticated
		end
	end

	unit.relationship_ids.draggee_id = -1
	unit.relationship_ids.rider_mount_id = -1
	unit.relationship_ids.mount_type = 0
	unit.flags1.rider = 0
end

-- Take the creature out of its cage
function clearCage(unit)
	local cage = dfhack.units.getContainer(unit)
	
	if -1 ~= cage then
		teleport.teleport(unit, xyz2pos(dfhack.units.getPosition(unit)))
	end

	unit.flags1.caged = false
end

-- Takes down any hostility flags that mo didn't handle
function clearHostile(unit)
	unit.population_id = popId
	unit.cultural_identity = -1
	
	unit.flags1.marauder = false
	unit.flags1.active_invader = false
	unit.flags1.hidden_in_ambush = false
	unit.flags1.hidden_ambusher = false
	unit.flags1.invades = false
	unit.flags1.coward = false
	unit.flags1.invader_origin = false
	
	unit.flags2.underworld = false
	unit.flags2.visitor_uninvited = false
	unit.flags2.visitor = false
	unit.flags2.resident = false
	unit.flags2.calculated_nerves = false
	unit.flags2.calculated_bodyparts = false

	unit.invasion_id = -1
	--acts if it doesn't exist....
	--if unit.relationship_ids.group_leader then unit.relationship_ids.group_leader = -1 end
	--if unit.relationship_ids.last_attacker then unit.relationship_ids.last_attacker = -1 end

	unit.flags3.body_part_relsize_computed = false
	unit.flags3.body_temp_in_range = true
	unit.flags3.size_modifier_computed = false
	unit.flags3.compute_health = true
	unit.flags3.weight_computed = false

    unit.counters.soldier_mood_countdown = -1
    unit.counters.death_cause = -1

    unit.animal.population.region_x = -1
    unit.animal.population.region_y = -1
    unit.animal.population.unk_28 = -1
    unit.animal.population.population_idx = -1
    unit.animal.population.depth = -1

    unit.counters.soldier_mood_countdown = -1
    unit.counters.death_cause = -1

    -- weird, unknown territory
    unit.enemy.anon_4 = -1
    unit.enemy.anon_5 = -1
    unit.enemy.anon_6 = -1
	--unit.enemy.anon_7 = 0
    --unit.status2.unk_7c0 = -1
    --unit.enemy.unk_v40_2_count = 11
    --unit.unk_100 = 3
end

function findRaceAndCaste(raceRawId, casteRawId)
  --find race
  local race, raceIndex, casteIndex
  for i,v in ipairs(df.global.world.raws.creatures.all) do
    if v.creature_id == raceRawId then
      raceIndex = i
      race = v
    end
  end

  -- find caste
  if race then
    for i,v in ipairs(race.caste) do
      if v.caste_id == casteRawId then
        casteIndex = i
      end
    end
  else -- race failed
    return nil, nil
  end

  return raceIndex, casteIndex
end


-- Change the creature race, take down hostility and  merchant flags, free cages and trading
function corrupt(unit)
	local origRace = tostring(df.global.world.raws.creatures.all[unit.race].creature_id)
	local suffix

	-- After taking the enemy to your side, transform it
	if debug then print('origRace: '..origRace..', targetRace: '..targetRace) end

	if targetRace ~= origRace then 
		local targetCaste = creatureSet[origRace]
		if nil ~= targetCaste then
			if unit.sex == 1 then
				suffix = "_MALE"
			else
				suffix = "_FEMALE"
			end
			targetCaste = targetCaste..suffix
			if debug then print('selected caste: '..targetCaste) end

			local raceIndex, casteIndex = findRaceAndCaste(targetRace, targetCaste)

			if raceIndex==nil then
				if debug then print('raceIndex returned nil') end
				return nil
			elseif casteIndex==nil then
				if debug then print('raceIndex returned nil') end
				return nil
			end
			
			local position = { dfhack.units.getPosition(unit) }

			local newUnitId = createUnit.createUnitInCiv(raceIndex, casteIndex, df.global.ui.civ_id, df.global.ui.group_id, position)
--			dfhack.run_script('modtools/transform-unit', '-unit', unit.id, '-race', targetRace, '-caste', targetCaste, '-keepInventory', 1)
			
			-- grab the newUnit pointer from the index above
			local newUnit = df.unit.find(newUnitId)

			newUnit.civ_id=df.global.ui.civ_id

			-- hopefully will force DF to recallculate all the stuff it needs to.
			newUnit.flags2.calculated_nerves = false
			newUnit.flags2.calculated_bodyparts = false
			newUnit.flags3.body_part_relsize_computed = false
			newUnit.flags3.size_modifier_computed = false
			newUnit.flags3.compute_health = true
			newUnit.flags3.weight_computed = false

			-- here we need to copy all the names and stuff over to this newUnit from the old unit....
			newUnit.name.has_name = true
			if newUnit.status.current_soul then
				newUnit.status.current_soul.name.has_name = true
			end

		-- Assign the newUnit name according to the old Unit's name.
			newUnit.name:assign(unit.name)
			local newUnitHf = utils.binsearch(df.global.world.history.figures, newUnit.hist_figure_id, 'id')
			newUnitHf.name:assign(unit.name)
			
 		-- age
			newUnit.birth_year = unit.birth_year
			newUnit.birth_time = unit.birth_time
			newUnit.birth_year_bias = unit.birth_year_bias
			newUnit.birth_time_bias = unit.birth_time_bias
		
		--relationship_ids 
		-- from amostubal -"Is this the way?  If I understood it correctly every pet, has its owner
		-- as a pet. same for spouse etc. except mother and father don't have selections for children?"
		-- might need some help with finding and setting the old part.
			if -1 ~= unit.relationship_ids.Pet then
				newUnit.relationship_ids.Pet = unit.relationship_ids.Pet
				local pet = df.unit.find(unit.relationship_ids.Pet)
				pet.relationship_ids.Pet = newUnitId
			end

			if -1 ~= unit.relationship_ids.Spouse then
				newUnit.relationship_ids.Spouse = unit.relationship_ids.Spouse
				local spouse = df.unit.find(unit.relationship_ids.Spouse)
				spouse.relationship_ids.Spouse = newUnitId
			end

			if -1 ~= unit.relationship_ids.Lover then
				newUnit.relationship_ids.Lover = unit.relationship_ids.Lover
				local lover = df.unit.find(unit.relationship_ids.Lover)
				lover.relationship_ids.Lover = newUnitId
			end

			if -1 ~= unit.relationship_ids.Mother then
				newUnit.relationship_ids.Mother = unit.relationship_ids.Mother
				local Mother = df.unit.find(unit.relationship_ids.Mother)
				-- need to find out how to link a father to a child.
			end

			if -1 ~= unit.relationship_ids.Father then
				newUnit.relationship_ids.Father = unit.relationship_ids.Father
				local Father = df.unit.find(unit.relationship_ids.Father)
				-- need to find out how to link a father to a child.
			end

			-- need to find out how children and parents work altogether.


		-- Amostubal - I wrote this, but didn't test this, was afraid it would mess something up with the grouping.
		--[[ steal an existing historical figure of the old unit if it exists. 
			if unit.hist_figure_id then
				newUnit.hist_figure_id = unit.hist_figure_id
				hf = utils.binsearch(df.global.world.history.figures, unit.hist_figure_id, 'id')
				hf.unit_id = newUnitId -- resets the hf to the new unit.
				newUnit.flags1.important_historical_figure = unit.flags1.important_historical_figure
			end
			if unit.hist_figure_id2 then
				newUnit.hist_figure_id2 = unit.hist_figure_id2
				hf = utils.binsearch(df.global.world.history.figures, unit.hist_figure_id2, 'id')
				hf.unit_id = newUnitId -- resets the hf to the new unit.
				newUnit.flags2.important_historical_figure = unit.flags2.important_historical_figure
			end

		-- steal a soul?
			if unit.status.current_soul then
				newUnit.status.current_soul = unit.status.current_soul
				unit.status.current_soul.unit_id = newUnitId
			end
		--]]

		-- maybe need to grab their stuff?

		-- can't think of anything else, but if there is it needs to go here.
	

		--Delete the old unit if you made it to here... otherwise ignore it.  If you put it anywhere else, it will kill off units that don't have a targetcaste or worse who are succubus....
			clearCage(unit) -- have to get it out of the cage first.
			teleport.teleport(unit, xyz2pos( 0, 0, 0 ))
			unit.flags3.scuttle=true
		
		end
	end
	
--[[	mo.make_own(unit)
	mo.make_citizen(unit)
	
	-- Setting announcements
	if unit.flags1.merchant == true then 
		announceMerchant = true 
	end

	-- Removes all the previous behaviour
	clearEnemy(unit)
	clearHostile(unit)
	clearMerchant(unit)
	clearCage(unit)
--]]


end

--
-- Action
--

validArgs = validArgs or utils.invert({
    'help',
    'unit',
    'set',
})

local args = utils.processArgs({...}, validArgs)

if args.help then
 print([[scripts/succubus/corrupt.lua
arguments
    -help
        Print this help message
    -unit <number>
        The unit at the source of the corruption
    -set <string>
        One of the available creature sets, currently only "succubus" is accepted
]])
 return
end

-- The source unit
if not args.unit then qerror('Not unit provided, check succubus/corrupt -help') end

unitSource = df.unit.find(tonumber(args.unit))
if not unitSource then qerror('Unit not found.') end

-- The transformation set, syntax is {RACE = 'TARGET_CASTE'}
-- TARGET_CASTE can be false, then no transformation occur
-- The played fort's race must contain the castes 
if args.set == 'succubus' then
	creatureSet = {
		WARLOCK_CIV = 'DEVIL',
		HUMAN = 'DEVIL',
		DWARF = 'FIEND',
		ELF = 'CAMBION',
		GNOME_CIV = 'KORRIGAN',
		KOBOLD = 'IMP',
		GOBLIN = 'HELLION',
		ORC_TAIGA = 'ONI',
		SUCCUBUS = false,
		-- FD
		FROG_MANFD = 'DEVIL',
		IMP_FIRE_FD = 'IMP',
		BLENDECFD = 'DEVIL',
		WEREWOLFFD = 'DEVIL',
		SERPENT_MANFD = 'CAMBION',
		TIGERMAN_WHITE_FD = 'CAMBION',
		BEAK_WOLF_FD = 'HELLION',
		ELF_FERRIC_FD = 'CAMBION',
		ELEPHANTFD = 'ONI',
		STRANGLERFD = 'HELLION',
		JOTUNFD = 'ONI',
		MINOTAURFD = 'ONI',
		SPIDER_FIEND_FD = 'DEVIL',
		NIGHTWINGFD = 'IMP',
		GREAT_BADGER_FD = 'IMP',
		PANDASHI_FD = 'FIEND',
		RAPTOR_MAN_FD = 'DEVIL'
	}
else
	qerror("Invalid set, check succubus/corrupt -help")
end

-- Starts the corruption process
targetRace = df.global.world.raws.creatures.all[df.global.ui.race_id].creature_id
popId = unitSource.population_id
findLos(unitSource) 

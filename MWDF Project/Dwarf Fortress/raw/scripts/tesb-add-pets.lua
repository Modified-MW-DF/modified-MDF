-- Made by Dirst for the Earth Strikes Back mod
-- Based on AddPetToCiv

local utils=require 'utils'

local args = utils.processArgs({...}, validArgs)

validArgs = validArgs or utils.invert({
 'help',
 'entity',
 'race',
 'sort'
})

if args.help then
	print([[tesb-add-pets.lua
Adds specific castes to each civ based on discovered minerals
Based on AddPetToCiv.lua
arguments
    -help
        print this help message
    -entity <ENTITY_ID>
        The raw id of the target entity, e.g. MOUNTAIN
    -race <CREATURE_ID>
        The raw id of a creature, e.g. TESB_PET_ROCK
	-sort
		Sorts the castes alphabetically (by ID) before adding
]])
	return
end


function insertPet(civ_id,creature,caste)
	local exists=false
	civ = df.global.world.entities.all[civ_id]
	-- Original AddPetToCiv targets all civs belonging to the same ENTITY raw
	-- This version allows each instanced civ to have its own list
	for k,v in pairs(civ.resources.animals.pet_races) do
		local checkrace = df.creature_raw.find(v)
		local checkcaste = checkrace.caste[civ.resources.animals.pet_castes[k]]
		if checkrace.creature_id == creature and checkcaste.caste_id == caste then exists=true end
	end
	if exists==true then
	else
		--the civ doesn't have the creature as a pet
		--add the creature as a pet
		local racenum=-1
		local castenum=-1
		for k,v in pairs(df.global.world.raws.creatures.all) do
			if v.creature_id==creature then 
				racenum=k
				for kk,vv in pairs(v.caste) do
					if vv.caste_id==caste then castenum=kk end
				end
				break
			end
		end
		if racenum > -1 and castenum > -1 then
			civ.resources.animals.pet_races:insert('#',racenum)
			civ.resources.animals.pet_castes:insert('#',castenum)
			--print("Inserted "..creature..":"..caste.." in civ "..dfhack.TranslateName(df.global.world.entities.all[civ_id].name))
		else
			-- Invalid caste.  Print a message and do NOT increment the pet count.
			print(creature..":"..caste.." not found in the raws")
			exists = true
		end
	end
	return not exists
end

--Find race's common name
for k,v in ipairs(df.global.world.raws.creatures.all) do
  if v.creature_id == args.race then
    raceSingle = df.creature_raw.find(k).name[0]
	racePlural = df.creature_raw.find(k).name[1]
    break
  end
end


-- List of layer stones that coincide with Pet Rock castes
stone_list = { "ANDESITE", "BASALT", "CHALK", "CHERT", "CLAYSTONE",
	"CONGLOMERATE", "DACITE", "DIORITE", "DOLOMITE", "GABBRO", "GNEISS", 
	"GRANITE", "LIMESTONE", "MARBLE", "MUDSTONE", "PHYLLITE", "QUARTZITE",
	"RHYOLITE", "ROCK_SALT", "SANDSTONE", "SCHIST", "SHALE", "SILTSTONE",
	"SLATE" }

caste_list = {}

-- Lists indexed by material ID numbers
for mat = 1, #stone_list do
	local index = dfhack.matinfo.find(stone_list[mat]).index
	caste_list[index] = stone_list[mat]
end

-- Identify appropriate castes for each instanced civ of the correct entity type
for k,civ in pairs(df.global.world.entities.all) do
	local pet_list = {}
	if civ.type==0 and civ.entity_raw.code==args.entity then
		for kk,mat in pairs(civ.resources.stones) do
			if caste_list[mat] then
				pet_list[1 + #pet_list] = caste_list[mat]
			end
		end
		if args.sort then table.sort(pet_list) end
		local pet_count = 0
		-- Pets aren't valid until successfully inserted, so maintaining a count of successes
		for kk,pet_caste in ipairs(pet_list) do
			if insertPet(civ.id,args.race,pet_caste) then pet_count = pet_count + 1 end
		end
		if pet_count > 1 then 
			print("Added "..pet_count.." kinds of "..racePlural.." to "..dfhack.df2console(dfhack.TranslateName(df.global.world.entities.all[civ.id].name)).." ("..dfhack.df2console(dfhack.TranslateName(df.global.world.entities.all[civ.id].name,true))..").")
		elseif pet_count == 1 then
			print("Added 1 kind of "..raceSingle.." to "..dfhack.df2console(dfhack.TranslateName(df.global.world.entities.all[civ.id].name)).." ("..dfhack.df2console(dfhack.TranslateName(df.global.world.entities.all[civ.id].name,true))..").")
		end
	end
end

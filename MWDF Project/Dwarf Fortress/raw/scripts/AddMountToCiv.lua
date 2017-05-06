-- Adds a mount to the civ. Mounts are used in sieges.
--[=[
    Adds a mount to the civ. Mounts are used in sieges.
    This allows to add any creature to the list, even if it would be prohibited by the entity raw.
    Please note that you need to add the castes individually, for exemple once for MALE and once for FEMALE.

    arguments
        -help
            print this help message
        -civ <ENTITY_ID>
            The raw id of the target entity
        -race <CREATURE_ID>
            The raw id of a creature
        -caste <CASTE_ID>
            The caste's raw id, optional

    Example : AddMountToCiv -civ MOUNTAIN -race DOG -caste MALE
]=]
local utils=require 'utils'

function insertPet(entity,creature,caste)
	local exists=false
	for k,v in pairs(df.global.world.entities.all) do
		--ENTITY TYPES
		--Civilization	0
		--SiteGovernment	1
		--VesselCrew	2
		--MigratingGroup	3
		--NomadicGroup	4
		--Religion	5
		--MilitaryUnit	6
		--Outcast	7
		if v.type==0 and v.entity_raw.code==entity then --exclude bandits
			--print(k)
			--printall(v.resources.animals)
			for kk,vv in pairs(v.resources.animals.mount_races) do
				--print(kk,vv,v.resources.animals.mount_castes[kk])
				local checkrace = df.creature_raw.find(vv)
				local checkcaste = checkrace.caste[v.resources.animals.mount_castes[kk]]
				--print(checkrace.creature_id, checkcaste.caste_id)
				if checkrace.creature_id == creature and checkcaste.caste_id == caste then exists=true end
			end
			if exists==true then
				--print("ERROR- civilization ",entity," has creature ", creature, caste)
			else
				--the civ doesn't have the creature as a pet
				--add the creature as a pet
				local racenum=-1
				local castenum=-1
				for kk,vv in pairs(df.global.world.raws.creatures.all) do
					--print(vv.creature_id)
					if vv.creature_id==creature then 
						racenum=kk
						--print(kk)
						--printall(vv.caste)
						for kkk,vvv in pairs(vv.caste) do
							--print(vvv.caste_id)
							if vvv.caste_id==caste then castenum=kkk end
						end
						break
					end
				end
				if racenum > -1 and castenum > -1 then
					--print("success!!")
					--print(v)
					v.resources.animals.mount_races:insert('#',racenum)
					v.resources.animals.mount_castes:insert('#',castenum)
					print("Inserted ", creature, caste, " in civ ",k, entity)
				else
					print(creature, caste, " not found in raws")
				end
			end
		end
		exists=false
	end
end

ValidArgs = validArgs or utils.invert({
    'help',
    'civ',
    'race',
    'caste'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
 print([[scripts/spawn-unit.lua
arguments
    -help
        print this help message
    -civ <ENTITY_ID>
        The raw id of the target entity
    -race <CREATURE_ID>
        The raw id of a creature
    -caste <CASTE_ID>
        The caste's number, optional
]])
	return
end

if not moduleMode then
    insertPet(args.civ, args.race, args.caste)
end
--comment


local function insertPet(entity,creature,caste)
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
			for kk,vv in pairs(v.resources.animals.minion_races) do
				--print(kk,vv,v.resources.animals.minion_castes[kk])
				local checkrace = df.creature_raw.find(vv)
				local checkcaste = checkrace.caste[v.resources.animals.minion_castes[kk]]
				--print(checkrace.creature_id, checkcaste.caste_id)
				if checkrace.creature_id == creature and checkcaste.caste_id == caste then exists=true end
			end
			if exists==true then
				print("ERROR- civilization ",entity," has creature ", creature, caste)
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
					v.resources.animals.minion_races:insert('#',racenum)
					v.resources.animals.minion_castes:insert('#',castenum)
					print("Inserted ", creature, caste, " in civ ",k, entity)
				else
					print(creature, caste, " not found in raws")
				end
			end
		end
		exists=false
	end
end


--kobolds
--insertPet("KOBOLD_CAMP","OGRE_KOBOLD","MALE")
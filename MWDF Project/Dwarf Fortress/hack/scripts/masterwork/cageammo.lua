local eventful = require 'plugins.eventful'

local function posIsEqual(pos1,pos2)
	if pos1.x ~= pos2.x or pos1.y ~= pos2.y or pos1.z ~= pos2.z then return false end
	return true
end

function createItem(mat,itemType,quality,pos)
	pname = itemType[1]
    local item=df['item_'..pname..'st']:new() --incredible
    item.id=df.global.item_next_id
    df.global.world.items.all:insert('#',item)
    df.global.item_next_id=df.global.item_next_id+1
    if itemType[2]~=-1 then
        item:setSubtype(itemType[2])
    end
    item:setMaterial(mat.type)
    item:setMaterialIndex(mat.index)
    item:categorize(true)
    item.flags.removed=true
    item:setSharpness(1,0)
    item:setQuality(quality)
    dfhack.items.moveToGround(item,{x=pos.x,y=pos.y,z=pos.z})
	return item
end

eventful.onProjItemCheckImpact.capture=function(projectile)
	if projectile then
		if getmetatable(projectile.item) == 'item_ammost' then
			print(projectile.item.name)
			if string.starts(projectile.item.ammo_class,'DFHACK_PROJCAGE') then
				local material = dfhack.matinfo.decode(projectile.item)
				
				if not material then return nil end
				local unit = nil
				for uid,u in ipairs(df.global.world.units.active) do
					if posIsEqual(u.pos,projectile.cur_pos) then unit = u end
				end
				
				local cage = createItem(material,{'cage',-1},0,projectile.cur_pos)
				if unit ~= nil then
				
					
					local damagefactor = 1
					if unit.counters.winded > 0 then damagefactor = damagefactor/1.5 end
					if unit.counters.stunned > 0 then damagefactor = damagefactor/1.5 end
					if unit.counters.unconscious > 0 then damagefactor = damagefactor/2 end
					if unit.counters.webbed > 0 then damagefactor = damagefactor/1.5 end
					if unit.counters.nausea > 0 then damagefactor = damagefactor/1.5 end
					local bloodfrac = 1
					blood_max = unit.body.blood_max
					if blood_max == 0 then bloodfrac = 1
					else bloodfrac = unit.body.blood_count/unit.body.blood_max end
					local prob = 100 - (math.pow(unit.body.size_info.size_cur*10,1/3)*bloodfrac*damagefactor)
					
					if math.random(100) > prob then
						cage_ref = df.general_ref_contained_in_itemst:new()
						cage_ref.item_id = cage.id
						unit.general_refs:insert('#',cage_ref)
						unit.flags1.caged = true
						
						--make other units stop following it
						for i=#allUnits-1,0,-1 do	-- search list in reverse
							newu = allUnits[i]
							if newu.relations.following == unit then
								newu.relations.following = nil
							end
						end
						
						unit_ref = df.general_ref_contains_unitst:new()
						unit_ref.unit_id = unit.id
						cage.general_refs:insert('#',unit_ref)
					end
					
					projectile.flags.to_be_deleted=true
				end
			end
		end
	end
	return true
end

local builds=require 'plugins.building-hacks'
local eventful= require 'plugins.eventful'
local guidm   =require 'gui.dwarfmode'
local widgets =require 'gui.widgets'

local phylactery_gears={
	{x=0,y=3},
	{x=6,y=3},
	{x=3,y=0},
	{x=3,y=6},
}
function get_owner(workshop)
	if #workshop.parents>0 and workshop.parents[0].owner~=nil then
		return workshop.parents[0].owner
	end
end
function find_corpse_parts(unit)
	local ret={}
	for i,v in ipairs(unit.corpse_parts) do
		local it=df.item.find(v)
		if it then
			table.insert(ret,it)
		end
	end
	return ret
end
function dist_it(pos,pos2)
	local dx=pos.x-pos2.x
	local dy=pos.y-pos2.y
	local dz=pos.z-pos2.z
	return math.sqrt(dx*dx+dy*dy+dz*dz)
end
function nearest_item(pos,items)
	local nearest={dist=10000}
	for i,v in ipairs(items) do
		local x,y,z=dfhack.items.getPosition(v)
		local it_pos={x=x,y=y,z=z}
		if v.pos.z==it_pos.z then
			local d=dist_it(pos,it_pos)
			if nearest.dist>d then
				nearest.dist=d
				nearest.it=v
			end
		end
	end
	return nearest
end
function nearest_corpse_owner( workshop )
	local owner=get_owner(workshop)
	local it=nearest_item({x=workshop.centerx,y=workshop.centery,z=workshop.z},
			find_corpse_parts(owner))
	return it
end
phylactery_sidebar=defclass(phylactery_sidebar,guidm.WorkshopOverlay)
	
function phylactery_sidebar:init(args)
	local owner
	owner=get_owner(self.workshop)
	local owner_text = {}
	if owner then
		owner_text.text=dfhack.TranslateName(owner.name)
	else
		owner_text.text="<no owner, disabled>"
		owner_text.pen={fg=COLOR_LIGHTRED}
	end
	self.owner=owner
    self:addviews{
    widgets.Panel{
        subviews = {
            widgets.Label{ text="Phylactery", frame={t=1,l=1} },
            widgets.Label{ text={{text="Owner:"},owner_text}, frame={t=3,l=1} },
            widgets.Label{ text={{text="Status:"},{text=self:status_text()}}, frame={t=4,l=1} },
            
            widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
            widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
        }
    }
    }
end
function phylactery_sidebar:status_text()
	if self.workshop:isUnpowered() then
		return "No power"
	end
	local item=nearest_corpse_owner(self.workshop)
	print(item.dist)
	if self.owner==nil then
		return "Disabled"
	elseif self.owner.flags1.dead then
		if item.dist>25 then
			return "Dead, corpse parts too far"
		else
			return "Dead, reconstructing"
		end
	else
		return "Idle"
	end
end
function remove_corpse_parts(items)
	for i,v in ipairs(items) do
		--dfhack.items.remove(v)
		v.flags.removed=true
		v.flags.garbage_collect=true
	end
end
function full_heal(unit,resurrect)
	if resurrect then
		if unit.flags1.dead then
			--print("Resurrecting...")
			unit.flags2.slaughter = false
			unit.flags3.scuttle = false
		end
		unit.flags1.dead = false
		unit.flags2.killed = false
		unit.flags3.ghostly = false
		--unit.unk_100 = 3
	end
	
	--print("Erasing wounds...")
	while #unit.body.wounds > 0 do
		unit.body.wounds[#unit.body.wounds-1]:delete()
		unit.body.wounds:erase(#unit.body.wounds-1)
	end
	unit.body.wound_next_id=1

	--print("Refilling blood...")
	unit.body.blood_count=unit.body.blood_max

	--print("Resetting grasp/stand status...")
	unit.status2.limbs_stand_count=unit.status2.limbs_stand_max
	unit.status2.limbs_grasp_count=unit.status2.limbs_grasp_max

	--print("Resetting status flags...")
	unit.flags2.has_breaks=false
	unit.flags2.gutted=false
	unit.flags2.circulatory_spray=false
	unit.flags2.vision_good=true
	unit.flags2.vision_damaged=false
	unit.flags2.vision_missing=false
	unit.flags2.breathing_good=true
	unit.flags2.breathing_problem=false

	unit.flags2.calculated_nerves=false
	unit.flags2.calculated_bodyparts=false
	unit.flags2.calculated_insulation=false
	unit.flags3.compute_health=true

	--print("Resetting counters...")
	unit.counters.winded=0
	unit.counters.stunned=0
	unit.counters.unconscious=0
	unit.counters.webbed=0
	unit.counters.pain=0
	unit.counters.nausea=0
	unit.counters.dizziness=0

	unit.counters2.paralysis=0
	unit.counters2.fever=0
	unit.counters2.exhaustion=0
	unit.counters2.hunger_timer=0
	unit.counters2.thirst_timer=0
	unit.counters2.sleepiness_timer=0
	unit.counters2.vomit_timeout=0
	
	--print("Resetting body part status...")
	v=unit.body.components
	for i=0,#v.nonsolid_remaining - 1,1 do
		v.nonsolid_remaining[i] = 100	-- percent remaining of fluid layers (Urist Da Vinci)
	end

	v=unit.body.components
	for i=0,#v.layer_wound_area - 1,1 do
		v.layer_status[i].whole = 0		-- severed, leaking layers (Urist Da Vinci)
		v.layer_wound_area[i] = 0		-- wound contact areas (Urist Da Vinci)
		v.layer_cut_fraction[i] = 0		-- 100*surface percentage of cuts/fractures on the body part layer (Urist Da Vinci)
		v.layer_dent_fraction[i] = 0		-- 100*surface percentage of dents on the body part layer (Urist Da Vinci)
		v.layer_effect_fraction[i] = 0		-- 100*surface percentage of "effects" on the body part layer (Urist Da Vinci)
	end
	
	v=unit.body.components.body_part_status
	for i=0,#v-1,1 do
		v[i].on_fire = false
		v[i].missing = false
		v[i].organ_loss = false
		v[i].organ_damage = false
		v[i].muscle_loss = false
		v[i].muscle_damage = false
		v[i].bone_loss = false
		v[i].bone_damage = false
		v[i].skin_damage = false
		v[i].motor_nerve_severed = false
		v[i].sensory_nerve_severed = false
	end
	
	if unit.job.current_job and unit.job.current_job.job_type == df.job_type.Rest then
		--print("Wake from rest -> clean self...")
		unit.job.current_job = df.job_type.CleanSelf
	end
end

function phylactery_update(workshop)
	if not workshop:isUnpowered() then
		local item=nearest_corpse_owner(workshop)
		local owner=get_owner(workshop)
		if owner and owner.flags1.dead and item.dist<25 then
			print("Resurrecting...")
			local x,y,z=dfhack.items.getPosition(item.it)
			remove_corpse_parts(find_corpse_parts(owner))
			full_heal(owner,true)
			owner.corpse_parts:resize(0)
			owner.pos={x=x,y=y,z=z}
		end
	end
end
eventful.registerSidebar("MECHAMAGIC_PHYLACTERY",phylactery_sidebar)
function make_frames( gears )
	local ret={}
	local frame={42,15}
	for _,frame_pic in ipairs(frame) do
		local nframe={}
		for i,v in ipairs(gears) do
			table.insert(nframe,{x=v.x,y=v.y,frame_pic,7,0,0})
		end
		table.insert(ret,nframe)
	end
	return ret
end
builds.registerBuilding{
        name="MECHAMAGIC_PHYLACTERY",
        fix_impassible=true,
        consume=25, --TODO UP THIS VERY MUCH!
        gears=phylactery_gears,
        action={50,phylactery_update},
        animate={
            isMechanical=true,
            frames=make_frames(phylactery_gears)
        }
        }
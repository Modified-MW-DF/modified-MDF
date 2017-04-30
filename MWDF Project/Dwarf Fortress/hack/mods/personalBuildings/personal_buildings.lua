
--NFH -> not finished here
local eventful=require 'plugins.eventful'
local guidm   =require 'gui.dwarfmode'
local widgets =require 'gui.widgets'
local bhacks  =require 'plugins.building-hacks'
local utils   =require 'utils'

local debug   =dfhack.internal.debug

function find_building_type(token)
    local _,ret=utils.linear_index(df.global.world.raws.buildings.workshops,token,"code")
    if not ret then
        error("Invalid instalation, "..token.." not found!")
    end
    return ret
end
function find_reaction( wshop,name)
    local _,ret=utils.linear_index(wshop.jobs,name,"reaction_name")
    return ret
end
function is_job_working(job)
    if job ==nil then
        return false
    end
    local u=dfhack.job.getWorker(job)
    if job and u and job.flags.working and
        u.pos.x==job.pos.x and u.pos.y==job.pos.y and u.pos.z==job.pos.z then
        return true, u
    end
    return false
end
--[====[Hobby buildings]====]
local hobby_tables={
    {"HOBBY_WORKSHOP","Personal worktable","LUA_HOOK_HOBBY_WORKTABLE",function ()print("Hobby work!") end}
}

sidebars=sidebars or {}
function make_job( reaction_name,unit,building )
    local newJob=df.job:new()
    newJob:assign{
        job_type=df.job_type.CustomReaction,
        reaction_name=reaction_name,
        general_refs={
            {new=df.general_ref_building_holderst,building_id=building.id},
            {new=df.general_ref_unit_workerst,unit_id=unit.id}
        },
        pos={x=building.centerx,y=building.centery,z=building.z},
        completion_timer=-1,
    }
    dfhack.job.linkIntoWorld(newJob,true)
    unit.path.dest:assign{x=newJob.pos.x,y=newJob.pos.y,z=newJob.pos.z}
    unit.job.current_job=newJob
    building.jobs:insert("#",newJob)
    return newJob
end
function lookup_owner(wshop)
    if #wshop.parents>0 and wshop.parents[0].owner~=nil then
        return wshop.parents[0].owner
    end
end
function personal_job(reaction_name,chance)
    local callback=function(wshop)
        if not debug then
            if math.random()<chance/100 then
                return
            end
        end
        local owner=lookup_owner(wshop)
        if owner==nil then return end --this works only for owned buildings
        if owner.job.current_job~=nil then return end

        make_job(reaction_name,owner,wshop)
    end
    return callback
end

function register_hobby_workshop(wshop)
    sidebars[wshop[1]]=defclass(sidebars[wshop[1]],guidm.WorkshopOverlay)
    local class=sidebars[wshop[1]]
    function class:init(args)
        local owner=lookup_owner(self.workshop)

        local owner_text = {}
        if owner then
            owner_text.text=dfhack.TranslateName(owner.name)
        else
            owner_text.text="<no owner, disabled>"
            owner_text.pen={fg=COLOR_LIGHTRED}
        end

        self:addviews{
        widgets.Panel{
            subviews = {
                widgets.Label{ text=wshop[2], frame={t=1,l=1} },
                widgets.Label{ text={{text="Owner:"},owner_text}, frame={t=3,l=1} },
                widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
                widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
            }
        }
        }
    end
    eventful.registerSidebar(wshop[1],class)
    bhacks.registerBuilding{name=wshop[1],action={500,personal_job(wshop[3],65)},canBeRoomSubset=1}
    if wshop[4] then
        eventful.registerReaction(wshop[3],wshop[4])
    end
end

function register_all()
    for i,v in ipairs(hobby_tables) do
        register_hobby_workshop(v)
    end
end
register_all()
--[====[Group buildings]====]
--[==[ Classroom ]==]
--[[ Pulpit ]]


local PULPIT_REACTION="LUA_HOOK_COMUNAL_READ_LECTURE"
local PULPIT_TOKEN="COMUNAL_PULPIT"
local PULPIT_TYPE=find_building_type(PULPIT_TOKEN)

local SEAT_REACTION="LUA_HOOK_COMUNAL_LISTEN"
local SEAT_TOKEN="COMUNAL_SEAT"
local SEAT_TYPE = find_building_type(SEAT_TOKEN)

function get_pulpit_job( wshop )
    for i,v in ipairs(building.jobs) do
        if v.reaction_name==react_name then
            return v
        end
    end
end
--give exp some in some skill.
-- either big lump at the end
-- or small parts during the lecture

function enum_listeners(wshop)
    local ret={}
    local p=wshop.parents
    if #p==0 then return ret end
    local parent=wshop.parents[0]
    for i,v in ipairs(parent.children) do
        if v:getCustomType()==SEAT_TYPE.id then
            local r=find_reaction(v,SEAT_REACTION)
            local _,u=is_job_working(r)
            if u then
                table.insert(ret,u)
            end
        end
    end
    return ret
end
pulpit_sidebar=defclass(pulpit_sidebar,guidm.WorkshopOverlay)
function get_taught_skill( job,unit )
    --local val=(math.cos(job.id*77.5)+1)*784+(math.sin(unit.id*7941.0045)+1)*1234 --EPIC RAND NUMBER GENERATOR (patent pending)
    --sort skills unit can teach
    local skills=unit.status.current_soul.skills
    local skill_ratings={}
    for i,v in ipairs(skills) do
        table.insert(skill_ratings,{v.id,v.rating})
    end
    table.sort(skill_ratings,function (v1,v2)return v1[2]>v2[2] end)
    
    return skill_ratings[1][1]
    --skip blacklisted (e.g. military? physical?) skills TODO: note- use skill class maybe?
    --pick random from top (X)? skills
    --maybe factor in the units teaching skill?
end
function pulpit_sidebar:init(args)
    local owner=lookup_owner(self.workshop)

    local owner_text = {}
    if owner then
        owner_text.text=dfhack.TranslateName(owner.name)
    else
        owner_text.text="<no owner, disabled>"
        owner_text.pen={fg=COLOR_LIGHTRED}
    end
    local num_listeners=#enum_listeners(self.workshop)
    self:addviews{
    widgets.Panel{
        subviews = {
            widgets.Label{ text="Pulpit", frame={t=1,l=1} },
            widgets.Label{ text={{text="Owner:"},owner_text}, frame={t=3,l=1} },
            widgets.Label{ text={{text="Status:"},{text=self:callback("status_text")}}, frame={t=4,l=1} },
            widgets.Label{ text="Listeners:"..tostring(num_listeners), frame={t=5,l=1} },
            widgets.Label{ text={{key='CUSTOM_R',key_sep=": ",text="Start lecture",enabled=(owner~=nil),on_activate=self:callback("add_lecture")}}, frame={b=3,l=1} },
            widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
            widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
        }
    }
    }
end
function pulpit_sidebar:status_text()
    local r=find_reaction(self.workshop,PULPIT_REACTION)
    local _,u=is_job_working(r)
    if u then
        return "Teaching:"..get_taught_skill(r,u)
    else
        return "Idle"
    end
end
--- add or resume lecture
function pulpit_sidebar:add_lecture()
    local building=self.workshop
    local react_name=PULPIT_REACTION
    if #building.jobs>0 then --either it has old job or destroy job
        local job=get_pulpit_job(building)
        if job then job.flags.suspended=false end
    else
        local job=make_job(react_name,lookup_owner(building),building)
        job.completion_timer=250 --TODO maybe customizable value?
    end
end

eventful.registerSidebar(PULPIT_TOKEN,pulpit_sidebar)
bhacks.registerBuilding{name=PULPIT_TOKEN,canBeRoomSubset=1}

function get_building_from_unit(u)
    local job=u.job.current_job
    if not job then return end
    return dfhack.job.getHolder(job)
end
function cancel_job(job)
    --unlink
    local link=job.list_link
    link.prev.next=link.next
    link:delete()
    --remove from unit
    local u=dhfack.job.get
    if u then
        u.job.current_job=nil
    end
    --remove from building
    local bld=dfhack.job.getHolder(job)
    if bld then
        for i,v in ipairs(bld.jobs) do
            if v==job then
                bld.jobs:erase(i)
                break
            end
        end
    end
    --TODO remove items from job

    --finally KILL THE JOB!!!!
    job:delete()
end
function add_xp(unit,skill_id,xp)
    --get skill entry
    local skills=unit.status.current_soul.skills
    local s_entry=utils.binsearch(skills,skill_id,'id')

    --does not exist so create skill entry
    if not s_entry then
        s_entry=df.unit_skill:new()
        s_entry.id = skill_id
        utils.insert_sorted(skills,s_entry,'id')
    end
    --add xp
    s_entry.experience=s_entry.experience+xpP
    --check if it levels up
    repeat
        local thresh=df.skill_rating.attrs[s_entry.rating].xp_threshold
        if thresh>s_entry.experience then
            s_entry.rating=s_entry.rating+1
            s_entry.experience=s_entry.experience-thresh
        else
            break
        end
    until false
end
function get_skill_rating( unit,skill_id )
    local skills=unit.status.current_soul.skills
    local s_entry=utils.binsearch(skills,skill_id,'id')
    if not s_entry then
        return 0
    else
        return s_entry.rating
    end
end
function pulpit_finish_reading(reaction,reaction_product,unit,input_items,input_reagents,output_items,call_native)
    call_native.value=false
    --enum all listeners
    local listeners=enum_listeners(get_building_from_unit(unit))
    --cancel their jobs
    for i,v in ipairs(listeners) do
        cancel_job(v.job.current_job)
    end
    --give out xp
    local skill_id=get_taught_skill(unit.job.current_job,unit)
    local skill_rating=get_skill_rating(unit,skill_id)
    for i,v in ipairs(listeners) do
        -- check if not lower skill teacher
        -- give xp based on teaching skill
        if get_skill_rating(v,skill_id)<skill_rating then
            add_xp(v,skill_id,25) --TODO xp based on teaching etc...
        end
    end
    
end
eventful.registerReaction("LUA_HOOK_COMUNAL_READ_LECTURE",pulpit_finish_reading)
--[[ Chairs ]]

chair_sidebar=defclass(chair_sidebar,guidm.WorkshopOverlay)
function find_pulpit(wshop)
    local p=wshop.parents
    if #p==0 then return end
    local parent=wshop.parents[0]
    for i,v in ipairs(parent.children) do
        
        if v:getCustomType()==PULPIT_TYPE.id then
            return v
        end
    end
end
function chair_sidebar:init(args)
    self.pulpit=find_pulpit(self.workshop)
    self:addviews{
    widgets.Panel{
        subviews = {
            widgets.Label{ text="Lecture chair", frame={t=1,l=1} },
            widgets.Label{ text={{text="Status:"},{text=self:callback("status_text")}}, frame={t=4,l=1} },
            widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
            widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
        }
    }
    }
end
function chair_sidebar:status_text()
    if self.pulpit then
        return "Ok"
    else
        return "Not in room with pulpit"
    end
end
function enum_idle_dwarves(pos,distance)
    local dsq=distance*distance

    local dwarfs_near={}
    for k,v in pairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(v) and v.job.current_job==nil then
            local dx=pos.x-v.pos.x
            local dy=pos.y-v.pos.y
            local dz=pos.z-v.pos.z
            if dx*dx+dy*dy<dsq and dz==0 then --only on same level
                table.insert(dwarfs_near,v)
            end
        end
    end
    return dwarfs_near
end
function listen_job(wshop)

    if #wshop.jobs>0 then --already listening
        return
    end

    if not debug then
        if math.random()<0.6 then
            return
        end
    end
    local pulpit=find_pulpit(wshop)
    if pulpit==nil then return end --this works only for buildings in classroom with pulpit
    
    local dwarves=enum_idle_dwarves({x=wshop.centerx,y=wshop.centery,z=wshop.z},25)
    if #dwarves==0 then return end
    local target=dwarves[math.random(1,#dwarves)]
    local job=make_job(SEAT_REACTION,target,wshop)
    job.completion_timer=100
end
eventful.registerSidebar(SEAT_TOKEN,chair_sidebar)
bhacks.registerBuilding{name=SEAT_TOKEN,canBeRoomSubset=1,action={500,listen_job}}

-- a group job:
--[[
    synced -> as master starts, he waits till MIN_MEMBERS are available and then they all start and finish their jobs
           -> non-synced, anybody can join/quit anytime
    MIN_MEMBERS -> minimal count of members for it to be sucessful (if non-synced it still works but fails, on synced it just don't start)
    no_wait -> instantly start job
    needs_owner -> buildings parent needs owner (e.g. only priest can do sermons)

    group job variants:
        X people needed to make it work (e.g. magic?)
        one person (leader) makes other able to work (e.g. priest and sermons)
        each person (other then leader) makes job quicker (e.g. helping in smeltery)
        virtual leader makes other able to work (e.g. parties) --> see if it's possible to add a job to parent + random location in room!
    Random ideas:


]]



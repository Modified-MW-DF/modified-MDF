local eventful=require "plugins.eventful"
local ev=require("plugins.eventful")

local gui = require 'gui'
local guidm = require 'gui.dwarfmode'
local widgets =require 'gui.widgets'

CHAIR_TOKEN="DWARVEN_GAMES_CHAIR"
local _,chair_def=require('utils').linear_index(df.global.world.raws.buildings.workshops,CHAIR_TOKEN,"code")
CHAIR_ID=chair_def.id
--[[==========================================================]]
building_view=defclass(building_view, guidm.MenuOverlay)
building_view.ATTRS={
    wshop=DEFAULT_NIL,
    frame_background=dfhack.pen.parse{ch=32,fg=0,bg=0},
    focus_path="eventful/building_view" -- must start with eventful/ to function correctly
}
function building_view:onInput(keys)
    local allowedKeys={
        "CURSOR_RIGHT","CURSOR_LEFT","CURSOR_UP","CURSOR_DOWN",
        "CURSOR_UPRIGHT","CURSOR_UPLEFT","CURSOR_DOWNRIGHT","CURSOR_DOWNLEFT","CURSOR_UP_Z","CURSOR_DOWN_Z","DESTROYBUILDING"}
    if keys.LEAVESCREEN then
        self:dismiss()
        self:sendInputToParent('LEAVESCREEN')
    else
        for _,name in ipairs(allowedKeys) do
            if keys[name] then
                self:sendInputToParent(name)
                break
            end
        end
        self:inputToSubviews(keys)
    end
    if df.global.world.selected_building ~= self.wshop then
        self:dismiss()
        return
    end
end
--[[==========================================================]]
function sidebar(class_object )
    return function(wshop)
        if wshop:getMaxBuildStage()~=wshop:getBuildStage() then
            return
        end

        local valid_focus="dwarfmode/QueryBuilding/Some"
        local focus=dfhack.gui.getCurFocus()
        local ev_focus="dfhack/lua/eventful/"

        if string.sub(focus,1,#valid_focus)==valid_focus then
            local sidebar=class_object{wshop=wshop}
            sidebar:show()
        elseif string.sub(focus,1,#ev_focus)==ev_focus then
            local sidebar=class_object{wshop=wshop}
            sidebar:show(dfhack.gui.getCurViewscreen().parent)
        end
    end
end
--[[==========================================================]]
chair_view = defclass(chair_view, building_view)
function chair_view:init(args)
    self.player=getChairsPlayer(self.wshop)
    self:addviews{
    widgets.Panel{
        subviews = {
            widgets.Label{ text="Game chair", frame={t=1,l=1} },
            widgets.Label{ text={{text=self:callback("state"),pen={fg=3}}},frame={t=3,l=1}},
            widgets.Label{ text={{text=self:callback("getPlayer"),pen={fg=4}}},frame={t=4,l=1}},
            widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
            widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
        }
    }
    }
end
function chair_view:state()
    if self.player~=nil then
        return "Occupied"
    else
        return "Free"
    end
end
function chair_view:getPlayer()
    if self.player~=nil then
        return dfhack.TranslateName(self.player.name)
    else
        return ""
    end
end
--[[==========================================================]]
table_view = defclass(table_view, building_view)
function table_view:init(args)
    self.chairs=enumChairs(self.wshop)
    self.players={}
    self.game="Rock Pick Gauntlet"
    for _,p in ipairs(self.chairs) do
        local player=getChairsPlayer(p)
        if player then
            table.insert(self.players,player)
        end
    end
    self:addviews{
    widgets.Panel{
        subviews = {
            widgets.Label{ text="Game table", frame={t=1,l=1} },
            widgets.Label{ text="Players:"..#self.players, frame={t=3,l=1} },
            widgets.Label{ text="Game:"..self.game, frame={t=4,l=1} },
            widgets.Label{ text={{key='CUSTOM_J',key_sep=": ",text="Join game",enabled=false}}, frame={b=3,l=1} },
            widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
            widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
        }
    }
    }
end
------------------------------------------------------------------
function enumChairs(bld_table)
    local rect={x1=bld_table.x1-1,y1=bld_table.y1-1,z=bld_table.z,
                x2=bld_table.x2+1,y2=bld_table.y2+1}
    local ret={}
    for _,bld in pairs(df.global.world.buildings.other.WORKSHOP_CUSTOM) do
        if bld.custom_type==CHAIR_ID and bld.z==rect.z  and
            bld.x1>=rect.x1 and bld.x1<=rect.x2 and bld.y1>=rect.y1 and bld.y1<=rect.y2 then
            table.insert(ret,bld)
        end
    end
    return ret
end
function getChairsPlayer(bld_chair)
    if #bld_chair.jobs>0 then
        return dfhack.job.getWorker(bld_chair.jobs[0])
    end
end

function getLastJobLink()
    local st=df.global.world.job_list
    while st.next~=nil do
        st=st.next
    end
    return st
end
function addNewJob(job)
    local lastLink=getLastJobLink()
    local newLink=df.job_list_link:new()
    newLink.prev=lastLink
    lastLink.next=newLink
    newLink.item=job
    job.list_link=newLink
end
function UnassignJob(job,unit,unit_pos)
    unit.job.current_job=nil
end
function makeJob(args)
    local newJob=df.job:new()
    newJob.id=df.global.job_next_id
    df.global.job_next_id=df.global.job_next_id+1
    --newJob.flags.special=true
    newJob.job_type=args.job_type
    newJob.completion_timer=-1

    newJob.pos:assign(args.pos)
    args.job=newJob
    local failed
    for k,v in ipairs(args.pre_actions or {}) do
        local ok,msg=v(args)
        if not ok then
            failed=msg
            break
        end
    end
    if failed==nil then
        AssignUnitToJob(newJob,args.unit,args.from_pos)
        for k,v in ipairs(args.post_actions or {}) do
            local ok,msg=v(args)
            if not ok then
                failed=msg
                break
            end
        end
        if failed then
            UnassignJob(newJob,args.unit)
        end
    end
    if failed==nil then
        addNewJob(newJob)
        return newJob
    else
        newJob:delete()
        return false,failed
    end
    
end
function AssignUnitToJob(job,unit,unit_pos)
    job.general_refs:insert("#",{new=df.general_ref_unit_workerst,unit_id=unit.id})
    unit.job.current_job=job
    unit_pos=unit_pos or {x=job.pos.x,y=job.pos.y,z=job.pos.z}
    unit.path.dest:assign(unit_pos)
    return true
end
function AssignBuildingRef(bld)
    return function(args)
        args.job.general_refs:insert("#",{new=df.general_ref_building_holderst,building_id=bld.id})
        bld.jobs:insert("#",args.job)
    end
end

function makeWaitJob(building,unit)
    local args={}
    args.pos={x=building.centerx,y=building.centery,z=building.z}
    args.job_type=df.job_type.CustomReaction
    args.pre_actions={
        function(args) 
            args.job.reaction_name="LUA_HOOK_WAIT_FOR_PLAYERS"
            args.job.completion_timer=math.random(25,100) --todo think of normal value
            --todo set on break flag
        end
    }
    args.post_actions={AssignBuildingRef(building)}
    args.unit=unit
    local ok,msg=makeJob(args)
    if not ok then
        qerror(msg)
    end
end
function addWaitJob(wshop)
    --[[if math.random()<0.65 then
        return
    end]]
    if #wshop.jobs>0 then --already playing/waiting
        return
    end
    local DISTANCE=25
    local dsq=DISTANCE*DISTANCE
    print("Trying to add job:"..tostring(wshop))
    local dwarfs_near={}
    for k,v in pairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(v) and v.job.current_job==nil then
            local dx=wshop.centerx-v.pos.x
            local dy=wshop.centery-v.pos.y
            local dz=wshop.z-v.pos.z
            if dx*dx+dy*dy<dsq and dz==0 then --only on same level
                table.insert(dwarfs_near,v)
            end
        end
    end
    if #dwarfs_near>0 then
        print(string.format("found %d dwarfs nearby",#dwarfs_near))
        makeWaitJob(wshop,dwarfs_near[math.random(1,#dwarfs_near-1)])
    end
end
function waitDone( reaction,reaction_product,unit )
    --check players
    --local players=getPlayers(unit.job.current_job) todo write this
    --start playing

end
eventful.registerReaction("LUA_HOOK_WAIT_FOR_PLAYERS",waitDone)

require("plugins.building-hacks").registerBuilding{name=CHAIR_TOKEN,action={500,addWaitJob}}
ev.registerSidebar(CHAIR_TOKEN,sidebar(chair_view))

ev.registerSidebar("DWARVEN_GAMES_TABLE",sidebar(table_view))
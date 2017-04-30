local builds=require 'plugins.building-hacks'
local eventful= require 'plugins.eventful'


function make_frames( gears ) -- a helper to make animation for gears
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

local dragon_engine_dirs={
    S={spew={x=0,y=5,dx=0,dy=1,mx=0,my=3}}, --spew place, direction, magma place
    N={spew={x=0,y=-1,dx=0,dy=-1,mx=0,my=1}},
    W={spew={x=-1,y=0,dx=-1,dy=0,mx=1,my=0}},
    E={spew={x=5,y=0,dx=1,dy=0,mx=3,my=0}},
    }
function getMagma(pos)
    local flags=dfhack.maps.getTileFlags(pos)
    return flags.liquid_type, flags.flow_size
end
function removeLiquid(pos)
    local flags=dfhack.maps.getTileFlags(pos)
    flags.flow_size=0
    dfhack.maps.enableBlockUpdates(dfhack.maps.getBlock(pos.x/16,pos.y/16,pos.z),true)
end
function makeSpewFire(spew)
    return function(wshop)
        if not wshop:isUnpowered() then
            if math.random() >0.7 then --30% chance not to fire, for a bit of random look
                return
            end
            local pos={x=wshop.x1,y=wshop.y1,z=wshop.z}
            local mPos={x=pos.x+spew.mx,y=pos.y+spew.my,z=pos.z}
            local sPos={x=pos.x+spew.x,y=pos.y+spew.y,z=pos.z}
            --check for magma
            local isMagma,amount=getMagma(mPos)
            if amount>0 then
                local flowType
                if isMagma then
                    flowType=df.flow_type.Dragonfire
                    local flow=dfhack.maps.spawnFlow(sPos,flowType,6,-1,120*amount/7)
                    flow.dest={x=sPos.x+spew.dx*5,y=sPos.y+spew.dy*5,z=sPos.z}
                    
                else
                    
                    for i=0,math.ceil(amount/1.3) do
                        dfhack.maps.spawnFlow({x=sPos.x+spew.dx*i,y=sPos.y+spew.dy*i,z=sPos.z},df.flow_type.Mist,6,-1,120*(amount-i)/7)
                    end
                    
                end
                --consume the liquid
                removeLiquid(mPos)
            end
        end
    end
end
function registerDragonEngine(dir,data)
    builds.registerBuilding{
        name="DRAGON_ENGINE_"..dir,
        fix_impassible=true,
        consume=25,
        action={50,makeSpewFire(data.spew)}
        }
    print("Registered mechanical workshop:".."DRAGON_ENGINE_"..dir)
end
for k,v in pairs(dragon_engine_dirs) do
    registerDragonEngine(k,v)
end
function getBuildingFromJob(job)
    for k,v in ipairs(job.general_refs) do
        if v:getType()==df.general_ref_type.BUILDING_HOLDER then
            return df.building.find(v.building_id)
        end
    end
end

function load_webs(reaction,reaction_product,unit,input_items,input_reagents,output_items,call_native)
    local building=getBuildingFromJob(unit.job.current_job)
    dfhack.items.moveToBuilding(input_items[0],building,0)
    call_native.value=false
    --cancel repeat if full, cancel the job too?
end
function makeSpewWeb(spew)
    return function(wshop)
        if not wshop:isUnpowered() then
            if math.random() >0.7 then --30% chance not to fire, for a bit of random look
                return
            end
            local pos={x=wshop.x1,y=wshop.y1,z=wshop.z}
            local sPos={x=pos.x+spew.x,y=pos.y+spew.y,z=pos.z}
            --check for loaded webs
            local amount=1--getLoadedWebs(wshop)
            if amount>0 then
                local flow=dfhack.maps.spawnFlow(sPos,df.flow_type.Web,6,-1,300)
                flow.dest={x=sPos.x+spew.dx*25,y=sPos.y+spew.dy*25,z=sPos.z}
                --removeWeb(wshop)
            end
        end
    end
end
local webber_dirs={
    S={gear={x=0,y=0},spew={x=0,y=3,dx=0,dy=1}}, --spew place, direction
    N={gear={x=0,y=2},spew={x=0,y=-1,dx=0,dy=-1}},
    W={gear={x=2,y=0},spew={x=-1,y=0,dx=-1,dy=0}},
    E={gear={x=0,y=0},spew={x=3,y=0,dx=1,dy=0}},
    }
function registerWebber(dir,data)
    builds.registerBuilding{
        name="WEBBER_"..dir,
        fix_impassible=true,
        consume=25,
        gears={data.gear},
        action={50,makeSpewWeb(data.spew)},
        animate={
            isMechanical=true,
            frames={
            {{x=data.gear.x,y=data.gear.y,42,7,0,0}}, --first frame, 1 changed tile
            {{x=data.gear.x,y=data.gear.y,15,7,0,0}} -- second frame, same
            }
        }
        }
    print("Registered mechanical workshop:".."WEBBER_"..dir)
end
for k,v in pairs(webber_dirs) do
    registerWebber(k,v)
end
--TODO sidebar iterpose that removes job if it's full
eventful.registerReaction("LUA_HOOK_ADD_WEBS_TO_SHOOTER",load_webs)

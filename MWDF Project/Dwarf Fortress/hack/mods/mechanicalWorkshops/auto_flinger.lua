local builds=require 'plugins.building-hacks'
local eventful= require 'plugins.eventful'
local guidm   =require 'gui.dwarfmode'
local widgets =require 'gui.widgets'
local utils=require 'utils'
--[==[
    TODO list:
        add z level each 5/10 power
        get items on/in this building too
        tweak numbers?
        add power requirement per item flinged (or trying to fling)
            thus making players produce more power or have chance of
            machines siezing up
        maybe add variation in fling power to discorouge long fling distance
        add (small?) chance that items will hit units
            could work as improvised trap/weapon
]==]
local function enum_items_in_region(min_x,min_y,max_x,max_y,z)
    local blocks={}

    for x=min_x,max_x do
    for y=min_y,max_y do
        local block=dfhack.maps.getTileBlock(x,y,z)
        if block then 
            blocks[block]=true
        end
    end
    end
    
    local item_ids={}
    for k,v in pairs(blocks) do
        for i,v in ipairs(k.items) do
            table.insert(item_ids,v)
        end
    end
    local ret={}
    for i,v in ipairs(item_ids) do
        local item=df.item.find(v)
        if item.pos.z==z and
            item.pos.x>=min_x and
            item.pos.x<=max_x and
            item.pos.y>=min_y and
            item.pos.y<=max_y then
            ret[v]=item
        end
    end
    return ret
end
local function get_create_general_ref(building)
    for k,ref in pairs(building.general_refs) do
        if ref:getType()==df.general_ref_type.LOCATION then
            return ref
        end
    end
    local ref=df.general_ref_locationst:new()
    ref.anon_1=0
    ref.anon_2=2
    building.general_refs:insert('#',ref)
    return ref
end
local function get_dir_pow(building)
    local ref=get_create_general_ref(building)
    return ref.anon_1,ref.anon_2
end
local function set_dir_pow(building,dir,pow)
    local ref=get_create_general_ref(building)
    ref.anon_1=dir
    ref.anon_2=pow
end
local function get_close_workshops(workshop)
    local ret={}
    local dirs={{x=0,y=-1,z=0},{x=1,y=0,z=0},{x=0,y=1,z=0},{x=-1,y=0,z=0}}
    for _,side in ipairs(dirs) do
        local pos={x=workshop.centerx+side.x*2,y=workshop.centery+side.y*2,z=workshop.z}
        local bld=dfhack.buildings.findAtTile(pos)
        if bld then
            table.insert(ret,bld)
        end
    end
    return ret
end
local function remove_ref( item )
    for i,v in ipairs(item.general_refs) do
        if v:getType()==df.general_ref_type.BUILDING_HOLDER then
            v:delete()
            item.general_refs:erase(i)
            return true
        end
    end
    return false
end
local function get_items( bld,tbl )
    for i=#bld.contained_items-1,0,-1 do
        local it=bld.contained_items[i]
        if it.use_mode==0 and not it.item.flags.in_job then
            local item=it.item
            table.insert(tbl,item)

            it:delete()
            bld.contained_items:erase(i)
            remove_ref(item)
            item.flags.removed=true
            --dfhack.items.remove(it.item,true)
            if not dfhack.items.moveToGround(item,{x=bld.centerx,y=bld.centery,z=bld.z}) then
                print("failed to move item")
            end
        end
    end
end
local function make_projectile( item,direction,power )
    local dirs={{x=0,y=-1,z=0},{x=1,y=0,z=0},{x=0,y=1,z=0},{x=-1,y=0,z=0}}
    local proj=dfhack.items.makeProjectile(item)
    if not proj then
        --TODO: put on ground?
        qerror("Failed to throw item:"..tostring(item))
        return
    end
    local dir=dirs[direction+1]
    proj.flags.no_impact_destroy=true
    proj.target_pos.x=proj.origin_pos.x+dir.x*power
    proj.target_pos.y=proj.origin_pos.y+dir.y*power
    proj.target_pos.z=proj.origin_pos.z+dir.z*power
    --parabolic?
    --high_flying?
    proj.min_ground_distance=power
    proj.min_hit_distance=power/3
    proj.fall_threshold=power
end
function flinger_update(wshop)
    if not wshop:isUnpowered() then
        local dir,power=get_dir_pow(wshop)
        --enum close shops
        local wshops=get_close_workshops(wshop)
        --get items
        local items={}
        for i,v in ipairs(wshops) do
            get_items(v,items)
        end
        local my_items=enum_items_in_region(wshop.x1,wshop.y1,wshop.x2,wshop.y2,wshop.z)
        --merge them in
        for k,v in pairs(my_items) do
            table.insert(items,v)
        end
        --fling items
        for i,v in ipairs(items) do
            v.pos={x=wshop.centerx,y=wshop.centery,z=wshop.z}
            make_projectile(v,dir,power)
        end
    end
end
local flinger_gears={{x=1,y=0},{x=0,y=1},{x=2,y=1},{x=1,y=2}}
builds.registerBuilding{
        name="AUTO_FLINGER",
        fix_impassible=true,
        consume=15,
        gears=flinger_gears,
        action={50,flinger_update},
        animate={
            isMechanical=true,
            frames=make_frames(flinger_gears)
        }
        }

flinger_sidebar=defclass(flinger_sidebar,guidm.WorkshopOverlay)
function get_machine( bld )
    if bld.machine and bld.machine.machine_id>=0 then
        return df.machine.find(bld.machine.machine_id)
    end
end
function make_power_widgets(target,top) --makes a nice "like vanila" machine information
    local m=get_machine(target)
    if m then
        local min=m.min_power
        local cur=m.cur_power
        local active_text="Innactive"
        local active_pen=dfhack.pen.parse{fg=COLOR_LIGHTRED,bg=0}
        if m.flags.active then
            active_text="Active"
            active_pen=dfhack.pen.parse{fg=COLOR_LIGHTGREEN,bg=0}
        end
        local function make_power_string()
            local make,use=builds.getPower(target)
            local power_string

            if make==nil then
                power_string="A" --TODO: not make any widget at all?
            elseif make>0 and use>0 then
                power_string=string.format("This Building Makes/Uses: %d/%d",make,use)
            elseif make>0 and use==0 then
                power_string=string.format("This Building Makes: %d",make)
            elseif make==0 and use>0 then
                power_string=string.format("This Building Uses: %d",use)
            end
            return power_string
        end
        

        return {
            widgets.Label{ text=active_text,text_pen=active_pen,frame={t=top,l=1} },
            widgets.Label{ text="Total Power: "..tostring(cur), frame={t=top+1,l=1} },
            widgets.Label{ text="Total Power Needed: "..tostring(min), frame={t=top+2,l=1} },
            widgets.Label{ text={{text=make_power_string}}, frame={t=top+3,l=1} },
        }
    else
        return {widgets.Label{ text="Not connected to machines",
            text_pen=dfhack.pen.parse{fg=COLOR_LIGHTRED,bg=0}, frame={t=top,l=1} }}
    end
end
function flinger_sidebar:init(args)
    self:update_text()
    self:addviews{
    widgets.Panel{
        subviews = {
            widgets.Label{ text="Auto flinger", frame={t=1,l=1} },
            widgets.Label{ text={{text="Direction:"},{text=self:cb_getfield("dir_text")},
                {key="CUSTOM_D",key_sep="()",on_activate=self:callback("change_dir")}
                }, frame={t=3,l=1} },
            widgets.Label{ text={{text="Distance:"},{text=self:cb_getfield("power_text")},
                {text="+",key="CUSTOM_T",key_sep="()",on_activate=self:callback("add_pow")},
                {text="-",key="CUSTOM_R",key_sep="()",on_activate=self:callback("remove_pow")}
                }, frame={t=4,l=1} },
            widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
            widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
        }
    }
    }
    self:addviews(make_power_widgets(self.workshop,6))
end
function flinger_sidebar:add_pow()
    local d,p=get_dir_pow(self.workshop)
    p=p+1
    if p>25 then
        p=25
    end
    builds.setPower(self.workshop,0,5+p*5)
    set_dir_pow(self.workshop,d,p)
    self:update_text()
end
function flinger_sidebar:remove_pow()
    local d,p=get_dir_pow(self.workshop)
    p=p-1
    if p<2 then
        p=2
    end
    builds.setPower(self.workshop,0,5+p*5)
    set_dir_pow(self.workshop,d,p)
    self:update_text()
end
function flinger_sidebar:update_text()
    local dirs={"N","E","S","W"}
    local d,pow=get_dir_pow(self.workshop)

    self.dir_text=dirs[d+1]
    self.power_text=tostring(pow)
end
function flinger_sidebar:change_dir()
    local d,p=get_dir_pow(self.workshop)
    d=d+1
    if d>=4 then d=0 end
    set_dir_pow(self.workshop,d,p)
    self:update_text()
end

eventful.registerSidebar("AUTO_FLINGER",flinger_sidebar)

function do_recipe(workshop,item,recipes)
    if type(recipes)=="function" then
        return recipes(workshop,item)
    end
    if type(recipes)=="table" then
        for i,v in ipairs(recipes) do
            if type(v)=="function" then
                local p=v(workshop,item)
                if p then
                    return p
                end
            else
                --TODO
            end
        end
    end
    return false
end
--[==[
    TODO:
        move to other file?
        Special effects: emit clouds of materials?
        Smasher might be too fast: dwarves take a lot longer to do the same. We should not have it TOO fast
--]==]
function make_auto_workshop(name,nice_name,recipes,consume_power)
    --TODO: get nice_name from raws
    consume_power=consume_power or 20
    local function wshop_update(wshop)
        if not wshop:isUnpowered() then
            local items={}

            local my_items=enum_items_in_region(wshop.x1,wshop.y1,wshop.x2,wshop.y2,wshop.z)
            --merge them in
            for k,v in pairs(my_items) do
                table.insert(items,v)
            end
            --process one item
            for i,v in ipairs(items) do
                if do_recipe(wshop,v,recipes) then
                    return
                end
            end
        end
    end
    builds.registerBuilding{
        name=name,
        fix_impassible=true,
        consume=consume_power,
        auto_gears=true,
        action={50,wshop_update},
        }
    --WARNING stupid code follows: i create new class for each workshop
    -- this could be avoided but i'm too lazy and who cares, right?

    local auto_workshop_gui=defclass(auto_workshop_gui,guidm.WorkshopOverlay)
    function auto_workshop_gui:init(args)
        self:addviews{
        widgets.Panel{
            subviews = {
                widgets.Label{ text=nice_name, frame={t=1,l=1} },
                
                widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
                widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
            }
        }
        }
        self:addviews(make_power_widgets(self.workshop,2))
    end
    eventful.registerSidebar(name,auto_workshop_gui)
end

function rock_smasher_recipe(wshop, item )
    local BLOCK_SIZE=600
    if item:getVolume()<= BLOCK_SIZE then --fits between teeth and just sits there. Also prevents machine from totally eating blocks
        return false
    end
    --TODO: figure out if material used for teeth COMPRESSIVE strenght is > items
    --if not damage the teeth randomly
    --in extreme case break the machine, explosively!
    if item:getActualMaterial()==-1 or item:getActualMaterialIndex()==-1 then --no invalid materials
        return false
    end
    local volume=item:getVolume()*(math.random()*0.1+0.2) --Vanilla blocks have 0.24 efficiency, this sometimes is better
    local count=math.floor(volume/BLOCK_SIZE)
    
    local function make_block()
        local block=df.item_blocksst:new()

        block.stack_size = 1
        block.mat_type = item:getActualMaterial()
        block.mat_index = item:getActualMaterialIndex()

        block.flags.removed=true

        block.id=df.global.item_next_id
        df.global.item_next_id=df.global.item_next_id+1
        block:categorize(true)
        df.global.world.items.all:insert("#",block)
        dfhack.items.moveToBuilding(block,wshop,0)
        block.flags.in_building=false --temp fix for a bug in moveToBuilding
    end
    for i=1,count do
        make_block()
    end
    dfhack.items.remove(item)    
    return true
end
make_auto_workshop("ITEM_SMASHER","Smasher",rock_smasher_recipe,30)-- any item with volume*(0.2 to 0.3) > block volume is crushed to blocks
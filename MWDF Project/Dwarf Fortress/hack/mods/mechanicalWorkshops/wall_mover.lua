
local builds=require 'plugins.building-hacks'
local eventful= require 'plugins.eventful'
local guidm   =require 'gui.dwarfmode'
local widgets =require 'gui.widgets'
local utils=require 'utils'


--[[=begin

move_wall
=========
experimenting with wall moving. Idea is to have building that moves touching wall

=end]]

--[[
    TODO:
        moving over tops of walls removes them and does not re-add
        crush units stuck between walls
        maybe move units if it's possible
        unstuck items stuck in walls and stuck new items in walls (encased flag)
        check if same_wall is actually a wall (or other supported type) -> related to flood fill idea and tops of walls todo
        liquids? Liquids!
        Move the script part to modtools. Others could benefit from this
    PERF:
        loop only once, tileset and tile gets in blocks etc...
    MISC:
        flood fill out of pos to find all connected parts and move them all at once 
            check if "front" has any blockers
            move them in reverse direction sorted way
]]

function set_tile_type(pos,tile_type )
    local block=dfhack.maps.getTileBlock(pos)
    block.tiletype[math.fmod(pos.x,16)][math.fmod(pos.y,16)]=tile_type
end

function same_wall( w1,w2 )
    return w1.item_type==w2.item_type and w1.item_subtype==w2.item_subtype and w1.mat_type==w2.mat_type and w1.mat_index==w2.mat_index
end
function find_connected_wall(pos,dir)
    local tt=dfhack.maps.getTileType(pos)
    local att=df.tiletype.attrs[tt]
    if att.material~=df.tiletype_material.CONSTRUCTION then
        return {}
    end
    local start=df.construction.find(pos)
    if not start then return {} end

    for i=1,16 do --TODO: hardcoded limit of tiles...
        local t_pos={x=pos.x-dir.x*i,y=pos.y-dir.y*i,z=pos.z-dir.z*i} --reverse search for first tile
        local new_start=df.construction.find(t_pos)
        if new_start and same_wall(start,new_start) and (not new_start.flags.top_of_wall) then 
            start=new_start 
        else
            break
        end
    end
    pos=start.pos
    local wall_tiles={start}
    for i=1,16 do --forward search
        local t_pos={x=pos.x+dir.x*i,y=pos.y+dir.y*i,z=pos.z+dir.z*i}
        local new_wall=df.construction.find(t_pos)
        if new_wall and same_wall(start,new_wall) and (not new_wall.flags.top_of_wall) then 
            table.insert(wall_tiles,new_wall)
        else
            break
        end
    end
    return wall_tiles
end
function valid_target(target_pos )
    local target_tile=dfhack.maps.getTileType(target_pos)
    local att=df.tiletype.attrs[target_tile]
    local valid_choices={ 
        [df.tiletype_shape.NONE]=true,
        [df.tiletype_shape.EMPTY]=true,
        [df.tiletype_shape.FLOOR]=true,
        [df.tiletype_shape.PEBBLES]=true,
        [df.tiletype_shape.RAMP_TOP]=true,
        }
        --print(df.tiletype_shape[att.shape])
    return valid_choices[att.shape]
end


function pos_compare(p1,other)
    if (p1.x ~= other.x) then return (p1.x - other.x) end
    if (p1.y ~= other.y) then return (p1.y - other.y) end
    return p1.z - other.z;
end

function top_of_wall_fixup(from,to_pos,c)
    local from_tt=dfhack.maps.getTileType(from)
    if df.tiletype.attrs[from_tt].shape~=df.tiletype_shape.WALL then --only fixup for walls
        return
    end
    local from_top=copyall(from)
    from_top.z=from_top.z+1

    local to_top=copyall(to_pos)
    to_top.z=to_top.z+1

    local top_constr=df.construction.find(from_top)

    if top_constr and top_constr.flags.top_of_wall then --had top
        if valid_target(to_top) then  --and can move it
            move_construction(top_constr,to_top)
        else
            remove_construction(top_constr) --remove it
        end
    else
        if valid_target(to_top) then --did not have it, but new tile has space for it
            add_construction({new=true,pos=to_top,
                item_type=c.item_type,item_subtype=c.item_subtype,
                mat_type=c.mat_type,mat_index=c.mat_index,
                flags={top_of_wall=true}
                },df.tiletype.ConstructedFloor)
        end
    end
end
function add_construction(c,construction_tiletype)
    local found=df.construction.find(c.pos)
    if found then
        return false
    end
    utils.insert_sorted(df.global.world.constructions,c,"pos",pos_compare)
    local new_org=dfhack.maps.getTileType(c.pos)
    c.original_tile=new_org
    set_tile_type(c.pos,construction_tiletype) --set to tile to new tiletype
        
    return true
end
function check_wall_top( pos ) --check for and remove wall top construction at tile
    local found=df.construction.find(pos)
    if not found then --no construction, can move
        return true
    end
    if not found.flags.top_of_wall then --other construction
        return true
    end
    remove_construction(found)
    return true
end
function move_construction(c,trg_pos)
    local found,cur,pos=utils.erase_sorted_key(df.global.world.constructions,c.pos,"pos",pos_compare)
    if found then
        local from_pos=copyall(c.pos)
        local construction_tiletype=dfhack.maps.getTileType(c.pos)
        if check_wall_top(trg_pos) then
            top_of_wall_fixup(from_pos,trg_pos,c)
            set_tile_type(c.pos,c.original_tile) --set from tile to old tiletype
            c.pos=trg_pos
        
            utils.insert_sorted(df.global.world.constructions,c,"pos",pos_compare)
            local new_org=dfhack.maps.getTileType(c.pos)
            c.original_tile=new_org
            set_tile_type(c.pos,construction_tiletype) --set to tile to new tiletype
        else
            return false
        end
        return true
    end
    return false
end

function remove_construction(c) --pass in construction or position to remove construction at that position
    local map_pos
    if c.pos then 
        map_pos=c.pos
    else
        map_pos=c
    end

    local found,cur,pos=utils.erase_sorted_key(df.global.world.constructions,map_pos,"pos",pos_compare)
    if found then
        local construction_tiletype=dfhack.maps.getTileType(map_pos)
        set_tile_type(map_pos,c.original_tile) --restore map to normal "before construction"
        return true,cur,construction_tiletype
    end
    return false
end


-- The building definition itself
local wall_mover_gears={{x=1,y=0},{x=0,y=1},{x=2,y=1},{x=1,y=2}}

local function get_create_general_ref(building)
    for k,ref in pairs(building.general_refs) do
        if ref:getType()==df.general_ref_type.LOCATION then
            return ref
        end
    end
    local ref=df.general_ref_locationst:new()
    ref.anon_1=0
    ref.anon_2=0
    building.general_refs:insert('#',ref)
    return ref
end
local function get_pos_dir_naked(building)
    local ref=get_create_general_ref(building)
    return ref.anon_1,ref.anon_2
end
local function set_pos_dir_naked(building,pos,dir)
    local ref=get_create_general_ref(building)
    ref.anon_1=pos
    ref.anon_2=dir
end
local function get_pos_and_dir( workshop )
    local s,d=get_pos_dir_naked(workshop)
    -- N,E,S,W
    local dirs={{x=0,y=-1,z=0},{x=1,y=0,z=0},{x=0,y=1,z=0},{x=-1,y=0,z=0}}
    local side=dirs[s+1]
    local pos={x=workshop.centerx+side.x*2,y=workshop.centery+side.y*2,z=workshop.z}

    return pos,dirs[d+1]
end

function wall_mover_update(wshop)
    --TODO: this could be expensive (the find_connected_wall) so it could lag. @PERFORMANCE
    local pos,direction=get_pos_and_dir(wshop)
    local wall_tiles=find_connected_wall(pos,direction)
    builds.setPower(wshop,0,5+#wall_tiles*20)
    if #wall_tiles==0 then
        return
    end

    if not wshop:isUnpowered() then
        for i=1,#wall_tiles do 
            local cur_tile=wall_tiles[#wall_tiles-i+1]
            local cur_trg={x=cur_tile.pos.x+direction.x,y=cur_tile.pos.y+direction.y,z=cur_tile.pos.z+direction.z}
            if valid_target(cur_trg) then
                move_construction(cur_tile,cur_trg) 
                --TODO: spawn dust clouds
            else
                --print("Can't move")
                --printall(cur_trg)
                break
            end 
        end
    end
end
builds.registerBuilding{
        name="WALL_MOVER",
        fix_impassible=true,
        consume=5,
        gears=wall_mover_gears,
        action={300,wall_mover_update},
        animate={
            isMechanical=true,
            frames=make_frames(wall_mover_gears)
        }
        }
wall_mover_sidebar=defclass(wall_mover_sidebar,guidm.WorkshopOverlay)

function wall_mover_sidebar:init(args)
    self:update_text()
    self:addviews{
    widgets.Panel{
        subviews = {
            widgets.Label{ text="Wall mover", frame={t=1,l=1} },
            widgets.Label{ text={{text="Direction:"},{text=self:cb_getfield("dir_text")},
                {key="CUSTOM_D",key_sep="()",on_activate=self:callback("change_dir")}
                }, frame={t=3,l=1} },
            widgets.Label{ text={{text="Side:"},{text=self:cb_getfield("side_text")},
                {key="CUSTOM_S",key_sep="()",on_activate=self:callback("change_side")}
            }, frame={t=4,l=1} },
            
            widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
            widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
        }
    }
    }
end
function wall_mover_sidebar:update_text()
    local dirs={"N","E","S","W"}
    local s,d=get_pos_dir_naked(self.workshop)

    self.dir_text=dirs[d+1]
    self.side_text=dirs[s+1]
end
function wall_mover_sidebar:change_dir()
    local s,d=get_pos_dir_naked(self.workshop)
    d=d+1
    if d>=4 then d=0 end
    
    if d==0 or d==2 then
        s=1
    elseif d==1 or d==3 then
        s=0
    end
    set_pos_dir_naked(self.workshop,s,d)
    self:update_text()
end
function wall_mover_sidebar:change_side()
    local s,d=get_pos_dir_naked(self.workshop)
    if d==0 or d==2 then --north or south only allow E/W
        if s==1 then
            s=3
        else
            s=1
        end
    elseif d==1 or d==3 then --E/W only allow N/S
        if s==0 then
            s=2
        else
            s=0
        end
    end
    set_pos_dir_naked(self.workshop,s,d)
    self:update_text()
end
eventful.registerSidebar("WALL_MOVER",wall_mover_sidebar)
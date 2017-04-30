local eventful=require("plugins.eventful")
function reaction_imbue(reaction,reaction_product,unit,input_items,input_reagents,output_items,call_native)
    --printall(input_items[1])
    local figure_base=219
    local creature_base=19
    local mat_source=input_items[1]
    local mat=mat_source:getActualMaterial()
    local mat_idx=mat_source:getActualMaterialIndex()
    if df.item_body_component:is_instance(mat_source) then
        input_items[0]:setMaterial(figure_base+mat-creature_base)
        input_items[0]:setMaterialIndex(mat_source.hist_figure_id)
    elseif input_items[1]:getMaterial()>=figure_base then
        input_items[0]:setMaterial(input_items[1]:getMaterial())
        input_items[0]:setMaterialIndex(input_items[1]:getMaterialIndex())
    else
        input_items[0]:setMaterial(mat)
        input_items[0]:setMaterialIndex(mat_idx)
    end
    call_native.value=false
end
eventful.registerReaction("LUA_HOOK_IMBUE_MAT",reaction_imbue)

local eventful=require("plugins.eventful")
function add_site(size,civ,site_type,name)
    local x=(df.global.world.map.region_x+1)%16;
    local y=(df.global.world.map.region_y+1)%16;
    local minx,miny,maxx,maxy
    if(x<size) then
        minx=0
        maxx=2*size
    elseif(x+size>16) then
        maxx=16
        minx=16-2*size
    else
        minx=x-size
        maxx=x+size
    end
        
    if(y<size) then
        miny=0
        maxy=2*size
    elseif(y+size>16) then
        maxy=16
        miny=16-2*size
    else
        miny=y-size
        maxy=y+size
    end
    
    --TODO: this is removed!
    require("plugins.dfusion.adv_tools").addSite(nil,nil,maxx,minx,maxy,miny,civ,name,site_type)
end
function reaction(reaction,reaction_product,unit,input_items,input_reagents,output_items,call_native)
    require("gui.dialogs").showInputPrompt("Site name", "Select a name for a new site:", nil,nil, dfhack.curry(add_site,1,unit.civ_id,0))
    call_native.value=false
end
eventful.registerReaction("LUA_HOOK_MAKE_SITE3x3",reaction)

--eventful.onProjItemCheckImpact.port=function(projectile,somebool)
    --if projectile.item.type()==df.item_type.WEAPON and projectile.item
--end--
local ev=require("plugins.eventful")

local gui = require 'gui'
local guidm = require 'gui.dwarfmode'
local widgets =require 'gui.widgets'
local dialog  =require 'gui.dialogs'

slab_sign_view = defclass(slab_sign_view, guidm.WorkshopOverlay)
function slab_sign_view:edit_slab()
    local item=self.item
    
end
function slab_sign_view:init(args)
    self.item=self.workshop.contained_items[0].item --todo check if always the case!
    local label_text=self.item.description
    self:addviews{
    widgets.Panel{
        subviews = {
            widgets.Label{ text="Sign", frame={t=1,l=1} },
            widgets.Label{ text="This sign reads:", frame={t=2}},
            widgets.Label{ text=label_text,frame={t=6,l=1,r=1,b=4} },
            widgets.Label{ text={{key='CUSTOM_E',key_sep=": ",text="Edit text",on_activate=self:callback("edit_slab")}}, frame={b=3,l=1} },
            widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
            widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
        }
    }
    }
end
ev.registerSidebar("SLAB_SIGN",slab_sign_view)

slab_sign_multi_view = defclass(slab_sign_view, guidm.WorkshopOverlay)
function slab_sign_multi_view:list_slabs()
    local ret={}
    local items=self.workshop.contained_items
    for i,v in ipairs(items) do
        if i>0 then
            table.insert(ret,{text=v.item.description,item=v})
        end
    end
    return ret
end
function slab_sign_multi_view:init(args)
    self.slab_list=self:list_slabs()

    self:addviews{
    widgets.Panel{
        subviews = {
            widgets.Label{ text="Slab shelf", frame={t=1,l=1} },
            widgets.Label{ text="Slabs on the shelf:", frame={t=2}},
            widgets.List{ choices=self.slab_list},
            widgets.Label{ text={{key='CUSTOM_A',key_sep=": ",text="Add slab",on_activate=self:callback("add_slab")}}, frame={b=4,l=1} },
            widgets.Label{ text={{key='CUSTOM_E',key_sep=": ",text="Edit text"},on_activate=self:callback("edit_slab")}, frame={b=3,l=1} },
            widgets.Label{ text={{key='DESTROYBUILDING',key_sep=": ",text="Remove Building"}}, frame={b=2,l=1} },
            widgets.Label{ text={{key='LEAVESCREEN',key_sep=": ",text="Done"}}, frame={b=1,l=1} }
        }
    }
    }
end
ev.registerSidebar("SLAB_SIGN_MULTI",slab_sign_multi_view)
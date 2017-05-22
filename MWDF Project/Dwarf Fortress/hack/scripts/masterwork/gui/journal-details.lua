local gui = require 'gui'
local dialog = require 'gui.dialogs'
local widgets =require 'gui.widgets'
local guiScript = require 'gui.script'
local utils = require 'utils'
local split = utils.split_string

args = {...}
if args[1] == 'Creatures' then
 showList = {'All Creatures','GOOD Creatures','EVIL Creatures','SAVAGE Creatures'}
 sortList = {'None','Biome','Type'}
 headers = {'Creatures','Castes'}
elseif args[1] == 'Plants' then
 showList = {'All Plants','Trees','Bushes','Grasses'}
 sortList = {'None','Biome'}
 headers = {'Plants','Plant'}
elseif args[1] == 'Items' then
 showList = {'All Items','Weapons','Shields','Helms','Armor','Gloves','Pants','Shoes','Ammo','Siege Ammo','Trap Components','Tools','Instruments','Food'}
 sortList = {'None'}
 headers = {'Items','Item'}
elseif args[1] == 'Inorganics' then
 showList = {'All Inorganics','Metal','Glass','Stone','Gem'}
 sortList = {'None'}
 headers = {'Inorganics','Inorganic'}
--elseif args[1] == 'Food' then
-- showList = {'Meat','Fish','UnpreparedFish','Eggs','PlantDrink','CreatureDrink','PlantCheese','CreatureCheese','EdibleCheese','AnyDrink','EdiblePlant','CookableLiquid','CookablePowder','CookableSeed','CookableLeaf'}
-- sortList = {'None'}
-- headers = {'Foods','Food'}
elseif args[1] == 'Organics' then
 showList = {'Leather','Silk','PlantFiber','PlantPowder','CreaturePowder','PlantLiquid','CreatureLiquid','MiscLiquid','Bone','Shell','Wood','Horn','Pearl','Tooth','Paste','Pressed','Yarn','MetalThread'}
 sortList = {'None'}
 headers = {'Organics','Organic'}
elseif args[1] == 'Buildings' then
 showList = {'All Buildings','Workshops','Furnaces'}
 sortList = {'None'}
 headers = {'Buildings','Building'}
elseif args[1] == 'Reactions' then
 showList = {'All Reactions'}
 sortList = {'None'}
 headers = {'Reactions','Reaction'}
else
 return
end

function center(str, length)
 local string1 = str
 local string2 = string.format("%"..tostring(math.floor((length-#string1)/2)).."s"..string1,"")
 local string3 = string.format(string2.."%"..tostring(math.ceil((length-#string1)/2)).."s","")
 return string3
end

function tchelper(first, rest)
  return first:upper()..rest:lower()
end

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local guiFunctions = dfhack.script_environment('functions/gui')

CompendiumUi = defclass(CompendiumUi, gui.FramedScreen)
CompendiumUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = args[1],
	             }

function CompendiumUi:init()
numshow = #showList
numsort = #sortList
 self:addviews{
       widgets.Panel{
       view_id = 'detailView',
       frame = { l = 21, r = 0},
       frame_inset = 1,
       subviews = {
        widgets.List{
         view_id = 'detailViewDetails',
         frame = {l = 0, t = 0},
                },
        widgets.List{
		 view_id = 'detailViewDetails1',
         frame = { l = 0, t = 5},
                },
        widgets.List{
		 view_id = 'detailViewDetails2',
         frame = { l = 45, t = 5},
                }
            }
        }
    }
    
 self:addviews{
       widgets.Panel{
	   view_id = 'compendiumBase',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
       	widgets.Label{
		 view_id = 'compendiumBaseHeader_Show',
         frame = { l = 0, t = 3},
         text = {{text='Show:',pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.List{
		 view_id = 'compendiumBaseShow',
         on_submit = self:callback('getShow'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         frame = { l = 0, t = 4}
                },
        widgets.Label{
		 view_id = 'compendiumBaseHeader_Sort',
         frame = { l = 0, t = 4+numshow+2},
         text = {{text='Sort By:',pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.List{
		 view_id = 'compendiumBaseSort',
         on_submit = self:callback('getSort'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         frame = { l = 0, t = 4+numshow+2+1}
                }
            }
        }
    }
 self:addviews{
       widgets.Panel{
	   view_id = 'nonsortedList',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
       	widgets.Label{
		 view_id = 'nonsortedListHeader_1',
         frame = { l = 0, t = 0},
         text = {{text=center(headers[1],20),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.FilteredList{
		 view_id = 'nonsortedList1',
         on_submit = self:callback('submitEntry'),
         on_select = self:callback('selectEntry'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         edit_pen=dfhack.pen.parse{fg=COLOR_WHITE,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
		 view_id = 'nonsortedListHeader_2',
         frame = { l = 0, t = 0},
         text = {{text=center(headers[2],20),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.List{
		 view_id = 'nonsortedList2',
         on_select = self:callback('entryDetails'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         frame = { l = 0, t = 1},
                },
		    }
        },
       widgets.Panel{
	   view_id = 'sortedList',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
       	widgets.Label{
		 view_id = 'sortedListHeader_1',
         frame = { l = 0, t = 0},
         text = {{text=center('Sorted',20),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.FilteredList{
		 view_id = 'sortedList1',
         on_submit = self:callback('submitSort'),
         on_select = self:callback('selectSort'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         edit_pen=dfhack.pen.parse{fg=COLOR_WHITE,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
		 view_id = 'sortedListHeader_2',
         frame = { l = 0, t = 0},
         text = {{text=center(headers[1],20),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.FilteredList{
		 view_id = 'sortedList2',
         on_submit = self:callback('submitEntry'),
         on_select = self:callback('selectEntry'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         edit_pen=dfhack.pen.parse{fg=COLOR_WHITE,bg=0},
         frame = { l = 0, t = 1},
                },
        widgets.Label{
		 view_id = 'sortedListHeader_3',
         frame = { l = 0, t = 0},
         text = {{text=center(headers[2],20),pen=COLOR_LIGHTCYAN}}
                },
	   	widgets.List{
		 view_id = 'sortedList3',
         on_select = self:callback('entryDetails'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         inactive_pen=dfhack.pen.parse{fg=COLOR_CYAN,bg=0},
         frame = { l = 0, t = 1},
                },
		    }
        }
    }

 self.viewcheck = {compendiumBase = {
                                   {'compendiumBaseHeader_Show','compendiumBaseHeader_Sort','compendiumBaseShow','compendiumBaseSort'}
                                  },
                   nonsortedList = {
                                   {'nonsortedList1','nonsortedListHeader_1'},
                                   {'nonsortedList2','nonsortedListHeader_2'}
                                  },
                   sortedList = {
                           {'sortedList1','sortedListHeader_1'},
                           {'sortedList2','sortedListHeader_2'},
                           {'sortedList3','sortedListHeader_3'}
                          }
                  }
 self.viewcheck.base = {'compendiumBase','nonsortedList','sortedList'}
 self.viewcheck.always = {'detailView','detailViewDetails','detailViewDetails1','detailViewDetails2'}
 self.viewcheck.baseNum = 3
 self:setShowSort()
 
 self.subviews.compendiumBaseSort.active = false
 
 self.subviews.nonsortedList.visible = false
 self.subviews.nonsortedList1.active = false
 self.subviews.nonsortedList1.edit.active = false
 self.subviews.nonsortedList2.active = false
 self.subviews.nonsortedList2.visible = false
 
 self.subviews.sortedList.visible = false
 self.subviews.sortedList1.visible = false
 self.subviews.sortedList2.visible = false
 self.subviews.sortedList3.visible = false
 self.subviews.sortedList.active = false
end

function CompendiumUi:setShowSort()
 guiFunctions.makeWidgetList(self.subviews.compendiumBaseShow,'second',showList)
 guiFunctions.makeWidgetList(self.subviews.compendiumBaseSort,'second',sortList)
end

function CompendiumUi:getShow(input,choice)
 list, listNames, listIDs = guiFunctions.getShow(choice.text,self.frame_title)
 dict = {}
 for i,name in pairs(listNames) do
  dict[name] = listIDs[i]
 end
 self.list = list
 self.listNames = listNames
 self.listIDs = listIDs
 self.dict = dict

 self.ShowChoice = choice.text
 self.subviews.compendiumBaseShow.active = false
 self.subviews.compendiumBaseSort.active = true
end

function CompendiumUi:getSort(input,choice)
 self.SortChoice = choice.text
 if choice.text == 'None' then
  guiFunctions.makeWidgetList(self.subviews.nonsortedList1,'second',self.listNames)
  guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'base','nonsortedList')
 else
  sort = guiFunctions.getSort(self.list,self.frame_title,choice.text)
  guiFunctions.makeWidgetList(self.subviews.sortedList1,'first',sort)
  self.sort = sort
  guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'base','sortedList')
 end
end

function CompendiumUi:selectSort()
 return
end

function CompendiumUi:selectEntry(index,choice)
 local input = {}
 local input2 = {}
 local header = {}
 if not choice then return end
 entry, subList = guiFunctions.getEntry(choice.text,self.dict,self.frame_title)
 if not entry then return end
 self.entry = entry 
 self.subList = subList
 header, input, input2 = guiFunctions.getDetails(self.frame_title,self.entry)
 self.subviews.detailViewDetails:setChoices(header)
 self.subviews.detailViewDetails1:setChoices(input)
 self.subviews.detailViewDetails2:setChoices(input2)
end

function CompendiumUi:submitSort(index,choice)
 guiFunctions.makeWidgetList(self.subviews.sortedList2,'second',self.sort[choice.text])
 guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'down')
end

function CompendiumUi:submitEntry(index,choice)
 if self.frame_title == 'Creatures' then
  guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'down')
  if self.subviews.nonsortedList2.visible then
   guiFunctions.makeWidgetList(self.subviews.nonsortedList2,'second',self.subList)
  elseif self.subviews.sortedList3.visible then
   guiFunctions.makeWidgetList(self.subviews.sortedList3,'second',self.subList)
  end
 else
  return
 end
end

function CompendiumUi:entryDetails(index,choice)
 local input = {}
 local input2 = {}
 local header = {}
 if index then 
  index = index - 1
 else
  index = nil
 end
 header, input, input2 = guiFunctions.getDetails(self.frame_title,self.entry,index)
 self.subviews.detailViewDetails:setChoices(header)
 self.subviews.detailViewDetails1:setChoices(input)
 self.subviews.detailViewDetails2:setChoices(input2)
end

function CompendiumUi:clearCreatureDetails()
 input = {}
 self.subviews.detailViewDetails:setChoices(input)
 self.subviews.detailViewDetails1:setChoices(input)
 self.subviews.detailViewDetails2:setChoices(input)
end

function CompendiumUi:onInput(keys)
 if keys.LEAVESCREEN then
  check = guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'up')
  self:clearCreatureDetails()
  if check then
   self:clearCreatureDetails()
  else
   if self.subviews.compendiumBase.visible then
    if self.subviews.compendiumBaseSort.active then
     self.subviews.compendiumBaseSort.active = false
    else
     self:dismiss()
    end
   else
    guiFunctions.changeViewScreen(self.subviews,self.viewcheck,'base','compendiumBase')    
   end
  end
 end

 self.super.onInput(self,keys)
end

local screen = CompendiumUi{}
screen:show()

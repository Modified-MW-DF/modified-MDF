local gui = require 'gui'
local dialog = require 'gui.dialogs'
local widgets =require 'gui.widgets'
local guiScript = require 'gui.script'
local utils = require 'utils'
local split = utils.split_string

checkclass = true

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

function getTargetFromScreens()
 local my_trg
 if dfhack.gui.getSelectedUnit(true) then
  my_trg=dfhack.gui.getSelectedUnit(true)
 else
  qerror("No valid target found")
 end
 return my_trg
end

local guiFunctions = dfhack.script_environment('functions/gui')
 
UnitViewUi = defclass(UnitViewUi, gui.FramedScreen)
UnitViewUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = "Detailed unit viewer",
	             }

function UnitViewUi:init(args)
 test_length = 40
 self.target = args.target
 self.test_length = test_length
 local persistTable = require 'persist-table'
 if safe_index(persistTable,'GlobalTable','roses','ClassTable') then
  self.classSystem = true
 end
-- Positioning
---- Main Frame Layout
--[[
          X                   Y                 Z
    Name               |                |                |
A   Caste              | Description    |     Skills     |
    Civilization       |                |                |
-----------------------|----------------|----------------|
B   Membership/Worship | Appearance     |                |
-----------------------|----------------|----------------|
C                      | Attribute Desc |                |
----------------------------------------------------------
Bottom UI:
Attributes	Health		Syndromes	Thoughts
Classes		Spells		Traits
]]
----
 AX = {anchor = {}, width = test_length, height = 6}
 AY = {anchor = {}, width = test_length, height = 6}
 AZ = {anchor = {}, width = test_length, height = 20}
 BX = {anchor = {}, width = test_length, height = 10}
 BY = {anchor = {}, width = test_length, height = 10}
 BZ = {anchor = {}, width = test_length, height = 0}
 CX = {anchor = {}, width = test_length, height = 10}
 CY = {anchor = {}, width = test_length, height = 10}
 CZ = {anchor = {}, width = test_length, height = 10}
----
 X_width = math.max(AX.width,BX.width,CX.width)
 Y_width = math.max(AY.width,BY.width,CY.width)
 Z_width = math.max(AZ.width,BZ.width,CZ.width)
----
 AX.anchor.top  = 0
 AY.anchor.top  = 0
 AZ.anchor.top  = 0
 AX.anchor.left = 0
 AY.anchor.left = X_width + 4
 AZ.anchor.left = X_width + Y_width + 8
----
 BX.anchor.top  = AX.height + 1
 BY.anchor.top  = AY.height + 1
 BZ.anchor.top  = AZ.height + 1
 BX.anchor.left = 0
 BY.anchor.left = X_width + 4
 BZ.anchor.left = X_width + Y_width + 8
----
 CX.anchor.top  = AX.height + BX.height + 2
 CY.anchor.top  = AY.height + BY.height + 2
 CZ.anchor.top  = AZ.height + BZ.height + 2
 CX.anchor.left = 0
 CY.anchor.left = X_width + 4
 CZ.anchor.left = X_width + Y_width + 8
 
-- Create frames
 self:addviews{
      widgets.Panel{view_id = 'main',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
        	widgets.List{
		 view_id = 'AX',
        	 frame = { l = AX.anchor.left, t = AX.anchor.top, w = X_width, h = AX.height},
                },
		widgets.List{
		 view_id = 'AY',
        	 frame = { l = AY.anchor.left, t = AY.anchor.top, w = Y_width, h = AY.height},
                },          
		widgets.List{
		 view_id = 'AZ',
        	 frame = { l = AZ.anchor.left, t = AZ.anchor.top, w = Z_width, h = AZ.height},
                },
		widgets.List{
		 view_id = 'BX',
        	 frame = { l = BX.anchor.left, t = BX.anchor.top, w = X_width, h = BX.height},
                },
		widgets.List{
		 view_id = 'CX',
        	 frame = { l = CX.anchor.left, t = CX.anchor.top, w = X_width, h = CX.height},
                },
		widgets.List{
		 view_id = 'BZ',
        	 frame = { l = BZ.anchor.left, t = BZ.anchor.top, w = Z_width, h = BZ.height},
                },
		widgets.List{
		 view_id = 'CZ',
        	 frame = { l = CZ.anchor.left, t = CZ.anchor.top, w = CZ.width, h = CZ.height},
                },
		widgets.List{
		 view_id = 'CY',
         	 frame = {  l = CY.anchor.left, t = CY.anchor.top, w = Y_width, h = CY.height},
                },
        	widgets.List{
        	 view_id = 'BY',
        	 frame = { l = BY.anchor.left, t = BY.anchor.top, w = Y_width, h = BY.height},
                }}}}
 
 self:addviews{
  widgets.Panel{
   view_id = 'bottomView',
   frame = { b = 0, h = 1},
   subviews = {
               widgets.Label{
                view_id = 'bottom_ui',
                frame = { l = 0, t = 0}
                text = 'filled by updateBottom()'
               }}}}
 
 self:addviews{
  widgets.Panel{
   view_id = 'attributeView',
   frame = { l = 0, r = 0 },
   frame_inset = 1,
   subviews = {
	    widgets.List{
             view_id = 'attributeViewDetailed',
             frame = { l = 0, t = 0},
            }}}}

 self:addviews{
  widgets.Panel{
   view_id = 'thoughtsView',
   frame = { l = 0, r = 0 },
   frame_inset = 1,
   subviews = {
	    widgets.List{
             view_id = 'thoughtsViewDetailed',
             frame = { l = 0, t = 0},
            },
            widgets.List{
             view_id = 'thoughtsViewDetailed2',
             frame = { l = 45, t = 0},
            }}}}

 self:addviews{
  widgets.Panel{
   view_id = 'syndromeView',
   frame = { l = 0, r = 0 },
   frame_inset = 1,
   subviews = {
	    widgets.List{
	     view_id = 'syndromeViewDetailed',
             frame = { l = 0, t = 0},
            }}}}

 self:addviews{
  widgets.Panel{
   view_id = 'classView2',
   frame = { l = 51, r = 0},
   frame_inset = 1,
   subviews = {
            widgets.List{
             view_id = 'classViewDetailedDetails1',
             frame = { l = 0, t = 0},
            },
            widgets.List{
	     view_id = 'classViewDetailedDetails2',
             frame = { l = 40, t = 2},
            }
   }
  },
  widgets.Panel{
   view_id = 'classView',
   frame = { l = 0, r = 0 },
   frame_inset = 1,
   subviews = {
            widgets.List{
	     view_id = 'classViewDetailedTop',
             frame = { l = 0, t = 0},
            },
	    widgets.FilteredList{
	     view_id = 'classViewDetailedClasses',
             on_select = self:callback('checkClass'),
             on_submit = self:callback('changeClass'),
             text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
             cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
             frame = { l = 0, t = 3},
          }
   }
  }
 }
 self:addviews{
  widgets.Panel{
   view_id = 'featView2',
   frame = { l = 51, r = 0},
   frame_inset = 1,
   subviews = {
            widgets.List{
             view_id = 'featViewDetailedDetails1',
             frame = { l = 0, t = 0},
            },
            widgets.List{
             view_id = 'featViewDetailedDetails2',
             frame = { l = 40, t = 2},
            }
   }
  },
  widgets.Panel{
   view_id = 'featView',
   frame = { l = 0, r = 0 },
   frame_inset = 1,
   subviews = {
            widgets.List{
             view_id = 'featViewDetailedTop',
             frame = { l = 0, t = 0},
            },
            widgets.FilteredList{
             view_id = 'featViewDetailedFeats',
             on_select = self:callback('checkFeat'),
             on_submit = self:callback('changeFeat'),
             text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
             cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
             frame = { l = 0, t = 3},
          }
   }
  }
 }
 self:addviews{
  widgets.Panel{
   view_id = 'spellView2',
   frame = { l = 51, r = 0},
   frame_inset = 1,
   subviews = {
            widgets.List{
             view_id = 'spellViewDetailedDetails1',
             frame = { l = 0, t = 0},
            },
            widgets.List{
             view_id = 'spellViewDetailedDetails2',
             frame = { l = 40, t = 2},
            }
   }
  },
  widgets.Panel{
   view_id = 'spellView',
   frame = { l = 0, r = 0 },
   frame_inset = 1,
   subviews = {
            widgets.List{
             view_id = 'spellViewDetailedTop',
             frame = { l = 0, t = 0},
            },
            widgets.FilteredList{
             view_id = 'spellViewDetailedSpells',
             on_select = self:callback('checkSpell'),
             on_submit = self:callback('changeSpell'),
             text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
             cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
             frame = { l = 0, t = 3},
          }
   }
  }
 }

 self.subviews.attributeView.visible = false
 self.subviews.classView.visible = false
 self.subviews.classView2.visible = false
 self.subviews.spellView.visible = false
 self.subviews.spellView2.visible = false
 self.subviews.featView.visible = false
 self.subviews.featView2.visible = false
 self.subviews.syndromeView.visible = false
 self.subviews.thoughtsView.visible = false
 self.subviews.main.visible = true
 self.subviews.bottomView.visible = true

 self:fillMain()
 self:updateBottom()

 self:detailsAttributes()
 self:detailsSyndromes()
 self:detailsThoughts()

 self:classList('Available')
 self:spellList('Available')
 self:featList('Available')
end

function UnitViewUi:updateBottom()
 if self.classSystem then
  text = {
          { key = 'CUSTOM_SHIFT_A', text = ': Attributes  ', on_activate = self:callback('attributeView') },
          { key = 'CUSTOM_SHIFT_H', text = ': Health  ', on_activate = self:callback('healthView') },
          { key = 'CUSTOM_SHIFT_S', text = ': Syndromes  ', on_activate = self:callback('syndromeView') },
          { key = 'CUSTOM_SHIFT_T', text = ': Thoughts and Preferences  ', on_activate = self:callback('thoughtsView') },
          { text = NEWLINE },
          { key = 'CUSTOM_SHIFT_C', text = ': Classes  ', on_activate = self:callback('classView') },
          { key = 'CUSTOM_SHIFT_F', text = ': Feats  ', on_activate = self:callback('featView') },
          { key = 'CUSTOM_SHIFT_P', text = ': Spells  ', on_activate = self:callback('spellView') },
         }
 else
  text = {
          { key = 'CUSTOM_SHIFT_A', text = ': Attributes  ', on_activate = self:callback('attributeView') },
          { key = 'CUSTOM_SHIFT_H', text = ': Health  ', on_activate = self:callback('healthView') },
          { key = 'CUSTOM_SHIFT_S', text = ': Syndromes  ', on_activate = self:callback('syndromeView') },
          { key = 'CUSTOM_SHIFT_T', text = ': Thoughts and Preferences  ', on_activate = self:callback('thoughtsView') },
         }
 end
    self.subviews.bottom_ui:setText(text)
end
function UnitViewUi:attributeView()
 self.subviews.bottom_ui:setText({
                                  { text = 'ESC: Back'}
                                 })
 self.subviews.attributeView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:classView()
 self.subviews.bottom_ui:setText({
                                  { key = 'CUSTOM_SHIFT_A', text = ': Show All Classes  ', on_activate = function () self:classList('All') end },
                                  { key = 'CUSTOM_SHIFT_C', text = ': Show Civilization Classes  ', on_activate = function () self:classList('Civ') end },
                                  { key = 'CUSTOM_SHIFT_K', text = ': Show Known Classes  ', on_activate = function () self:classList('Learned') end },
                                  { key = 'CUSTOM_SHIFT_V', text = ': Show Available Classes  ', on_activate = function () self:classList('Available') end },
                                  { text = 'ESC: Back'}
                                 })
 self.subviews.classView.visible = true
 self.subviews.classView2.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:featView()
 self.subviews.bottom_ui:setText({
                                  { key = 'CUSTOM_SHIFT_A', text = ': Show All Feats  ', on_activate = function () self:featList('All') end },
                                  { key = 'CUSTOM_SHIFT_K', text = ': Show Known Feats  ', on_activate = function () self:featList('Learned') end },
                                  { key = 'CUSTOM_SHIFT_V', text = ': Show Available Feats  ', on_activate = function () self:featList('Available') end },
                                  { text = 'ESC: Back'}
                                 })
 self.subviews.featView.visible = true
 self.subviews.featView2.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:healthView()
 return
end
function UnitViewUi:spellView()
 self.subviews.bottom_ui:setText({
                                  { key = 'CUSTOM_SHIFT_A', text = ': Show All Spells  ', on_activate = function () self:spellList('All') end },
                                  { key = 'CUSTOM_SHIFT_C', text = ': Show Class Spells  ', on_activate = function () self:spellList('Class') end },
                                  { key = 'CUSTOM_SHIFT_K', text = ': Show Known Spells  ', on_activate = function () self:spellList('Learned') end },
                                  { key = 'CUSTOM_SHIFT_T', text = ': Show Active Spells  ', on_activate = function () self:spellList('Active') end },
                                  { key = 'CUSTOM_SHIFT_V', text = ': Show Available Spells  ', on_activate = function () self:spellList('Available') end },
                                  { text = 'ESC: Back'}
                                 }) 
 self.subviews.spellView.visible = true
 self.subviews.spellView2.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:syndromeView()
 self.subviews.bottom_ui:setText({
                                  { text = 'ESC: Back'}
                                 })
 self.subviews.syndromeView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:thoughtsView()
 self.subviews.bottom_ui:setText({
                                  { text = 'ESC: Back'}
                                 })
 self.subviews.thoughtsView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:fillMain()
 unit = self.target
 width = self.test_length
 base = guiFunctions.getBaseOutput(unit,width)
 info = guiFunctions.getInfo(unit,width)
 self.info = info
 description = guiFunctions.getDescriptionOutput(info,width)
 health = guiFunctions.getHealthOutput(info,width)
 worship = guiFunctions.getWorshipOutput(info,width)
 appearance = guiFunctions.getAppearanceOutput(info,width)
 skills = guiFunctions.getSkillsOutput(unit,width)
 attributes = guiFunctions.getAttributesOutput(info,width)
 if self.classSystem then class = guiFunctions.getClassOutput(unit,width) end
--AX
   self.subviews.AX:setChoices(base)
--AY
   self.subviews.AY:setChoices(description)
--AZ
   if self.classSystem then self.subviews.AZ:setChoices(class) end
--BX
   self.subviews.BX:setChoices(worship)
--BY
   self.subviews.BY:setChoices(appearance)
--BZ
   self.subviews.BZ:setChoices(skills)
--CX
   self.subviews.CX:setChoices(health)
--CY
   self.subviews.CY:setChoices(attributes)
--CZ
-- self.subviews.CZ:setChoices()
end

function UnitViewUi:detailsAttributes()
 unit = self.target
 insert = guiFunctions.getAttributesDetails(unit)
 self.subviews.attributeViewDetailed:setChoices(insert)
end

function UnitViewUi:classList(filter)
 unit = self.target
 classList = guiFunctions.getClassList(unit,filter)
 in2 = {}
 table.insert(in2,{text = {{text=center('Classes',40),width=30,pen=COLOR_LIGHTCYAN}}})
 table.insert(in2,{text = {
                           {text='Class',width=21,pen=COLOR_LIGHTMAGENTA},
                           {text='Level',width=7,rjustify=true,pen=COLOR_LIGHTMAGENTA},
                           {text='Experience',width=12,rjustify=true,pen=COLOR_LIGHTMAGENTA},
                          }})
 self.subviews.classViewDetailedClasses:setChoices(classList)
 self.subviews.classViewDetailedTop:setChoices(in2)
end

function UnitViewUi:checkClass(index,choice)
 if not choice then return end
 unit = self.target
 input, input2, check = guiFunctions.getClassDetails(unit,choice)
 self.subviews.classViewDetailedDetails1:setChoices(input)
 self.subviews.classViewDetailedDetails2:setChoices(input2)
end

function UnitViewUi:changeClass(index,choice)
 unit = self.target
 local name = choice.text[1].text
 local persistTable = require 'persist-table'
 local classTable = persistTable.GlobalTable.roses.ClassTable
 for _,x in pairs(classTable._children) do
  if classTable[x].Name == name then
   class = x
   break
  end
 end

 if dfhack.script_environment('functions/class').checkRequirementsClass(unit,class) then
  dfhack.script_environment('functions/class').changeClass(unit,class)
 else
  return
 end
end

function UnitViewUi:spellList(filter)
 unit = self.target
 spellList = guiFunctions.getSpellList(unit,filter)
 in2 = {}
 table.insert(in2,{text = {{text=center('Spells',40),width=30,pen=COLOR_LIGHTCYAN}}})
 table.insert(in2,{text = {
                           {text='Spell',width=20,pen=COLOR_LIGHTMAGENTA},
                           {text='Sphere',width=10,rjustify=true,pen=COLOR_LIGHTMAGENTA},
                           {text='School',width=10,rjustify=true,pen=COLOR_LIGHTMAGENTA},
                          }})
 self.subviews.classViewDetailedSpells:setChoices(spellList)
 self.subviews.classViewDetailedTop:setChoices(in2)
end

function UnitViewUi:checkSpell(index,choice)
 if not choice then return end
 unit = self.target
 input, input2, check = guiFunctions.getSpellDetails(unit,choice)
 self.subviews.spellViewDetailedDetails1:setChoices(input)
 self.subviews.spellViewDetailedDetails2:setChoices(input2)
end

function UnitViewUi:changeSpell(index,choice)
 unit = self.target
 local name = choice.text[1].text
 local persistTable = require 'persist-table'
 local spellTable = persistTable.GlobalTable.roses.SpellTable
 for _,x in pairs(spellTable._children) do
  if spellTable[x].Name == name then
   spell = x
   break
  end
 end

 if dfhack.script_environment('functions/class').checkRequirementsSpell(unit,spell) then
  dfhack.script_environment('functions/class').changeSpell(unit,spell,'add')
 else
  return
 end
end

function UnitViewUi:featList(filter)
 unit = self.target
 featList = guiFunctions.getClassList(unit,filter)
 in2 = {}
 table.insert(in2,{text = {{text=center('Feats',40),width=40,pen=COLOR_LIGHTCYAN}}})
 table.insert(in2,{text = {
                           {text='Feat',width=40,pen=COLOR_LIGHTMAGENTA}
                          }})
 self.subviews.classViewDetailedClasses:setChoices(featList)
 self.subviews.classViewDetailedTop:setChoices(in2)
end

function UnitViewUi:checkFeat(index,choice)
 if not choice then return end
 unit = self.target
 input, input2, check = guiFunctions.getFeatDetails(unit,choice)
 self.subviews.featViewDetailedDetails1:setChoices(input)
 self.subviews.featViewDetailedDetails2:setChoices(input2)
end

function UnitViewUi:changeFeat(index,choice)
 unit = self.target
 local name = choice.text[1].text
 local persistTable = require 'persist-table'
 local featTable = persistTable.GlobalTable.roses.FeatTable
 for _,x in pairs(featTable._children) do
  if featTable[x].Name == name then
   feat = x
   break
  end
 end

 if dfhack.script_environment('functions/class').checkRequirementsFeat(unit,feat) then
  dfhack.script_environment('functions/class').addFeat(unit,feat)
 else
  return
 end
end

function UnitViewUi:detailsSyndromes()
 unit = self.target
 insert = guiFunctions.getSyndromesDetails(unit)
 self.subviews.syndromeViewDetailed:setChoices(insert)
end

function UnitViewUi:detailsThoughts()
 info = self.info
 insert1, insert2 = guiFunctions.getThoughtsDetails(info)
 self.subviews.thoughtsViewDetailed:setChoices(insert1)
 self.subviews.thoughtsViewDetailed2:setChoices(insert2)
end

function UnitViewUi:onInput(keys)
 if keys.LEAVESCREEN then
  if self.subviews.syndromeView.visible then
   self:updateBottom()
   self.subviews.syndromeView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.attributeView.visible then
   self:updateBottom()
   self.subviews.attributeView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.classView.visible then
   self:updateBottom()
   self.subviews.classView.visible = false
   self.subviews.classView2.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.featView.visible then
   self:updateBottom()
   self.subviews.featView.visible = false
   self.subviews.featView2.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.spellView.visible then
   self:updateBottom()
   self.subviews.spellView.visible = false
   self.subviews.spellView2.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.thoughtsView.visible then
   self:updateBottom()
   self.subviews.thoughtsView.visible = false
   self.subviews.main.visible = true
  else
   self:dismiss()
  end
 else
  UnitViewUi.super.onInput(self, keys)
 end
end

function show_editor(trg)
 local screen = UnitViewUi{target=trg}
 screen:show()
end

show_editor(getTargetFromScreens())

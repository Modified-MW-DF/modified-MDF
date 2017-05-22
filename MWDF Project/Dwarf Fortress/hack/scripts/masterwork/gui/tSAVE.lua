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

UnitViewUi = defclass(UnitViewUi, gui.FramedScreen)
UnitViewUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = "Detailed unit viewer",
	             }

function UnitViewUi:init(args)
 test_length = 60
-- Gather data
 target = args.target
 full_name = getTargetName(args.target)
 caste = getTargetCaste(args.target)
 syndromes, syndromes_detail = getTargetSyndromes(args.target)
 interactions, t_interactions = getTargetInteractions(args.target)
 p_attributes, m_attributes = getTargetAttributes(args.target)
 skills = getTargetSkills(args.target)
 entity, civilization = getTargetEntity(args.target)
 info = getTargetInfo(args.target)

 -- Name
 nm_w = test_length
 nm_h = 5
 
 -- Membership and Worship
 length = test_length
 mem_desc = ''
 n = math.floor(#info.membership/length)+1
 for i = 1,n do
  mem_desc = mem_desc..string.sub(info.membership,1+length*(i-1),length*i)..'\n'
 end
 height = n
 wor_desc = ''
 n = math.floor(#info.worship/length)+1
 for i = 1,n do
  wor_desc = wor_desc..string.sub(info.worship,1+length*(i-1),length*i)..'\n'
 end
 mw_w = length
 mw_h = height + n + 3
 
 -- Physical Stats
 ps_w = 10
 ps_h = 4

 -- Physical Description
 length = test_length
 app_desc = ''
 n = math.floor(#info.appearance/length)+1
 for i = 1,n do
  app_desc = app_desc..string.sub(info.appearance,1+length*(i-1),length*i)..'\n'
 end
 pd_w = length
 pd_h = n + 1
 
 -- Creature Description
 length = test_length
 description = ''
 n = math.floor(#info.description/length)+1
 for i = 1,n do
  description = description..string.sub(info.description,1+length*(i-1),length*i)..'\n'
 end
 cd_w = length
 cd_h = n+1

 -- Skills
 height, s1, s2, s3 = 5, 0, 0, 0
 for i,x in pairs(skills) do
  height = height + 1
  if #i > s1 then s1 = #i end
  if #x[1] > s2 then s2 = #x[1] end
  if #tostring(x[2]) > s3 then s3 = #tostring(x[2]) end
 end
 sk_w = s1 + s2 + s3 + 3 + 4
 sk_h = height+1

 -- Basic Health
 y1 = #"Active Syndromes"
 y2 = #'Permenant'
 for i,x in pairs(syndromes) do
  if #x[1] > y1 then y1 = #x[1] end
  if #x[2] > y2 then y1 = #x[2] end
 end
 syndrome_len = y1 + y2 + 1
 syndrome_hgt = #syndromes + 2
 length = test_length
 if info.wounds ~= '' then
  hlt_desc = ''
  n = math.floor(#info.wounds/length)+1
  for i = 1,n do
   hlt_desc = hlt_desc..string.sub(info.wounds,1+length*(i-1),length*i)..'\n'
  end
 else
  hlt_desc = 'Perfect Health'
  n = 1
 end
 bh_w = length
 bh_h = syndrome_hgt + n + 3

 -- Preferences, Traits, and Values
 length = test_length
 prf_desc = ''
 n = math.floor(#info.preferences/length)+1
 for i = 1,n do
  prf_desc = prf_desc..string.sub(info.preferences,1+length*(i-1),length*i)..'\n'
 end 
 height1 = n
 trt_desc = ''
 n = math.floor(#info.traits/length)+1
 for i = 1,n do
  trt_desc = trt_desc..string.sub(info.traits,1+length*(i-1),length*i)..'\n'
 end
 height2 = n
 val_desc = ''
 n = math.floor(#info.values/length)+1
 for i = 1,n do
  val_desc = val_desc..string.sub(info.values,1+length*(i-1),length*i)..'\n'
 end
 tp_w = length
 tp_h = height1 + height2 + n + 6

 -- Attribute Description
 length = test_length
 att_desc1 = ''
 n = math.floor(#info.attributes[1]/length)+1
 for i = 1,n do
  att_desc1 = att_desc1..string.sub(info.attributes[1],1+length*(i-1),length*i)..'\n'
 end
 height1 = n
 att_desc2 = ''
 n = math.floor(#info.attributes[2]/length)+1
 for i = 1,n do
  att_desc2 = att_desc2..string.sub(info.attributes[2],1+length*(i-1),length*i)..'\n'
 end
 ad_w = length
 ad_h = height1+n+2

 -- Emotions
 length = test_length
 tht_desc = ''
 n = math.floor(#info.thoughts/length)+1
 for i = 1,n do
  tht_desc = tht_desc..string.sub(info.thoughts,1+length*(i-1),length*i)..'\n'
 end
 em_w = length
 em_h = n + 1
 
-- Positioning
 sk_l,ad_l,bh_l = 0,0,0
 cd_l,ps_l,pd_l,em_l = 61,61,61,61
 mw_l,tp_l      = 122,122

 nm_t = 0
 sk_t = nm_t + nm_h + 1
 ad_t = sk_t + sk_h + 1
 bh_t = ad_t + ad_h + 1
 cd_t = 0
 ps_t = cd_t + cd_h + 1
 pd_t = ps_t + ps_h + 1
 em_t = pd_t + pd_h + 1
 mw_t = 0
 tp_t = mw_t + mw_h + 1

-- Create frames
 self:addviews{
       widgets.Panel{
	   view_id = 'main',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
        widgets.Label{
		 view_id = 'unit',
         frame = { l = nm_l, t = nm_t, w = nm_w, h = nm_h},
         text = {
                { text = full_name, width = b11_len },
                NEWLINE,
                { text = caste, width = b11_len },
				NEWLINE,
				{ text = civilization, width = b11_len },
                }
                },
		widgets.List{
		 view_id = 'creature_description',
         frame = { l = cd_l, t = cd_t, w = cd_w, h = cd_h},
                },          
		widgets.List{
		 view_id = 'basic_health',
         frame = { l = bh_l, t = bh_t, w = bh_w, h = bh_h},
                },
		widgets.List{
		 view_id = 'membership_and_worship',
         frame = { l = mw_l, t = mw_t, w = mw_w, h = mw_h},
                },
		widgets.List{
		 view_id = 'skills',
         frame = { l = sk_l, t = sk_t, w = sk_w, h = sk_h},
                },
		widgets.List{
		 view_id = 'emotions',
         frame = { l = em_l, t = em_t, w = em_w, h = em_h},
                },
		widgets.List{
		 view_id = 'thoughts_and_preferences',
         frame = { l = tp_l, t = tp_t, w = tp_w, h = tp_h},
                },
        widgets.List{
         view_id = 'physical_stats',
         frame = { l = ps_l, t = ps_t, w = ps_w, h = ps_h},
                },
		widgets.List{
		 view_id = 'attribute_description',
         frame = { l = ad_l, t = ad_t, w = ad_w, h = ad_h},
                },
        widgets.List{
         view_id = 'physical_desc',
         frame = { l = pd_l, t = pd_t, w = pd_w, h = pd_h},
                },
		widgets.Label{
                    view_id = 'bottom_ui',
                    frame = { b = 0, h = 1 },
                    text = 'filled by updateBottom()'
                }
            }
		}
	}
 self:addviews{
       widgets.Panel{
	   view_id = 'attributeView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
       subviews = {
	   	widgets.List{
		 view_id = 'attributeViewDetailed',
         frame = { l = 0, t = 0},
                },
		    }
        }
    }
 self:addviews{
       widgets.Panel{
       view_id = 'classView2',
       frame = { l = 71, r = 0},
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
	   	widgets.List{
		 view_id = 'classViewDetailedClasses',
         on_select = self:callback('checkClass'),
         text_pen=dfhack.pen.parse{fg=COLOR_DARKGRAY,bg=0},
         cursor_pen=dfhack.pen.parse{fg=COLOR_YELLOW,bg=0},
         frame = { l = 0, t = 3},
                },
		    }
        }
    }
 self:addviews{
       widgets.Panel{
	   view_id = 'equipmentView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }
 self:addviews{
       widgets.Panel{
	   view_id = 'healthView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }
 self:addviews{
       widgets.Panel{
	   view_id = 'interactionView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }
 self:addviews{
       widgets.Panel{
	   view_id = 'spellbookView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }
 self:addviews{
       widgets.Panel{
	   view_id = 'legendsView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }
 self:addviews{
       widgets.Panel{
	   view_id = 'relationshipView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
		    }
        }
    }
 self:addviews{
       widgets.Panel{
	   view_id = 'syndromeView',
       frame = { l = 0, r = 0 },
       frame_inset = 1,
	   subviews = {
	   	widgets.List{
		 view_id = 'syndromeViewDetailed',
         frame = { l = 0, t = 0},
                },
		    }
        }
    }
 self.subviews.attributeView.visible = false
 self.subviews.classView.visible = false
 self.subviews.classView2.visible = false
 self.subviews.equipmentView.visible = false
 self.subviews.healthView.visible = false
 self.subviews.interactionView.visible = false
 self.subviews.legendsView.visible = false
 self.subviews.spellbookView.visible = false
 self.subviews.relationshipView.visible = false 
 self.subviews.syndromeView.visible = false
 self.subviews.main.visible = true
 self:insertDescriptionAppearance(app_desc)
 self:insertDescriptionAttribute(att_desc1,att_desc2)
 self:insertDescriptionBasicHealth(hlt_desc,syndromes)
 self:insertDescriptionCreature(description)
 self:insertDescriptionEmotion(tht_desc)
 self:insertDescriptionMembership(mem_desc,wor_desc)
 self:insertDescriptionPersonality(prf_desc,trt_desc,val_desc)
 self:insertSkills(skills)
-- self:insertSyndromes(syndromes)
-- self:insertInteractions(interactions,t_interactions)
-- if checkclass then self:insertClasses(classes) end
 self:attributeDetail(p_attributes,m_attributes)
 self:classDetail(args.target)
 self:syndromeDetail(syndromes, syndromes_detail)
 self:updateBottom()
end

function UnitViewUi:updateBottom()
    self.subviews.bottom_ui:setText(
        {
            { key = 'CUSTOM_SHIFT_A', text = ': Attribute Information  ', on_activate = self:callback('attributeView') }, 
            { key = 'CUSTOM_SHIFT_C', text = ': Class Information  ', on_activate = self:callback('classView') }, 
            { key = 'CUSTOM_SHIFT_E', text = ': Equipment List  ', on_activate = self:callback('equipmentView') }, 
            { key = 'CUSTOM_SHIFT_H', text = ': Health Information  ', on_activate = self:callback('healthView') }, 
            NEWLINE,
            { key = 'CUSTOM_SHIFT_I', text = ': Interaction Information  ', on_activate = self:callback('interactionView') }, 
            { key = 'CUSTOM_SHIFT_L', text = ': Legends  ', on_activate = self:callback('legendsView') }, 
            { key = 'CUSTOM_SHIFT_P', text = ': Spellbook  ', on_activate = self:callback('spellbookView') },
            { key = 'CUSTOM_SHIFT_R', text = ': Relationship Information  ', on_activate = self:callback('relationshipView') }, 
            { key = 'CUSTOM_SHIFT_S', text = ': Syndrome Information  ', on_activate = self:callback('syndromeView') }
        })
end

function UnitViewUi:attributeView()
 self.subviews.attributeView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:classView()
 self.subviews.classView.visible = true
 self.subviews.classView2.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:equipmentView()
 self.subviews.equipmentView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:healthView()
-- self.subviews.healthView.visible = true
-- self.subviews.main.visible = false
 local temp_screen = df.viewscreen_unitst:new()
 temp_screen.unit = target
 gui.simulateInput(temp_screen,'UNITVIEW_HEALTH')
end
function UnitViewUi:interactionView()
 self.subviews.interactionView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:legendsView()
-- self.subviews.legendsView.visible = true
-- self.subviews.main.visible = false
 local temp_screen = df.viewscreen_unitst:new()
 temp_screen.unit = target
 gui.simulateInput(temp_screen,'UNITVIEW_KILLS')
end
function UnitViewUi:spellbookView()
 self.subviews.spellbookView.visible = true
 self.subviews.main.visible = false
end
function UnitViewUi:relationshipView()
-- self.subviews.relationshipView.visible = true
-- self.subviews.main.visible = false
 local temp_screen = df.viewscreen_unitst:new()
 temp_screen.unit = target
 gui.simulateInput(temp_screen,'UNITVIEW_RELATIONSHIPS')
end
function UnitViewUi:syndromeView()
 self.subviews.syndromeView.visible = true
 self.subviews.main.visible = false
end

function UnitViewUi:attributeDetail(p_attributes,m_attributes)
 attributes = {}
 a_len = 19
 n_len = 5
 table.insert(attributes, {text = {{text=center('Attributes',57), width = attribute_len,pen=COLOR_LIGHTCYAN}}})
 table.insert(attributes, {text = {{text=center('Physical',57), width = attribute_len,pen=COLOR_LIGHTMAGENTA}}})
 table.insert(attributes, {text = {
                                   {text=center('',19),width=19},
                                   {text='Current',rjustify=true,width=9,pen=COLOR_WHITE},
                                   {text='Class',rjustify=true,width=7,pen=COLOR_WHITE},
                                   {text='Item',rjustify=true,width=6,pen=COLOR_WHITE},
                                   {text='Syndrome',rjustify=true,width=10,pen=COLOR_WHITE},
                                   {text='Base',rjustify=true,width=6,pen=COLOR_WHITE}
                                  }})
 ttt = 0
 for i,x in pairs(p_attributes) do
  if ttt == 1 then
   if p_attributes[i]['Current'] >= p_attributes[i]['Base'] then
    fgc = COLOR_LIGHTGREEN
   elseif p_attributes[i]['Current'] < p_attributes[i]['Base'] then
    fgc = COLOR_LIGHTRED
   end
   ttt = 0
  elseif ttt == 0 then
   if p_attributes[i]['Current'] >= p_attributes[i]['Base'] then
    fgc = COLOR_LIGHTGREEN
   elseif p_attributes[i]['Current'] < p_attributes[i]['Base'] then
    fgc = COLOR_LIGHTRED
   end
   ttt = 1
  end
  table.insert(attributes, {text = {
	                                {text = i, width = a_len,pen = fgc},
		                            {text = tostring(p_attributes[i]['Current']), rjustify=true,width=9,pen = fgc},
                                    {text = tostring(p_attributes[i]['Class']), rjustify=true,width=7,pen = fgc},
                                    {text = tostring(p_attributes[i]['Item']), rjustify=true,width=6,pen = fgc},
                                    {text = tostring(p_attributes[i]['Syndrome']), rjustify=true,width=10,pen = fgc},
                                    {text = tostring(p_attributes[i]['Base']), rjustify=true,width=6,pen = fgc}
                                   }})
 end
 table.insert(attributes, {text = {{text=center('Mental',57), width = attribute_len,pen=COLOR_LIGHTMAGENTA}}})
 table.insert(attributes, {text = {
                                   {text=center('',19),width=19},
                                   {text='Current',rjustify=true,width=9,pen=COLOR_WHITE},
                                   {text='Class',rjustify=true,width=7,pen=COLOR_WHITE},
                                   {text='Item',rjustify=true,width=6,pen=COLOR_WHITE},
                                   {text='Syndrome',rjustify=true,width=10,pen=COLOR_WHITE},
                                   {text='Base',rjustify=true,width=6,pen=COLOR_WHITE}
                                  }})
 ttt = 0
 for i,x in pairs(m_attributes) do
  if ttt == 1 then
   if m_attributes[i]['Current'] >= m_attributes[i]['Base'] then
    fgc = COLOR_LIGHTGREEN
   elseif m_attributes[i]['Current'] < m_attributes[i]['Base'] then
    fgc = COLOR_LIGHTRED
   end
   ttt = 0
  elseif ttt == 0 then
   if m_attributes[i]['Current'] >= m_attributes[i]['Base'] then
    fgc = COLOR_LIGHTGREEN
   elseif m_attributes[i]['Current'] < m_attributes[i]['Base'] then
    fgc = COLOR_LIGHTRED
   end
   ttt = 1
  end
  table.insert(attributes, {text = {
	                                {text = i, width = a_len,pen = fgc},
		                            {text = tostring(m_attributes[i]['Current']), rjustify=true,width=9,pen = fgc},
                                    {text = tostring(m_attributes[i]['Class']), rjustify=true,width=7,pen = fgc},
                                    {text = tostring(m_attributes[i]['Item']), rjustify=true,width=6,pen = fgc},
                                    {text = tostring(m_attributes[i]['Syndrome']), rjustify=true,width=10,pen = fgc},
                                    {text = tostring(m_attributes[i]['Base']), rjustify=true,width=6,pen = fgc}
                                   }})
 end
 local list = self.subviews.attributeViewDetailed
 list:setChoices(attributes)
end

function UnitViewUi:syndromeDetail(syndromes,details)
 detail = {}
 table.insert(detail, {
     text = {
	     {text=center('Active Syndromes',20), pen=COLOR_LIGHTCYAN},
		 {text=center('Start',6), pen=COLOR_LIGHTCYAN},
		 {text=center('Peak',6), pen=COLOR_LIGHTCYAN},
		 {text=center('Severity',10), pen=COLOR_LIGHTCYAN},
		 {text=center('End',6), pen=COLOR_LIGHTCYAN},
		 {text=center('Duration',10), pen=COLOR_LIGHTCYAN}
     }
   })
 for i,x in pairs(syndromes) do
  table.insert(detail, {
      text = {
	      {text = x[1],width = 20,pen=fgc}
      }
  })
  for j,y in pairs(details[i]) do
   if pcall(function() return y.sev end) then
    severity = y.sev
   else
    severity = 'NA'
   end
   effect = split(split(tostring(y._type),'creature_interaction_effect_')[2],'st>')[1]:gsub("(%a)([%w_']*)", tchelper)
   if y['end'] == -1 then
    ending = 'Permanent'
	duration = x[3]
   else
    ending = y['end']
    duration = x[3]
   end
   if y.start-x[3] <0 then
--    starting = 0
	startcolor = COLOR_LIGHTGREEN
   else
--    starting = y.start-x[3]
	startcolor = COLOR_LIGHTRED
   end
   if y.peak-x[3] <0 then
--    starting = 0
	peakcolor = COLOR_LIGHTGREEN
   else
--    starting = y.peak-x[3]
	peakcolor = COLOR_LIGHTRED
   end
   if y['end']-x[3] <0 then
	endcolor = COLOR_LIGHTGREEN
   else
	endcolor = COLOR_LIGHTRED
   end
   table.insert(detail, {
       text = {
	       {text = "    "..effect, width = 20,pen=COLOR_WHITE},
		   {text = y.start, rjustify=true,width = 6,pen=startcolor},
		   {text = y.peak, rjustify=true,width = 6,pen=peakcolor},
		   {text = severity, rjustify=true,width = 10,pen=COLOR_WHITE},
		   {text = ending, rjustify=true,width = 6,pen=endcolor},
		   {text = duration, rjustify=true,width = 10,pen=COLOR_WHITE}
           
       }
   })
  end
 end
 local list = self.subviews.syndromeViewDetailed
 list:setChoices(detail)
end

function UnitViewUi:classDetail(tar)
 input = {}
 in2 = {}
 table.insert(in2,{text = {{text=center('Classes',60),width=60,pen=COLOR_LIGHTCYAN}}})
 table.insert(in2,{text = {
                             {text='Class',width=41,pen=COLOR_LIGHTMAGENTA},
                             {text='Level',width=7,rjustify=true,pen=COLOR_LIGHTMAGENTA},
                             {text='Experience',width=12,rjustify=true,pen=COLOR_LIGHTMAGENTA},
                            }})
 local persistTable = require 'persist-table'
 if persistTable.GlobalTable.roses then
  if persistTable.GlobalTable.roses.ClassTable then
   classTable = persistTable.GlobalTable.roses.ClassTable
   unitTable = persistTable.GlobalTable.roses.UnitTable
   if not unitTable[tostring(tar.id)] then
    dfhack.script_environment('functions/tables').makeUnitTable(tar.id)
   end
   unitClasses = unitTable[tostring(tar.id)].Classes
   for i,x in pairs(classTable._children) do
    table.insert(input,{text = {
                                {text=classTable[x].Name,width=41},
                                {text=tostring(unitClasses[x].Level),width=7,rjustify=true},
                                {text=tostring(unitClasses[x].Experience),width=12,rjustify=true},
                               }})
   end
  else
   table.insert(in2,{text = {{text='No Class Table Loaded',width=22,pen=COLOR_WHITE}}})
  end
 else
  table.insert(in2,{text = {{text='No Class Table Loaded',width=22,pen=COLOR_WHITE}}})
 end 
 local list = self.subviews.classViewDetailedClasses
 list:setChoices(input)
 local list = self.subviews.classViewDetailedTop
 list:setChoices(in2)
end

function UnitViewUi:checkClass(index,choice)
 if not choice then return end
 input = {}
 local name = choice.text[1].text
 local persistTable = require 'persist-table'
 local classTable = persistTable.GlobalTable.roses.ClassTable
 local unitClasses = persistTable.GlobalTable.roses.UnitTable[tostring(target.id)].Classes
 local unitSpells  = persistTable.GlobalTable.roses.UnitTable[tostring(target.id)].Spells
 for _,x in pairs(classTable._children) do
  if classTable[x].Name == name then
   class = x
   break
  end
 end
 local currentClass = unitClasses.Current.Name
 if currentClass == 'NONE' then
  currentName = 'None'
 else
  currentName = classTable[currentClass].Name
 end
 for _,x in pairs(classTable._children) do
  if classTable[x].Name == unitClasses.Current.Name then
   currentClass = x
   break
  end
 end
 if not class then return end
 table.insert(input,{text = {{text='Current Class = '..currentName,width=30,pen=COLOR_WHITE}}})
 table.insert(input,{text = {{text=center(name,60),width=60,pen=COLOR_LIGHTCYAN}}})
 table.insert(input,{text = {{text='Requirements:',width=30,pen=COLOR_LIGHTMAGENTA}}})
 table.insert(input,{text = {{text='Classes:',width=30,pen=COLOR_YELLOW}}})
 test = true
 for _,x in pairs(classTable[class].RequiredClass._children) do
  local check = unitClasses[x].Level
  local level = classTable[class].RequiredClass[x]
  if tonumber(check) < tonumber(level) then
   fgc = COLOR_LIGHTRED
  else
   fgc = COLOR_LIGHTGREEN
  end
  table.insert(input,{text = {{text='Level '..classTable[class].RequiredClass[x]..' '..classTable[x].Name,width=30,pen=fgc}}})
  test = false
 end
 if test then table.insert(input,{text = {{text='None',width=30,pen=COLOR_LIGHTGREEN}}}) end
 table.insert(input,{text = {{text='Attributes:',width=30,pen=COLOR_YELLOW}}})
 local test = true
 for _,x in pairs(classTable[class].RequiredPhysical._children) do
  local total,base,change,classval,syndrome = dfhack.script_environment('functions/unit').trackAttribute(target,x,0,0,0,0,'get')
  local check = total-change-classval-syndrome
  local value = classTable[class].RequiredPhysical[x]
  if tonumber(check) < tonumber(value) then
   fgc = COLOR_LIGHTRED
  else
   fgc = COLOR_LIGHTGREEN
  end
  table.insert(input,{text = {{text=classTable[class].RequiredPhysical[x]..' '..x,width=30,pen=fgc}}})
  test = false
 end
 for _,x in pairs(classTable[class].RequiredMental._children) do
  local total,base,change,classval,syndrome = dfhack.script_environment('functions/unit').trackAttribute(target,x,0,0,0,0,'get')
  local check = total-change-classval-syndrome
  local value = classTable[class].RequiredMental[x]
  if tonumber(check) < tonumber(value) then
   fgc = COLOR_LIGHTRED
  else
   fgc = COLOR_LIGHTGREEN
  end
  table.insert(input,{text = {{text=classTable[class].RequiredMental[x]..' '..x,width=30,pen=fgc}}})
  test = false
 end
 if test then table.insert(input,{text = {{text='None',width=40,pen=COLOR_LIGHTGREEN}}}) end
 table.insert(input,{text = {{text='Skills:',width=40,pen=COLOR_YELLOW}}})
 local test = true
 for _,x in pairs(classTable[class].RequiredSkill._children) do
  local total,base,change,classval,syndrome = dfhack.script_environment('functions/unit').trackSkill(target,x,0,0,0,0,'get')
  local check = total-change-classval-syndrome
  local value = classTable[class].RequiredSkill[x]
  if tonumber(check) < tonumber(value) then
   fgc = COLOR_LIGHTRED
  else
   fgc = COLOR_LIGHTGREEN
  end
  table.insert(input,{text = {{text='Level '..classTable[class].RequiredSkill[x]..' '..x.Name,width=30,pen=fgc}}})
  test = false
 end
 if test then table.insert(input,{text = {{text='None',width=40,pen=COLOR_LIGHTGREEN}}}) end
 table.insert(input,{text = {{text='Traits:',width=40,pen=COLOR_YELLOW}}})
 local test = true
 for _,x in pairs(classTable[class].RequiredTrait._children) do
  local total,base,change,classval,syndrome = dfhack.script_environment('functions/unit').trackTrait(target,x,0,0,0,0,'get')
  local check = total-change-classval-syndrome
  local value = classTable[class].RequiredTrait[x]
  if tonumber(check) < tonumber(value) then
   fgc = COLOR_LIGHTRED
  else
   fgc = COLOR_LIGHTGREEN
  end
  table.insert(input,{text = {{text=classTable[class].RequiredTrait[x]..' '..x,width=30,pen=fgc}}})
  test = false
 end
 if test then table.insert(input,{text = {{text='None',width=40,pen=COLOR_LIGHTGREEN}}}) end
 table.insert(input,{text = {{text='',width=40,pen=COLOR_WHITE}}})
 table.insert(input,{text = {{text='Attribute Changes:',width=40,pen=COLOR_LIGHTMAGENTA}}})
 local test = true
 current = {}
 if currentClass and currentClass ~= 'NONE' then
  for _,x in pairs(classTable[currentClass].BonusPhysical._children) do
   current[x] = classTable[currentClass].BonusPhysical[x][tostring(unitClasses[currentClass].Level+1)]
  end
  for _,x in pairs(classTable[currentClass].BonusMental._children) do
   current[x] = classTable[currentClass].BonusMental[x][tostring(unitClasses[currentClass].Level+1)]
  end
 end
 nextto = {}
 for _,x in pairs(classTable[class].BonusPhysical._children) do
  nextto[x] = classTable[class].BonusPhysical[x][tostring(unitClasses[class].Level+1)]
 end
 for _,x in pairs(classTable[class].BonusMental._children) do
  nextto[x] = classTable[class].BonusMental[x][tostring(unitClasses[class].Level+1)]
 end
 new = {}
 for str,val in pairs(current) do
  new[str] = -tonumber(val)
 end
 for str,val in pairs(nextto) do
  if new[str] then
   new[str] = new[str] + tonumber(val)
  else
   new[str] = tonumber(val)
  end
 end
 for str,val in pairs(new) do
  if val > 0 then 
   fgc = COLOR_LIGHTGREEN
   val = '+'..tostring(val)
  elseif val < 0 then 
   fgc = COLOR_LIGHTRED
   val = tostring(val)
  elseif val == 0 then 
   fgc = COLOR_WHITE 
   val = tostring(val)
  end
  table.insert(input,{text = {
                              {text=str,width=20,pen=fgc},
                              {text=val,width=10,rjustify=true,pen=fgc}
                             }})
  test = false
 end
 if test then table.insert(input,{text = {{text='None',width=40,pen=COLOR_WHITE}}}) end
 
 table.insert(input,{text = {{text='Skill Changes:',width=40,pen=COLOR_LIGHTMAGENTA}}})
 local test = true
 current = {}
 if currentClass and currentClass ~= 'NONE' then
  for _,x in pairs(classTable[currentClass].BonusSkill._children) do
   current[x] = classTable[currentClass].BonusSkill[x][tostring(unitClasses[currentClass].Level+1)]
  end
 end
 nextto = {}
 for _,x in pairs(classTable[class].BonusSkill._children) do
  nextto[x] = classTable[class].BonusSkill[x][tostring(unitClasses[class].Level+1)]
 end
 new = {}
 for str,val in pairs(current) do
  new[str] = -tonumber(val)
 end
 for str,val in pairs(nextto) do
  if new[str] then
   new[str] = new[str] + tonumber(val)
  else
   new[str] = tonumber(val)
  end
 end
 for str,val in pairs(new) do
  if val > 0 then 
   fgc = COLOR_LIGHTGREEN
   val = '+'..tostring(val)
  elseif val < 0 then 
   fgc = COLOR_LIGHTRED
   val = tostring(val)
  elseif val == 0 then 
   fgc = COLOR_WHITE 
   val = tostring(val)
  end
  table.insert(input,{text = {
                              {text=str,width=20,pen=fgc},
                              {text=val,width=10,rjustify=true,pen=fgc}
                             }})
  test = false
 end
 if test then table.insert(input,{text = {{text='None',width=40,pen=COLOR_WHITE}}}) end 

 table.insert(input,{text = {{text='Trait Changes:',width=40,pen=COLOR_LIGHTMAGENTA}}})
 local test = true
 current = {}
 if currentClass and currentClass ~= 'NONE' then
  for _,x in pairs(classTable[currentClass].BonusTrait._children) do
   current[x] = classTable[currentClass].BonusTrait[x][tostring(unitClasses[currentClass].Level+1)]
  end
 end
 nextto = {}
 for _,x in pairs(classTable[class].BonusTrait._children) do
  nextto[x] = classTable[class].BonusTrait[x][tostring(unitClasses[class].Level+1)]
 end
 new = {}
 for str,val in pairs(current) do
  new[str] = -tonumber(val)
 end
 for str,val in pairs(nextto) do
  if new[str] then
   new[str] = new[str] + tonumber(val)
  else
   new[str] = tonumber(val)
  end
 end
 for str,val in pairs(new) do
  if val > 0 then 
   fgc = COLOR_LIGHTGREEN
   val = '+'..tostring(val)
  elseif val < 0 then 
   fgc = COLOR_LIGHTRED
   val = tostring(val)
  elseif val == 0 then 
   fgc = COLOR_WHITE 
   val = tostring(val)
  end
  table.insert(input,{text = {
                              {text=str,width=20,pen=fgc},
                              {text=val,width=10,rjustify=true,pen=fgc}
                             }})
  test = false
 end
 if test then table.insert(input,{text = {{text='None',width=40,pen=COLOR_WHITE}}}) end
 
 input2 = {}
 
 table.insert(input2,{text = {{text='Leveling Bonuses:',width=40,pen=COLOR_LIGHTMAGENTA}}})
 test = true
 table.insert(input2,{text = {{text='Attributes:',width=40,pen=COLOR_YELLOW}}})
 for _,x in pairs(classTable[class].LevelBonus.Physical._children) do
  table.insert(input2,{text = {
                               {text=x,width=20,pen=COLOR_WHITE},
                               {text=classTable[class].LevelBonus.Physical[x],width=10,rjustify=true,pen=COLOR_WHITE}
                              }})
  test=false
 end
 for _,x in pairs(classTable[class].LevelBonus.Mental._children) do
  table.insert(input2,{text = {
                               {text=x,width=20,pen=COLOR_WHITE},
                               {text=classTable[class].LevelBonus.Mental[x],width=10,rjustify=true,pen=COLOR_WHITE}
                              }})
  test=false
 end
 if test then table.insert(input2,{text = {{text='None',width=40,pen=COLOR_WHITE}}}) end
 test = true
 table.insert(input2,{text = {{text='Skills:',width=40,pen=COLOR_YELLOW}}})
 for _,x in pairs(classTable[class].LevelBonus.Skill._children) do
  table.insert(input2,{text = {
                               {text=x,width=20,pen=COLOR_WHITE},
                               {text=classTable[class].LevelBonus.Skill[x],width=10,rjustify=true,pen=COLOR_WHITE}
                              }})
  test=false
 end
 if test then table.insert(input2,{text = {{text='None',width=40,pen=COLOR_WHITE}}}) end
 test = true
 table.insert(input2,{text = {{text='Traits:',width=40,pen=COLOR_YELLOW}}})
 for _,x in pairs(classTable[class].LevelBonus.Trait._children) do
  table.insert(input2,{text = {
                               {text=x,width=20,pen=COLOR_WHITE},
                               {text=classTable[class].LevelBonus.Trait[x],width=10,rjustify=true,pen=COLOR_WHITE}
                              }})
  test=false
 end
 if test then table.insert(input2,{text = {{text='None',width=40,pen=COLOR_WHITE}}}) end
 table.insert(input,{text = {{text='',width=40,pen=COLOR_WHITE}}})
 table.insert(input2,{text = {{text='Spells and Abilities:',width=40,pen=COLOR_LIGHTMAGENTA}}})
 test = true
 for _,x in pairs(classTable[class].Spells._children) do
  if unitSpells[x] == '1' then
   fgc = COLOR_WHITE
  else
   fgc = COLOR_GREY
  end
  if persistTable.GlobalTable.roses.SpellTable[x] then
   name = persistTable.GlobalTable.roses.SpellTable[x].Name
  else
   name = 'Unknown'
  end
  table.insert(input2,{text = {{text=name,width=40,pen=fgc}}})
  test = false
 end
 if test then table.insert(input2,{text = {{text='None',width=40,pen=COLOR_WHITE}}}) end
 
 local list = self.subviews.classViewDetailedDetails1
 list:setChoices(input)
 local list2 = self.subviews.classViewDetailedDetails2
 list2:setChoices(input2)
end

function UnitViewUi:insertDescriptionAppearance(desc)
 insert = {}
 w_frame = self.subviews.physical_desc.frame.w
 table.insert(insert,{text = { {text = center('Appearance',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 local list = self.subviews.physical_desc
 list:setChoices(insert)
end

function UnitViewUi:insertDescriptionAttribute(desc1,desc2)
 insert = {}
 w_frame = self.subviews.attribute_description.frame.w
 table.insert(insert,{text = { {text = center('Attributes',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc1,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 temp_split = split(desc2,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 local list = self.subviews.attribute_description
 list:setChoices(insert)
end

function UnitViewUi:insertDescriptionBasicHealth(desc,syndromes)
 insert = {}
 w_frame = self.subviews.basic_health.frame.w
 table.insert(insert,{text = { {text = center('Health',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end 
 table.insert(insert, {
     text = {
	     {text=center('Active Syndromes',w_frame), width = w_frame,pen=COLOR_LIGHTCYAN}
     }
   })
 fgc = COLOR_GREY
 for i,x in pairs(syndromes) do
  if fgc == COLOR_WHITE then
   fgc = COLOR_GREY
  elseif fgc == COLOR_GREY then
   fgc = COLOR_WHITE
  end
  table.insert(insert, {
      text = {
	      {text = x[1],width = y1,pen=fgc},
		  {text = x[3],width = y2,rjustify=true,pen=fgc}
      }
  })
 end
 local list = self.subviews.basic_health
 list:setChoices(insert)
end

function UnitViewUi:insertDescriptionCreature(desc)
 insert = {}
 w_frame = self.subviews.creature_description.frame.w
 table.insert(insert,{text = { {text = center('Creature Description',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 local list = self.subviews.creature_description
 list:setChoices(insert)
end

function UnitViewUi:insertDescriptionEmotion(desc)
 insert = {}
 w_frame = self.subviews.emotions.frame.w
 table.insert(insert,{text = { {text = center('Thougths and Feelings',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 local list = self.subviews.emotions
 list:setChoices(insert)
end

function UnitViewUi:insertDescriptionMembership(desc1,desc2)
 insert = {}
 w_frame = self.subviews.membership_and_worship.frame.w
 table.insert(insert,{text = { {text = center('Membership',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc1,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 table.insert(insert,{text = { {text = center('Worship',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc2,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 local list = self.subviews.membership_and_worship
 list:setChoices(insert)
end

function UnitViewUi:insertDescriptionPersonality(desc1,desc2,desc3)
 insert = {}
 w_frame = self.subviews.thoughts_and_preferences.frame.w
 table.insert(insert,{text = { {text = center('Preferences',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc1,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 table.insert(insert,{text = { {text = center('Traits',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc2,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 table.insert(insert,{text = { {text = center('Values',w_frame),width = w_frame,pen=COLOR_LIGHTCYAN}}})
 temp_split = split(desc3,'\n')
 for _,x in pairs(temp_split) do
  table.insert(insert,{text = { {text = x,width=w_frame,pen=COLOR_WHITE}}})
 end
 local list = self.subviews.thoughts_and_preferences
 list:setChoices(insert)
end

function UnitViewUi:insertSkills(skills)
 skill = {}
 w_frame = self.subviews.skills.frame.w
 misc_skl = {}
 blue_collar_skl = Set {"MINING","WOODCUTTING","CARPENTRY","DETAILSTONE","MASONRY","ANIMALTRAIN","ANIMALCARE",
                    "DISSECT_FISH","DISSECT_VERMIN","PROCESSFISH","BUTCHER","TRAPPING","TANNER","WEAVING",
					"BREWING,ALCHEMY","CLOTHESMAKING","MILLING","PROCESSPLANTS","CHEESEMAKING","MILK","COOK",
					"PLANT,HERBALISM","FISH","SMELT","EXTRACT_STRAND","FORGE_WEAPON","FORGE_ARMOR",
					"FORGE_FURNITURE","CUTGEM","ENCRUSTGEM","WOODCRAFT","STONECRAFT","METALCRAFT","GLASSMAKER",
					"LEATHERWORK","BONECARVE","SIEGECRAFT","BOWYER","MECHANICS","WOOD_BURNING","LYE_MAKING",
					"SOAP_MAKING","POTASH_MAKING","DYER","OPERATE_PUMP","KNAPPING","SHEARING","SPINNING","POTTERY",
					"GLAZING","PRESSING","BEEKEEPING","WAX_WORKING"
				   }
 white_collar_skl = Set {"APPRAISAL","TEACHING","DESIGNBUILDING","ORGANIZATION","RECORD_KEEPING","WRITING",
                     "PROSE","POETRY","READING","SPEAKING","LEADERSHIP","TEACHING"
					}
 social_skl = Set {"COMEDY","CONSOLE","CONVERSATION","FLATTERY","INTIMIDATION","JUDGING_INTENT",
             "LYING","NEGOTIATION","PACIFY","PERSUASION"
			}
 personal_skl = Set {"KNOWLEDGE_ACQUISITION","CONCENTRATION","DISCIPLINE","SITUATIONAL_AWARENESS","COORDINATION",
                 "BALANCE","MAGIC_NATURE","SWIMMING"
			    }
 military_skl = Set {"ARMOR","AXE","BITE","BLOWGUN","BOW","CROSSBOW","DAGGER","DODGING","GRASP_STRIKE","HAMMER",
             "MACE","MELEE_COMBAT","MILITARY_TACTICS","MISC_WEAPON","PIKE","RANGED_COMBAT","SHIELD","SNEAK",
			 "SIEGEOPERATE","SPEAR","STANCE_STRIKE","SWORD","THROW","TRACKING","WHIP","WRESTLING"
			}
 medical_skl = Set {"CRUTCH_WALK","DIAGNOSE","DRESS_WOUNDS","SET_BONE","SURGERY","SUTURE"}
 table.insert(skill, {
     text = {
	     {text=center('Skills',w_frame), width = w_frame,pen=COLOR_LIGHTCYAN}
     }
   })
 fgc = COLOR_GREY
 --Check Blue Collar Skills
 local check = true
 for i,x in pairs(skills) do
  if blue_collar_skl[x[3]] then
   if check then
    table.insert(skill, {
     text = {
	     {text=center('Blue Collar',w_frame), width = w_frame,pen=COLOR_LIGHTMAGENTA}
     }
    })
   end
   if fgc == COLOR_WHITE then
    fgc = COLOR_GREY
   elseif fgc == COLOR_GREY then
    fgc = COLOR_WHITE
   end
   table.insert(skill, {
       text = {
	       {text = i,width = s1+1,pen=fgc},
	 	   {text=x[1]..'('..tostring(df.skill_rating[x[1]])..')',rjustify=true,width=s2+5,pen=fgc},
	 	   {text=tostring(x[2]),rjustify=true,width=s3+1,pen=fgc}
       }
   })
   check = false
  end
 end
 fgc = COLOR_GREY
 --Check White Collar Skills
 check = true
 for i,x in pairs(skills) do
  if white_collar_skl[x[3]] then
   if check then
    table.insert(skill, {
     text = {
		 {text=center('White Collar',w_frame), width = w_frame,pen=COLOR_LIGHTMAGENTA}
     }
    })
   end
   if fgc == COLOR_WHITE then
    fgc = COLOR_GREY
   elseif fgc == COLOR_GREY then
    fgc = COLOR_WHITE
   end
   table.insert(skill, {
       text = {
	       {text = i,width = s1+1,pen=fgc},
	 	   {text=x[1]..'('..tostring(df.skill_rating[x[1]])..')',rjustify=true,width=s2+5,pen=fgc},
	 	   {text=tostring(x[2]),rjustify=true,width=s3+1,pen=fgc}
       }
   })
   check = false
  end
 end
 fgc = COLOR_GREY
 --Check Social Skills
 check = true
 for i,x in pairs(skills) do
  if social_skl[x[3]] then
   if check then
    table.insert(skill, {
     text = {
		 {text=center('Social',w_frame), width = w_frame,pen=COLOR_LIGHTMAGENTA}
     }
    })
   end
   if fgc == COLOR_WHITE then
    fgc = COLOR_GREY
   elseif fgc == COLOR_GREY then
    fgc = COLOR_WHITE
   end
   table.insert(skill, {
       text = {
	       {text = i,width = s1+1,pen=fgc},
	 	   {text=x[1]..'('..tostring(df.skill_rating[x[1]])..')',rjustify=true,width=s2+5,pen=fgc},
	 	   {text=tostring(x[2]),rjustify=true,width=s3+1,pen=fgc}
       }
   })
   check = false
  end
 end
 fgc = COLOR_GREY
 --Check Personal Skills
 check = true
 for i,x in pairs(skills) do
  if personal_skl[x[3]] then
   if check then
    table.insert(skill, {
     text = {
		 {text=center('Personal',w_frame), width = w_frame,pen=COLOR_LIGHTMAGENTA}
     }
    })
   end
   if fgc == COLOR_WHITE then
    fgc = COLOR_GREY
   elseif fgc == COLOR_GREY then
    fgc = COLOR_WHITE
   end
   table.insert(skill, {
       text = {
	       {text = i,width = s1+1,pen=fgc},
	 	   {text=x[1]..'('..tostring(df.skill_rating[x[1]])..')',rjustify=true,width=s2+5,pen=fgc},
	 	   {text=tostring(x[2]),rjustify=true,width=s3+1,pen=fgc}
       }
   })
   check = false
  end
 end
 fgc = COLOR_GREY
 --Check Military Skills
 check = true
 for i,x in pairs(skills) do
  if military_skl[x[3]] then
   if check then
    table.insert(skill, {
     text = {
		 {text=center('Military',w_frame), width = w_frame,pen=COLOR_LIGHTMAGENTA}
     }
    })
   end
   if fgc == COLOR_WHITE then
    fgc = COLOR_GREY
   elseif fgc == COLOR_GREY then
    fgc = COLOR_WHITE
   end
   table.insert(skill, {
       text = {
	       {text = i,width = s1+1,pen=fgc},
	 	   {text=x[1]..'('..tostring(df.skill_rating[x[1]])..')',rjustify=true,width=s2+5,pen=fgc},
	 	   {text=tostring(x[2]),rjustify=true,width=s3+1,pen=fgc}
       }
   })
   check = false
  end
 end
 fgc = COLOR_GREY
 --Check Medical Skills
 check = true
 for i,x in pairs(skills) do
  if medical_skl[x[3]] then
   if check then
    table.insert(skill, {
     text = {
		 {text=center('Medical',w_frame), width = w_frame,pen=COLOR_LIGHTMAGENTA}
     }
    })
   end
   if fgc == COLOR_WHITE then
    fgc = COLOR_GREY
   elseif fgc == COLOR_GREY then
    fgc = COLOR_WHITE
   end
   table.insert(skill, {
       text = {
	       {text = i,width = s1+1,pen=fgc},
	 	   {text=x[1]..'('..tostring(df.skill_rating[x[1]])..')',rjustify=true,width=s2+5,pen=fgc},
	 	   {text=tostring(x[2]),rjustify=true,width=s3+1,pen=fgc}
       }
   })
   check = false
  end
 end
 local list = self.subviews.skills
 list:setChoices(skill)
end

function UnitViewUi:onInput(keys)
 if keys.LEAVESCREEN then
  if self.subviews.interactionView.visible then
   self.subviews.interactionView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.syndromeView.visible then
   self.subviews.syndromeView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.attributeView.visible then
   self.subviews.attributeView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.classView.visible then
   self.subviews.classView.visible = false
   self.subviews.classView2.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.equipmentView then
   self.subviews.equipmentView = false
   self.subviews.main.visible = true
  elseif self.subviews.interactionView.visible then
   self.subviews.interactionView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.syndromeView.visible then
   self.subviews.syndromeView.visible = false
   self.subviews.main.visible = true
  elseif self.subviews.spellbookView.visible then
   self.subviews.spellbookView.visible = false
   self.subviews.main.visible = true  
  else
   self:dismiss()
  end
 else
  UnitViewUi.super.onInput(self, keys)
 end
end

function UnitViewUi:onResize()
 self:dismiss()
 local screen = UnitViewUi{target=getTargetFromScreens()}
 screen:show()
end

function show_editor(trg)
 local screen = UnitViewUi{target=trg}
 screen:show()
end

show_editor(getTargetFromScreens())
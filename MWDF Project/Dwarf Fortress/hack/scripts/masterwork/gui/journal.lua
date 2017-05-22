local gui = require 'gui'
local dialog = require 'gui.dialogs'
local widgets =require 'gui.widgets'
local guiScript = require 'gui.script'
local utils = require 'utils'
local split = utils.split_string

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

JournalUi = defclass(JournalUi, gui.FramedScreen)
JournalUi.ATTRS={
                  frame_style = gui.BOUNDARY_FRAME,
                  frame_title = "Journal",
	             }

function JournalUi:init()
-- Create frames
-- Creature Detail Frames
 self:addviews{
       widgets.Panel{
       view_id = 'creatureView',
       frame = { l = 0, r = 0},
       frame_inset = 1,
       subviews = {
                widgets.Label{
         view_id = 'creatureBottom',
         frame = {t=1,l=1},
         text ={{text=": Buildings ",key = "CUSTOM_SHIFT_B",on_activate=self:callback('building')},
                NEWLINE,
                {text=": Creatures ",key = "CUSTOM_SHIFT_C",on_activate=self:callback('creature')},
                NEWLINE,
                {text=": Food ",key = "CUSTOM_SHIFT_F",on_activate=self:callback('food')},
                NEWLINE,
                {text=": Items ",key = "CUSTOM_SHIFT_I",on_activate=self:callback('item')},
                NEWLINE,
                {text=": Inorganics ",key = "CUSTOM_SHIFT_N",on_activate=self:callback('inorganic')},
                NEWLINE,
                {text=": Organics ",key = "CUSTOM_SHIFT_O",on_activate=self:callback('organic')},
                NEWLINE,
                {text=": Plants ",key = "CUSTOM_SHIFT_P",on_activate=self:callback('plant')},
                NEWLINE,
                {text=": Reactions ",key = "CUSTOM_SHIFT_R",on_activate=self:callback('reaction')},
                NEWLINE,
                {text= ": Exit ",key= "LEAVESCREEN",} 
               }
                },
                }
            }
        }
end

function JournalUi:creature()
 dfhack.run_command('gui/journal-details Creatures')
end
function JournalUi:plant()
 dfhack.run_command('gui/journal-details Plants')
end
function JournalUi:food()
 dfhack.run_command('gui/journal-details Food')
end
function JournalUi:item()
 dfhack.run_command('gui/journal-details Items')
end
function JournalUi:inorganic()
 dfhack.run_command('gui/journal-details Inorganics')
end
function JournalUi:organic()
 dfhack.run_command('gui/journal-details Organics')
end
function JournalUi:building()
 dfhack.run_command('gui/journal-details Buildings')
end
function JournalUi:reaction()
 dfhack.run_command('gui/journal-details Reactions')
end

function JournalUi:onInput(keys)
 if keys.LEAVESCREEN then
  self:dismiss()
 end

 self.super.onInput(self,keys)
end

local screen = JournalUi{}
screen:show()

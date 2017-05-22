local utils=require 'utils'
local gui = require 'gui'
 
validArgs = --[[validArgs or]]utils.invert({
  'help',
  'unit',
  'corpse',
  'location',
  'kill',
})

local args = utils.processArgs({...}, validArgs)
if args.help then
  print('')
  return
end

corpse = nil
if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
 if not unit then return end
 if unit.flags1.dead then
  for _,id in pairs(unit.corpse_parts) do
   item = df.item.find(id)
   if df.item_corpsest:is_instance(item) and not item.body.components.body_part_status[0].missing and item.corpse_flags.unbutchered then
    corpse = item
    break
   end
  end
 else
  if args.kill then
   unit.body.blood_count = 0
   dfhack.timeout(1,'ticks',function () dfhack.run_command('butcher -unit '..tostring(unit.id)) end)
   return
  else
   print('Unit is still alive and has not been ordered -kill')
  end
 end
elseif args.corpse and tonumber(args.corpse) then
 item = df.item.find(tonumber(args.corpse))
 if not item then return end
 if df.item_corpsest:is_instance(item) then
  if not item.body.components.body_part_status[0].missing and item.corpse_flags.unbutchered then
   corpse = item
  end
 end
elseif args.location then
 locx = tonumber(args.location[1])
 locy = tonumber(args.location[2])
 locz = tonumber(args.location[3])
 block = dfhack.maps.ensureTileBlock(locx,locy,locz)
 if block.occupancy[locx%16][locy%16].item then
  for _,id in pairs(block.items) do
   item = df.item.find(id)
   if df.item_corpsest:is_instance(item) then
    if item.pos.x == locx and item.pos.y == locy and item.pos.z == locz then
     if not item.body.components.body_part_status[0].missing and item.corpse_flags.unbutchered then
      corpse = item
      break
     end
    end
   end
  end
 end
end
if not corpse then return end

local view_x = df.global.window_x
local view_y = df.global.window_y
local view_z = df.global.window_z
local curViewscreen = dfhack.gui.getCurViewscreen()
local dwarfmodeScreen = df.viewscreen_dwarfmodest:new()
curViewscreen.child = dwarfmodeScreen
dwarfmodeScreen.parent = curViewscreen
local oldMode = df.global.ui.main.mode
df.global.ui.main.mode = df.ui_sidebar_mode.LookAround
local old_gametype = df.global.gametype
df.global.gametype = df.game_type.DWARF_ARENA

df.global.cursor.x = corpse.pos.x
df.global.cursor.y = corpse.pos.y
df.global.cursor.z = corpse.pos.z
for i,_ in pairs(df.global.ui_look_list.items) do
 df.global.ui_look_cursor = i
 if dfhack.gui.getCurFocus() == 'dwarfmode/LookAround/Item' then
  if corpse.id == dfhack.gui.getSelectedItem().id then
   break
  end
 end
end
gui.simulateInput(dfhack.gui.getCurViewscreen(), 'D_LOOK_ARENA_ADV_MODE')

df.global.gametype = old_gametype
curViewscreen.child = nil
dwarfmodeScreen:delete()
df.global.ui.main.mode = oldMode

df.global.window_x = view_x
df.global.window_y = view_y
df.global.window_z = view_z

--unit/action-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'timer',
 'action',
 'interaction',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/action-change
  Change the action timer of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -action Action Type
     Valid Types:
      All
      Move
      Attack
   -interaction Interaction Type
     Valid Types:
      All
      Innate
      Learned
      INTERACTION_ID
   -timer #
     what to set the timer of the action to
     lower values mean the unit will be able to act again sooner
     Special Token:
      clear (erases all actions of the valid action type)
      clearAll (erases all actions regardless of action type)   
  examples:
   unit/action-change -unit \\UNIT_ID -action All -timer 200
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

if args.timer and tonumber(args.timer) then
 timer = tonumber(args.timer)
elseif args.timer == 'clear' then
 timer = 'clear'
elseif args.timer == 'clearAll' then
 timer = 'clearAll'
else
 print('No timer set')
 return
end

if args.action == 'All' then
 for i = 0,19 do
  dfhack.script_environment('functions/unit').changeAction(unit,df.unit_action_type[i],timer)
 end
elseif args.action then
 dfhack.script_environment('functions/unit').changeAction(unit,args.action,timer)
end

if args.interaction == 'All' then
 for _,id in pairs(unit.curse.own_interaction) do
  dfhack.script_environment('functions/unit').changeInteraction(unit,id,timer,'Innate')
 end
 for _,id in pairs(unit.curse.interaction_id) do
  dfhack.script_environment('functions/unit').changeInteraction(unit,id,timer,'Learned')
 end
elseif args.interaction == 'Learned' then
 for _,id in pairs(unit.curse.interaction_id) do
  dfhack.script_environment('functions/unit').changeInteraction(unit,id,timer,'Learned')
 end
elseif args.interaction == 'Innate' then
 for _,id in pairs(unit.curse.own_interaction) do
  dfhack.script_environment('functions/unit').changeInteraction(unit,id,timer,'Innate')
 end
else
 for _,interaction in pairs(df.global.world.raws.interactions) do
  if interaction.name == args.interaction then
   dfhack.script_environment('functions/unit').changeInteraction(unit,interaction.id,timer,'Both')
   return
  end
 end
end
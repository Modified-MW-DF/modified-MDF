--unit/attack.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'defender',
 'attacker',
 'target',
 'attack',
 'velocity',
 'hitchance',
 'weapon',
 'delay',
 'number',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/attack
 ]])
 return
end

if args.defender and tonumber(args.defender) then
 defender = df.unit.find(tonumber(args.defender))
else
 print('No defender selected')
 return
end
if args.attacker and tonumber(args.attacker) then
 attacker = df.unit.find(tonumber(args.attacker))
else
 print('No attacker selected')
 return
end

attack = nil
target = nil
delay = tonumber(args.delay) or 1
number = tonumber(args.number) or 1
hitchance = tonumber(args.hitchance) or 100

if not args.target then
 target = dfhack.script_environment('functions/unit').checkBodyRandom(defender)
else
 target = dfhack.script_environment('functions/unit').checkBodyCategory(defender,args.target)[1]
end
 
if not target then
 print('No appropriate target found')
 return
end
 
if args.weapon then
 attack_id = -1
 local item = nil
 args.weapon = 'Equipped'
 if args.weapon == 'Equipped' then
  item = dfhack.script_environment('functions/unit').checkInventoryType(attacker,'WEAPON')[1]
  if not item then
   print('No Equipped Weapon')
   return
  end
 end
 if not args.attack then
  attack = dfhack.script_environment('functions/item').checkAttack(item,'Random')
 else
  attack = dfhack.script_environment('functions/item').checkAttack(item,args.attack)
 end
 if not attack then
  print('No appropriate attack found')
  return
 end
 item_id = item.id
 if args.velocity then
  velocity = tonumber(args.velocity)
 else
  velocity = dfhack.script_environment('functions/attack').getAttackItemVelocity(attacker,item,attack)
 end
else
 item_id = -1 
 if not args.attack then
  attack = dfhack.script_environment('functions/unit').checkAttack(attacker,'Random')
 else
  attack = dfhack.script_environment('functions/unit').checkAttack(attacker,args.attack)
 end
 if not attack then
  print('No appropriate attack found')
  return
 end
 attack_id = attacker.body.body_plan.attacks[attack].body_part_idx[0]
 if args.velocity then
  velocity = tonumber(args.velocity)
 else
  velocity = dfhack.script_environment('functions/attack').getAttackUnitVelocity(attacker,attack)
 end
end

j = 0
while j < number do
 dfhack.script_environment('functions/attack').addAttack(attacker,defender.id,attack_id,target,item_id,attack,hitchance,velocity,delay)
 j = j + 1
end
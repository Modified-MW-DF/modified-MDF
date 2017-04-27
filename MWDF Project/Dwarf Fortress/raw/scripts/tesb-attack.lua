
-- Automatically generated, do not edit!
-- Source: addons:zip:The Earth Strikes Back!/tesb-attack.dfcom.lua

-- Automatically generated, do not edit!
-- Source: addons:zip:The Earth Strikes Back!/tesb-attack.dfcom.lua
-- Prototype of unit/attack.lua by Roses

--[[
Example uses:
unit/attack -attacker 0 -defender 1
unit/attack -attacker 0 -defender 1 -target UB
unit/attack -attacker 0 -defender 1 -attack PUNCH
unit/attack -attacker 0 -defender 1 -target RH -weapon Equipped
]]

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

if not args.target then
 local rand = dfhack.random.new()
 local totwght = 0
 local weights = {}
 weights[0] = 0
 local n = 1
 for _,targets in pairs(defender.body.body_plan.body_parts) do
  totwght = totwght + targets.relsize
  weights[n] = weights[n-1] + targets.relsize
  n = n + 1 
 end
 while not target do
  pick = rand:random(totwght)
  for i = 1,n do
   if pick >= weights[i-1] and pick < weights[i] then
    target = i-1
    break
   end
  end
  if defender.body.components.body_part_status[target].missing then target = nil end
 end
else
 for i,targets in pairs(defender.body.body_plan.body_parts) do
  if targets.token == args.target then
   target = i
   break
  end
 end
end
 
if not target then
 print('No appropriate target found')
 return
end
delay = args.delay or 1
number = args.number or 1
hitchance = args.hitchance or 100
 
if args.weapon then
 local item = nil
 if args.weapon == 'Equipped' then
  for _,items in pairs(attacker.inventory) do
   if items.mode == 1 then
    item = items.item
    break
   end
  end
  if not item then
   print('No Equipped Weapon')
   return
  end
 end
 if not args.attack then
  local rand = dfhack.random.new()
  local totwght = 0
  local weights = {}
  weights[0] = 0
  local n = 1
  for _,attacks in pairs(item.subtype.attacks) do
   totwght = totwght + 1
   weights[n] = weights[n-1] + 1
   n = n + 1 
  end
  pick = rand:random(totwght)
  for i = 1,n do
   if pick >= weights[i-1] and pick < weights[i] then
    attack = i-1
    vel_mod = item.subtype.attacks[attack].velocity_mult
    break
   end
  end
 else
  for i,attacks in pairs(item.subtype.attacks) do
   if attacks.verb_2nd == args.attack or attacks.verb_3rd == args.attack then
    attack = i
    vel_mod = item.subtype.attacks[attack].velocity_mult
    break
   end
  end
 end

 if not attack then
  print('No appropriate attack found')
  return
 end

 if args.velocity then
  velocity = tonumber(args.velocity)
 else
  material = dfhack.matinfo.decode(item.mat_type,item.mat_index).material
  weight = math.floor(item.subtype.size*material.solid_density/100000)
  weight_fraction = item.subtype.size*material.solid_density*10 - weight*1000000
  effweight=attacker.body.size_info.size_cur/100+weight*100+weight_fraction/10000
  velocity = attacker.body.size_info.size_base * dfhack.units.getPhysicalAttrValue(attacker,0) * vel_mod/1000/effweight/1000
  if velocity == 0 then velocity = 1 end
 end

 j = 0
 while j < number do
 action = df.unit_action:new()
 action.id = attacker.next_action_id
 attacker.next_action_id = attacker.next_action_id + 1

 action.type = 1
 attack_action = action.data.attack
 attack_action.target_unit_id = defender.id
 attack_action.attack_item_id = item.id
 attack_action.target_body_part_id = target
 attack_action.attack_body_part_id = -1
 attack_action.unk_30 = velocity
 attack_action.attack_id = attack
 attack_action.flags = 7

 attack_action.unk_28 = hitchance
 attack_action.unk_2c = 100
 attack_action.unk_38 = 100
 attack_action.unk_3c = 100
 attack_action.timer1 = delay
 attack_action.timer2 = delay
 for i,x in pairs(attack_action.unk_4) do
  attack_action.unk_4[i] = 7
 end
 attack_action.unk_4.wrestle_type = -1
 attacker.actions:insert('#',action)
 j = j + 1
 end
else
 if not args.attack then
  local rand = dfhack.random.new()
  local totwght = 0
  local weights = {}
  weights[0] = 0
  local n = 1
  for _,attacks in pairs(attacker.body.body_plan.attacks) do
   if attacks.flags.main then
    totwght = totwght + 100
    weights[n] = weights[n-1] + 100
   else
    totwght = totwght + 1
    weights[n] = weights[n-1] + 1
   end
   n = n + 1 
  end
  while not attack do
   pick = rand:random(totwght)
   for i = 1,n do
    if pick >= weights[i-1] and pick < weights[i] then
     attack = i-1
     vel_mod = attacker.body.body_plan.attacks[attack].velocity_modifier
     break
    end
   end
   if attacker.body.components.body_part_status[attacker.body.body_plan.attacks[attack].body_part_idx[0]].missing then attack = nil end
  end
 else
  for i,attacks in pairs(attacker.body.body_plan.attacks) do
   if attacks.name == args.attack then
    attack = i
    vel_mod = attacker.body.body_plan.attacks[attack].velocity_modifier
    break
   end
  end
 end

 if not attack then
  print('No appropriate attack found')
  return
 end
 
 if args.velocity then
  velocity = tonumber(args.velocity)
 else
  velocity = 100 * dfhack.units.getPhysicalAttrValue(attacker,0) / 1000 * vel_mod / 1000
 end

 j = 0
 while j < number do
 action = df.unit_action:new()
 action.id = attacker.next_action_id
 attacker.next_action_id = attacker.next_action_id + 1

 action.type = 1
 attack_action = action.data.attack
 attack_action.target_unit_id = defender.id
 attack_action.attack_item_id = -1
 attack_action.target_body_part_id = target
 attack_action.attack_body_part_id = attacker.body.body_plan.attacks[attack].body_part_idx[0]
 attack_action.attack_velocity = velocity
 attack_action.attack_id = attack
 attack_action.flags = 7

 attack_action.unk_28 = hitchance
 attack_action.unk_2c = 100
 attack_action.unk_38 = 100
 attack_action.attack_accuracy = 100
 attack_action.timer1 = delay
 attack_action.timer2 = delay
 for i,x in pairs(attack_action.unk_4) do
  attack_action.unk_4[i] = 7
 end
 attack_action.unk_4.wrestle_type = -1
 attacker.actions:insert('#',action)
 j = j + 1
 end
end
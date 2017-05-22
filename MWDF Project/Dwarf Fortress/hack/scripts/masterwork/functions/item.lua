-- Item based functions, version 42.06a
--[[
 trackMaterial(itemID,change,dur,alter) - Tracks the changes to an items material, can track multiple changes
 trackQuality(itemID,change,dur,alter) - Tracks the changes to an items quality, can track multiple changes
 trackSubtype(itemID,change,dur,alter) - Tracks the changes to an items subtype, can track multiple changes
 changeMaterial(item,material,dur,track) - Changes the items material
 changeQuality(item,quality,dur,track) - Changes the items quality
 changeSubtype(item,subtype,dur,track) - Changes the items subtype
 checkAttack(item,attack) - Checks if an item has a specified attack, will return false if no attack is found, will return the attack id if found
 create(item,material,options) - Creates an item of the given material in format ITEM_TYPE:ITEM_SUBTYPE, MATERIAL_TYPE:MATERIAL_SUBTYPE
 equip(item,unit,bodyPart,mode) - Equips an item to a units body
 makeProjectileFall(item,origin,velocity) - Turns an item into a falling projectile
 makeProjectileShoot(item,origin,target,options) - Turns an item into a shooting projectile
 removal(item) - Removes an item from the game
 findItem(search) - Find an item based on the search parameters. See the find functions ReadMe for more information regarding search strings.
]]
---------------------------------------------------------------------------------------
function trackMaterial(itemID,change,dur,alter)
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.ItemTable
 if not itemTable[tostring(itemID)] then dfhack.script_environment('functions/tables').makeItemTable(itemID) end
 if alter == 'track' then
  local materialTable = itemTable[tostring(itemID)].Material
  materialTable.Current = change
  if dur >= 0 then
   local statusTable = materialTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = tostring(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
   statusTable[tostring(number+1)].Change = tostring(change)
  else
   materialTable.Base = change
  end
 elseif alter == 'end' then
  local materialTable = itemTable[tostring(itemID)].Material
  materialTable.Current = tostring(change)
  local statusTable = materialTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if tonumber(statusTable[i].End) <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 end
end

function trackQuality(itemID,change,dur,alter)
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.ItemTable
 if not itemTable[tostring(itemID)] then dfhack.script_environment('functions/tables').makeItemTable(itemID) end
 if alter == 'track' then
  local qualityTable = itemTable[tostring(itemID)].Quality
  qualityTable.Current = tostring(change)
  if dur >= 0 then
   local statusTable = qualityTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = tostring(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
   statusTable[tostring(number+1)].Change = tostring(change)
  else
   qualityTable.Base = tostring(change)
  end
 elseif alter == 'end' then
  local qualityTable = itemTable[tostring(itemID)].Quality
  qualityTable.Current = tostring(change)
  local statusTable = qualityTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if tonumber(statusTable[i].End) <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 end
end

function trackSubtype(itemID,change,dur,alter)
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.ItemTable
 if not itemTable[tostring(itemID)] then dfhack.script_environment('functions/tables').makeItemTable(itemID) end
 if alter == 'track' then
  local subtypeTable = itemTable[tostring(itemID)].Quality
  subtypeTable.Current = tostring(change)
  if dur >= 0 then
   local statusTable = subtypeTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = tostring(1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur)
   statusTable[tostring(number+1)].Change = tostring(change)
  else
   subtypeTable.Base = tostring(change)
  end
 elseif alter == 'end' then
  local subtypeTable = itemTable[tostring(itemID)].Quality
  subtypeTable.Current = tostring(change)
  local statusTable = subtypeTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if tonumber(statusTable[i].End) <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 end
end

function changeMaterial(item,material,dur,track)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 mat = dfhack.matinfo.find(material)
 save = dfhack.matinfo.getToken(item.mat_type,item.mat_index)
 item.mat_type = mat.type
 item.mat_index = mat.index
 if tonumber(dur) and tonumber(dur) > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','changeMaterial',{item.id,save,0,'end'}) end
 if track then trackMaterial(item.id,material,dur,track) end
end

function changeQuality(item,quality,dur,track)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 save = item.quality
 if quality > 5 then quality = 5 end
 if quality < 0 then quality = 0 end
 item:setQuality(quality)
 if tonumber(dur) and tonumber(dur) > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','changeQuality',{item.id,save,0,'end'}) end
 if track then trackQuality(item.id,quality,dur,track) end
end

function changeSubtype(item,subtype,dur,track)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 local itemType = item:getType()
 local itemSubtype = item:getSubtype()
 itemSubtype = dfhack.items.getSubtypeDef(itemType,itemSubtype).id
 local found = false
 for i=0,dfhack.items.getSubtypeCount(itemType)-1,1 do
  local item_sub = dfhack.items.getSubtypeDef(itemType,i)
  if item_sub.id == subtype then
   item:setSubtype(item_sub.subtype)
   found = true
  end
 end
 if not found then
  print('Incompatable item type and subtype')
  return
 end
 if tonumber(dur) and tonumber(dur) > 0 and found then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','changeSubtype',{item.id,itemSubtype,0,'end'}) end
 if track then trackSubtype(item.id,subtype,dur,track) end
end

function checkAttack(item,attack)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 attackID = false
 if attack == 'Random' then
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
    attackID = i-1
    break
   end
  end
 else
  for i,attacks in pairs(item.subtype.attacks) do
   if attacks.verb_2nd == attack or attacks.verb_3rd == attack then
    attackID = i
    break
   end
  end
 end
 return attackID
end

function create(item,material,a,b,c) --from modtools/create-item
 quality = b or 0
 creatorID = a or -1
 if creatorID == -1 then
  creator = df.unit.find(df.global.world.units.active[0])
  creatorID = creator.id
 else
  creator = df.unit.find(tonumber(creatorID))
  creatorID = creator.id
 end
 dur = c or 0
 dur = tonumber(dur)
 itemType = dfhack.items.findType(item)
 if itemType == -1 then
  error 'Invalid item.'
 end
 local itemSubtype = dfhack.items.findSubtype(item)
 material = dfhack.matinfo.find(material)
 if not material then
  error 'Invalid material.'
 end
 if tonumber(creatorID) >= 0 then
  item = dfhack.items.createItem(itemType, itemSubtype, material.type, material.index, creator)
 end
 if dur > 0 then dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','removal',{item}) end
 return item
end

function equip(item,unit,bodyPart,mode) --from modtools/equip-item
  --it is assumed that the item is on the ground
  --taken from expwnent
  item.flags.on_ground = false
  item.flags.in_inventory = true
  local block = dfhack.maps.getTileBlock(item.pos)
  local occupancy = block.occupancy[item.pos.x%16][item.pos.y%16]
  for k,v in ipairs(block.items) do
    --local blockItem = df.item.find(v)
    if v == item.id then
      block.items:erase(k)
      break
    end
  end
  local foundItem = false
  for k,v in ipairs(block.items) do
    local blockItem = df.item.find(v)
    if blockItem.pos.x == item.pos.x and blockItem.pos.y == item.pos.y then
      foundItem = true
      break
    end
  end
  if not foundItem then
    occupancy.item = false
  end
  local inventoryItem = df.unit_inventory_item:new()
  inventoryItem.item = item
  inventoryItem.mode = mode
  inventoryItem.body_part_id = bodyPart
  unit.inventory:insert(#unit.inventory,inventoryItem)
end

function makeProjectileFall(item,origin,velocity)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 proj = dfhack.items.makeProjectile(item)
 proj.origin_pos.x=origin[1]
 proj.origin_pos.y=origin[2]
 proj.origin_pos.z=origin[3]
 proj.prev_pos.x=origin[1]
 proj.prev_pos.y=origin[2]
 proj.prev_pos.z=origin[3]
 proj.cur_pos.x=origin[1]
 proj.cur_pos.y=origin[2]
 proj.cur_pos.z=origin[3]
 proj.flags.no_impact_destroy=false
 proj.flags.bouncing=true
 proj.flags.piercing=true
 proj.flags.parabolic=true
 proj.flags.unk9=true
 proj.flags.no_collide=true
 proj.speed_x=velocity[1]
 proj.speed_y=velocity[2]
 proj.speed_z=velocity[3]
end

function makeProjectileShot(item,origin,target,options)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 if options then
  velocity = options.velocity or 20
  hit_chance = options.accuracy or 50
  max_range = options.range or 10
  min_range = options.minimum or 1
  firer = df.unit.find(tonumber(options.firer)) or nil
 else
  velocity = 20
  hit_chance = 50
  max_range = 10
  min_range = 1
  firer = nil
 end
 proj = dfhack.items.makeProjectile(item)
 proj.origin_pos.x=origin[1]
 proj.origin_pos.y=origin[2]
 proj.origin_pos.z=origin[3]
 proj.prev_pos.x=origin[1]
 proj.prev_pos.y=origin[2]
 proj.prev_pos.z=origin[3]
 proj.cur_pos.x=origin[1]
 proj.cur_pos.y=origin[2]
 proj.cur_pos.z=origin[3]
 proj.target_pos.x=target[1]
 proj.target_pos.y=target[2]
 proj.target_pos.z=target[3]
 proj.flags.no_impact_destroy=false
 proj.flags.bouncing=false
 proj.flags.piercing=false
 proj.flags.parabolic=false
 proj.flags.unk9=false
 proj.flags.no_collide=false
-- Need to figure out these numbers!!!
 proj.distance_flown=0 -- Self explanatory
 proj.fall_threshold=max_range -- Seems to be able to hit units further away with larger numbers
 proj.min_hit_distance=min_range -- Seems to be unable to hit units closer than this value
 proj.min_ground_distance=max_range-1 -- No idea
 proj.fall_counter=0 -- No idea
 proj.fall_delay=0 -- No idea
 proj.hit_rating=hit_chance -- I think this is how likely it is to hit a unit (or to go where it should maybe?)
 proj.unk22 = velocity
 proj.firer = firer
 proj.speed_x=0
 proj.speed_y=0
 proj.speed_z=0
end

function removal(item)
 if tonumber(item) then item = df.item.find(tonumber(item)) end
 dfhack.items.remove(item)
end

function findItem(search)
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local itemList = df.global.world.items.all
 local targetList = {}
 local target = nil
 local n = 0
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'WEAPON' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_weaponst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'ARMOR' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_armorst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'HELM' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_helmst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'SHIELD' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_shieldst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'GLOVE' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_glovesst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'SHOE' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_shoesst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'PANTS' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_pantsst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'AMMO' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_ammost:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'MATERIAL' then
   local mat_type = dfhack.matinfo.find(tertiary).type
   local mat_index = dfhack.matinfo.find(tertiary).index
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and x.mat_type == mat_type and x.mat_index == mat_index then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'VALUE' then
   if tertiary == 'LESS_THAN' then
    for i,x in pairs(itemList) do
     if dfhack.items.getPosition(x) and dfhack.items.getValue(x) <= tonumber(quaternary) then
      n = n + 1
      targetList[n] = x
     end
    end
   elseif tertiary == 'GREATER_THAN' then
    for i,x in pairs(itemList) do
     if dfhack.items.getPosition(x) and dfhack.items.getValue(x) >= tonumber(quaternary) then
      n = n + 1
      targetList[n] = x
     end
    end
   end
  end
 end
 if n > 0 then
  targetList = dfhack.script_environment('functions/misc').permute(targetList)
  target = targetList[1]
  return {target}
 else
--  print('No valid item found for event')
  return {}
 end
end

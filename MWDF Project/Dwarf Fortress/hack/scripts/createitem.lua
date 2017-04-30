--createitem.lua v1.0
--[[
createitem - can create ammo, armor, and weapons that last a set time
	ID # - the units id number
		\UNIT_ID - when triggering with a syndrome
		\WORKER_ID - when triggering with a reaction
	ITEM/SUBTYPE - the type of item you wish to create
		WEAPON/WEAPON_SUBTYPE
		ARMOR/ARMOR_SUBTYPE
		HELM/HELM_SUBTYPE
		SHOES/SHOES_SUBTYPE
		SHIELD/SHIELD_SUBTYPE
		GLOVE/GLOVE_SUBTYPE
		PANTS/PANTS_SUBTYPE
		AMMO/AMMO_SUBTYPE
	INORGANIC_TOKEN - the material the item is made from
		Any inorganic token
	location - where to put the item (currently only on the ground, will add inventory capability)
		ground - will place on ground under unit
	(OPTIONAL) duration - sets a specified length of time for the item to exist (in in-game ‘ticks’)
		DEFAULT: 0 - item will last forever
EXAMPLE: createitem \UNIT_ID WEAPON/ITEM_WEAPON_SOUL_KNIFE SOUL_ETHER ground 3600
--]]

args = {...}

local function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function createcallback(item)
	return function (deleteitem)
		dfhack.items.remove(item)
	end
end

local unit = df.unit.find(tonumber(args[1]))
local mat = args[3]
local mat_type = dfhack.matinfo.find(mat).type
local mat_index = dfhack.matinfo.find(mat).index
local location = args[4]
local dur = 0
if #args == 5 then dur = tonumber(args[5]) end

local t = split(args[2],'/')[1]
if t == 'WEAPON' then v = 'item_weaponst' end
if t == 'ARMOR' then v = 'item_armorst' end
if t == 'HELM' then v = 'item_helmst' end
if t == 'SHOES' then v = 'item_shoesst' end
if t == 'SHIELD' then v = 'item_shieldst' end
if t == 'GLOVE' then v = 'item_glovest' end
if t == 'PANTS' then v = 'item_pantsst' end
if t == 'AMMO' then v = 'item_ammost' end

local item_index = df.item_type[t]
local item_subtype = 'nil'

for i=0,dfhack.items.getSubtypeCount(item_index)-1 do
  local item_sub = dfhack.items.getSubtypeDef(item_index,i)
  if item_sub.id == split(args[2],'/')[2] then
	  item_subtype = item_sub.subtype
	end
end

if item_subtype == 'nil' then
  print("No item of that type found")
  return
end

local item=df[v]:new() --incredible
item.id=df.global.item_next_id
df.global.world.items.all:insert('#',item)
df.global.item_next_id=df.global.item_next_id+1
item:setSubtype(item_subtype)
item:setMaterial(mat_type)
item:setMaterialIndex(mat_index)
item:categorize(true)
item.flags.removed=true
if t == 'WEAPON' then item:setSharpness(1,0) end
item:setQuality(0)
if location == 'ground' then dfhack.items.moveToGround(item,{x=unit.pos.x,y=unit.pos.y,z=unit.pos.z}) end
if location == 'inventory' then
	local umode = 0
	local bpart = 0
	dfhack.items.moveToInventory(item,unit,umode,bpart) 
end
if dur ~= 0 then dfhack.timeout(dur,'ticks',createcallback(item)) end
	


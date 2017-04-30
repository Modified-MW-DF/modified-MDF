-- taxidermy.lua
-- by Atomic Chicken

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'corpse_id',
 'statue_id',
 'record_name',
 'help'
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print([[ taxidermy.lua
 This script is designed to work with a reaction that takes a corpse and produces one statue of any material.

 arguments:
 
 -corpse_id
	The item id of the corpse you wish to "stuff". 
	If used in conjunction with reaction-product-trigger, this takes \\INPUT_ITEMS
	
 -statue_id
	The item id of the statue produced in the reaction. 	
	If used in conjunction with reaction-product-trigger, this takes \\OUTPUT_ITEMS
	
 -record_name
	If this optional argument is included, the script will check whether the corpse was from a named historical figure,
	and if so describes the statues as being "of [creature's name]" rather than "of [creature's race]".

  To use:
  
 Create a file called "onLoad.init" in Dwarf Fortress/raw if one does not already exist.
 Enter the following: 
  modtools/reaction-product-trigger -reactionName YOUR_REACTION -command [ taxidermy -corpse_id \\INPUT_ITEMS -statue_id \\OUTPUT_ITEMS -record_name ]
 Replace "YOUR_REACTION" with whatever your reaction is called.
 ]])
 return
end	

if not args.corpse_id then 
error 'ERROR: Corpse id not specified.'
end

if not args.statue_id then
error 'ERROR: Statue id not specified.'
end

corpse = df.item.find(tonumber(args.corpse_id))
statue = df.item.find(tonumber(args.statue_id))

if corpse ~= nil and statue ~= nil then

if args.record_name 
and corpse:getType() ~= df.item_type.REMAINS 
and corpse.hist_figure_id ~= -1 then
unit_id = corpse.unit_id
unit = df.unit.find(unit_id)
if unit.name.has_name == true then
target_desc_name = dfhack.TranslateName(dfhack.units.getVisibleName(unit))

dfhack.timeout(1,'ticks',function() 
		statue.description = ''..target_desc_name..''
		
		for _,artchunk in ipairs(df.global.world.art_image_chunks) do
			if artchunk.id == statue.image.id then
				
			statue_image = artchunk.images[statue.image.subid]
end
end
		
		while #statue_image.elements > 0 do
		statue_image.elements:erase(#statue_image.elements-1)
			end
			
		while #statue_image.properties > 0 do
		statue_image.properties:erase(#statue_image.properties-1)
			end
					
		newart=df.art_image_element_creaturest:new()
		statue_image.elements:insert("#",newart)

		statue_image.elements[0].histfig = corpse.hist_figure_id
		
		statue_image.mat_type = -1
		statue_image.mat_index = -1
	end)
end

else

raceindex = corpse.race
casteindex = corpse.caste
target_desc = df.global.world.raws.creatures.all[raceindex].caste[casteindex].caste_name[0]

dfhack.timeout(1,'ticks',function() 
		statue.description = 'a '..target_desc..'' 

		for _,artchunk in ipairs(df.global.world.art_image_chunks) do
			if artchunk.id == statue.image.id then
			statue_image = artchunk.images[statue.image.subid]
end
end

	while #statue_image.elements > 0 do
		statue_image.elements:erase(#statue_image.elements-1)
			end
			
	while #statue_image.properties > 0 do
		statue_image.properties:erase(#statue_image.properties-1)
			end
					
		newart=df.art_image_element_creaturest:new()
		statue_image.elements:insert("#",newart)

			statue_image.elements[0].race = raceindex
			statue_image.elements[0].caste = casteindex
			statue_image.elements[0].count = 1
			
		statue_image.mat_type = -1
		statue_image.mat_index = -1

end)
end
end
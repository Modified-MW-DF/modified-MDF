    local pos=position or copyall(df.global.cursor)
    if pos.x==-30000 then
        qerror("Select a location")
    end
	local x = 0
	local y = 0
	for x=pos.x-3,pos.x+3,1 do
		for y=pos.y-3,pos.y+3,1 do
			 z=pos.z-1
			while true do
				local block = dfhack.maps.getTileBlock(x,y,z)
				if block then
					--print(x..","..y)
					block.tiletype[x%16][y%16]=32
					--z = z-1
				else
					--z = z+1
					block = dfhack.maps.getTileBlock(x,y,z)
					block.tiletype[x%16][y%16]=42
					break
				end
			
		end
		end
	end

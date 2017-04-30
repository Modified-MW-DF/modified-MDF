function empregnate(unit)
	if unit==nil then
		error("Failed to empregnate. Unit not selected/valid")
	end
	if unit.curse then
		unit.curse.add_tags2.STERILE=false
	end
	local genes = unit.appearance.genes
	if unit.pregnancy_genes == nil then
		print("creating preg ptr.")
		if false then
			print(string.format("%x %x",df.sizeof(unit:_field("pregnancy_genes"))))
			return
		end
		unit.pregnancy_genes = { new = true, assign = genes }
	end
	local ngenes = unit.pregnancy_genes
	if #ngenes.appearance ~= #genes.appearance or #ngenes.colors ~= #genes.colors then
		print("Array sizes incorrect, fixing.")
		ngenes:assign(genes);
	end
	print("Setting preg timer.")
	unit.pregnancy_timer=1
	unit.pregnancy_caste=1
end

local unit_id=...
empregnate(df.unit.find(tonumber(unit_id)))
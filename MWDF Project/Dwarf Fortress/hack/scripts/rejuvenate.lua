-- make the selected dwarf 20 years old
-- by vjek
--[====[

rejuvenate
==========
Set the age of the selected dwarf to 20 years.  Useful if valuable citizens are
getting old, or there are too many babies around...

]====]

function rejuvenate()
    local current_year,newbirthyear
    unit=dfhack.gui.getSelectedUnit()

    if unit==nil then print ("No unit under cursor!  Aborting.") return end

    current_year=df.global.cur_year
    newbirthyear=current_year - 20
    if unit.birth_year < newbirthyear then
        unit.birth_year=newbirthyear
    end
    if unit.old_year < current_year+100 then
        unit.old_year=current_year+100
    end
    print (dfhack.TranslateName(dfhack.units.getVisibleName(unit)).." is now 20 years old and will live at least 100 years")

end

rejuvenate()

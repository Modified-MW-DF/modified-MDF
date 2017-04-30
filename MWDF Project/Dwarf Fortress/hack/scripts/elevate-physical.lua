-- Elevate all the physical attributes of a unit
-- by vjek
--[====[

elevate-physical
================
Set all physical attributes of the selected dwarf to the maximum possible, or
any number numbers between 0 and 5000 passed as an argument.  Higher is
usually better, but an ineffective hammerer can be useful too...

]====]

function ElevatePhysicalAttributes(value)
    unit=dfhack.gui.getSelectedUnit()
    if unit==nil then
        print ("No unit under cursor!  Aborting with extreme prejudice.")
        return
    end
    --print name of dwarf
    print("Adjusting "..dfhack.TranslateName(dfhack.units.getVisibleName(unit)))
    --walk through available attributes, adjust current to max
    local ok,f,t,k = pcall(pairs,unit.body.physical_attrs)
    if ok then
        for k,v in f,t,k do
            if value ~= nil then
                print("Adjusting current value for "..tostring(k).." of "..v.value.." to the value of "..value)
                v.value=value
            else
                print("Adjusting current value for "..tostring(k).." of "..v.value.." to max value of "..v.max_value)
                v.value=v.max_value
                --below will reset values back to "normal"
                --v.value=v.max_value/2
            end
        end
    end
end
--script execution starts here
local opt = ...
opt = tonumber(opt)

if opt ~= nil then
    if opt >=0 and opt <=5000 then
        ElevatePhysicalAttributes(opt)
    end
    if opt <0 or opt >5000 then
        print(help)
        print('\n\nInvalid number!')
    end
end

if opt == nil then
    ElevatePhysicalAttributes()
end

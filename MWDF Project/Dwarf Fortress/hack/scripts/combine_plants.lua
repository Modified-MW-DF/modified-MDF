-- Merge stacks of plants and plant growths in the selected container or stockpile
--[[=begin

combine-plants
==============
Merge stacks of plants or plant growths in the selected container or stockpile.

=end]]
local utils = require 'utils'

validArgs = validArgs or utils.invert({ 'max', 'stockpile', 'container' })
local args = utils.processArgs({...}, validArgs)

local max = 12
if args.max then max = tonumber(args.max) end

local stockpile = nil
if args.stockpile then stockpile = df.building.find(tonumber(args.stockpile)) end
    
local container = nil
if args.container then container = df.item.find(tonumber(args.container)) end

local function itemsCompatible(item0, item1)
    return item0:getType() == item1:getType()
        and item0.mat_type == item1.mat_type
        and item0.mat_index == item1.mat_index
end

local function getPlants(items, plants, index)
    for i,p in ipairs(items) do
        -- Skip items currently tasked
        if #p.specific_refs == 0 then
            if p:getType() == 53 or p:getType() == 55 or p:getType() == 70 then
                plants[index] = p
                index = index + 1

            else
                local containedItems = dfhack.items.getContainedItems(p)
                if #containedItems > 0 then
                    index = getPlants(containedItems, plants, index)
                end
            end
        end
    end

    return index
end

local item = container or dfhack.gui.getSelectedItem(true)
local building = stockpile or dfhack.gui.getSelectedBuilding(true)
if building ~= nil and building:getType() ~= 29 then building = nil end
if item == nil and building == nil then
    error("Select an item or building")

else
    local rootItems;
    if building then
        rootItems = dfhack.buildings.getStockpileContents(building)
    else
        rootItems = dfhack.items.getContainedItems(item)
    end

    if #rootItems == 0 then
        error("Select a non-empty container")

    else
        local plants = { }
        local plantCount = getPlants(rootItems, plants, 0)

        local removedPlants = { }

        for i=0,(plantCount-2) do
            local currentPlant = plants[i]
            local itemsNeeded = max - currentPlant.stack_size

            if removedPlants[currentPlant.id] == nil and itemsNeeded > 0 then
                for j=(i+1),(plantCount-1) do
                    local sourcePlant = plants[j]

                    if removedPlants[sourcePlant.id] == nil and itemsCompatible(currentPlant, sourcePlant) then
                        local amountToMove = math.min(itemsNeeded, sourcePlant.stack_size)
                        itemsNeeded = itemsNeeded - amountToMove
                        currentPlant.stack_size = currentPlant.stack_size + amountToMove

                        if sourcePlant.stack_size == amountToMove then
                            removedPlants[sourcePlant.id] = true
                            sourcePlant.stack_size = 1
                        else
                            sourcePlant.stack_size = sourcePlant.stack_size - amountToMove
                        end
                    end
                end
            end
        end

        for id,removed in pairs(removedPlants) do
            if removed then
                local removedPlant = df.item.find(id)
                dfhack.items.remove(removedPlant)
            end
        end
    end
end

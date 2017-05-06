
-- Automatically generated, do not edit!
-- Source: addons:zip:The Earth Strikes Back!/tesb-weather.dfcom.lua
-- Asserts a specific weather type in the presence of a creature.
--[=[
    arguments
        -creature
            <CREATURE_TOKEN>    The creature type to watch for, mandatory
        -weather
            rain|snow|clear	    The weather to force, defaults to "rain"

    Made by Dirst for use in The Earth Strikes Back mod
	
--]=]

local utils=require 'utils'

local validArgs = validArgs or utils.invert({
    'help',
    'creature',
    'weather',
})

local args = utils.processArgs({...}, validArgs)

if args.help then
	print([[
Asserts a specific weather type in the presence of a creature.
    arguments
        -creature
            <CREATURE_TOKEN>    The creature type to watch for, mandatory
        -weather
            rain|snow|clear	    The weather to force, defaults to "rain"
        -help                   Display this help message  
]])
	return
end

local weather_name = args.weather or "rain"
local target_weather = 0

if weather_name ~= "rain" and weather_name ~= "snow" and weather_name ~= "clear" then
	qerror("Weather must be rain, snow or clear.")
else
	if weather_name == "rain" then target_weather = 1 end
	if weather_name == "snow" then target_weather = 2 end
end

local function findRace(name)
    for k,v in pairs(df.global.world.raws.creatures.all) do
        if v.creature_id==name then
            return k
        end
    end
    qerror("Race:"..name.." not found!")
end

critter = findRace(args.creature)

function checkForCreature()
    for k,v in ipairs(df.global.world.units.active) do
		if v.race == critter and dfhack.world.ReadCurrentWeather() ~= target_weather then 
			dfhack.world.SetCurrentWeather(target_weather)
		end
	end
end

require('repeat-util').scheduleEvery('onAction',10,'ticks',checkForCreature)
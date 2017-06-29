--[[
Utility for The Earth Strikes Back! mod that reports the base probability 
and grace period for Awakened Stones and Wyrms, plus the base and current
probability for Hidden Gems

Made by Dirst for The Earth Strikes Back! mod.
]]

local tesb_version = "2.14"
dfhack.color(-1)

-- Load configuration data
--	Value is a string holding the TESB version of the data structure
--	ints[1] is "-living" parameter
--	ints[2] is "-gem" parameter 
local config = dfhack.persistent.get("TESB/config")
local living_prob
local gem_prob
if config then
	if config.value > tesb_version then
		dfhack.color(12)
		dfhack.println("Cannot read configuration from version "..config.value..".")
		return
	end
	living_prob = config.ints[1]/10000
	gem_prob = config.ints[2]/10000
else
	dfhack.println("No saved TESB data found.")
	dfhack.print("Settings will be determined by ")
	dfhack.color(10)
	dfhack.print("tesb-job-monitor ")
	dfhack.color(-1)
	dfhack.print("parameters.")
	return
end
-- Load grace period data
--	Value is a string holding the TESB version of the data structure
--	ints[1] is "-grace_period" parameter
--	ints[2] is the number of tiles mined
local grace = dfhack.persistent.get("TESB/grace")
local grace_total
local grace_count
if grace then
	if config.value > tesb_version then
		dfhack.color(12)
		dfhack.println("Cannot read grace period data from version "..grace.value..".")
		dfhack.color(-1)
		return
	end
	grace_total = grace.ints[1]
	grace_count = grace.ints[2]
else
	dfhack.println("No saved TESB data found.")
	dfhack.print("Settings will be determined by ")
	dfhack.color(10)
	dfhack.print("tesb-job-monitor ")
	dfhack.color(-1)
	dfhack.print("parameters.")
	return
end

print("The Earth Strikes Back! version " .. tesb_version)
print("Grace period: " .. grace_total .. " tiles of layer stone")
if grace_count <30000 then
	print("Layer stone tiles dug so far: " .. grace_count)
else
	print("Layer stone tiles dug so far: 30000 or more.")
end
if grace_total <= grace_count then
	print("Living stone base probability: " .. living_prob*100 .. "% (No grace period remaining)")
else
	print("Living stone base probability: " .. living_prob*100 .. "% (" .. grace_total-grace_count .. " tiles remaining in grace period)")
end
print("    " .. (1-living_prob^.5)*100 .. "% of Living Stone yields an Awakened Stone")
print("    " .. (living_prob^.5)*100 .. "% of Living Stone yields a Wyrm")
print("Hidden gem base probability: " .. gem_prob*100 .. "% (Current effective rate " .. 100*gem_prob*math.min(1,(grace_count/grace_total)) .. "%)")

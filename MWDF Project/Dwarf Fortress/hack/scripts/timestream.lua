-- Multiplies the speed of calendar time by the specified value.  The parameter can be any positive number, though going over 10 is likely to cause bugs.  1 is normal speed.
 
args={...}
local rate=tonumber(args[1])
local prev_tick = 0
if rate == nil then
	rate = 1
elseif rate < 0 then
	rate = 0
end
 
eventNow = false
seasonNow = false
timestream = 0
counter = 0
if df.global.cur_season_tick < 3360 then
	month = 1
elseif df.global.cur_season_tick < 6720 then
	month = 2
else
	month = 3
end
 
dfhack.onStateChange.loadTimestream = function(code)
	if code==SC_MAP_LOADED then
		if rate ~= 1 then
			print('Time running at x'..rate)
			
			eventNow = false
			seasonNow = false
			timestream = 0
			if df.global.cur_season_tick < 3360 then
				month = 1
			elseif df.global.cur_season_tick < 6720 then
				month = 2
			else
				month = 3
			end
			if loaded ~= true then
				dfhack.timeout(1,"ticks",function() update() end)
				loaded = true
			end
		else
			print('Time set to normal speed.')
			loaded = false
		end
	elseif code==SC_MAP_UNLOADED then
	end
end
 
function update()
	prev_tick = df.global.cur_year_tick
	if rate ~= 1 then
		timestream = 0
		
		if rate < 1 then
			if df.global.cur_year_tick - math.floor(df.global.cur_year_tick/10)*10 == 5 then
				if counter > 1 then
					counter = counter - 1
					timestream = -1
				else
					counter = counter + 1/rate
				end
			end
		else
			counter = counter + rate-1
			while counter >= 10 do
				counter = counter - 10
				timestream = timestream + 1
			end
		end
		
		eventFound = false
		for i=0,#df.global.timed_events-1,1 do
			event=df.global.timed_events[i]
			if event.season == df.global.cur_season and event.season_ticks <= df.global.cur_season_tick then
				if eventNow == false then
					--df.global.cur_season_tick=event.season_ticks
					event.season_ticks = df.global.cur_season_tick
					eventNow = true
				end
				eventFound = true
			end
		end
		if eventFound == false then eventNow = false end
		
		if df.global.cur_season_tick >= 3359 and df.global.cur_season_tick < 6719 and month == 1 then
			seasonNow = true
			month = 2
			if df.global.cur_season_tick > 3359 then
				df.global.cur_season_tick = 3360
			end
		elseif df.global.cur_season_tick >= 6719 and df.global.cur_season_tick < 10079 and month == 2 then
			seasonNow = true
			month = 3
			if df.global.cur_season_tick > 6719 then
				df.global.cur_season_tick = 6720
			end
		elseif df.global.cur_season_tick >= 10079 then
			seasonNow = true
			month = 1
			if df.global.cur_season_tick > 10080 then
				df.global.cur_season_tick = 10079
			end
		else
			seasonNow = false
		end
		
		if df.global.cur_year > 0 then
			if timestream ~= 0 then
				if df.global.cur_season_tick < 0 then
					df.global.cur_season_tick = df.global.cur_season_tick + 10080
					df.global.cur_season = df.global.cur_season-1
					eventNow = true
				end
				if df.global.cur_season < 0 then
					df.global.cur_season = df.global.cur_season + 4
					df.global.cur_year_tick = df.global.cur_year_tick + 403200
					df.global.cur_year = df.global.cur_year - 1
					eventNow = true
				end
				if (eventNow == false and seasonNow == false) or timestream < 0 then
					if timestream > 0 then
						df.global.cur_season_tick=df.global.cur_season_tick + timestream
						remainder = df.global.cur_year_tick - math.floor(df.global.cur_year_tick/10)*10
						df.global.cur_year_tick=(df.global.cur_season_tick*10)+((df.global.cur_season)*100800) + remainder
					elseif timestream < 0 then
						df.global.cur_season_tick=df.global.cur_season_tick
						df.global.cur_year_tick=(df.global.cur_season_tick*10)+((df.global.cur_season)*100800)
					end
				end
			end
		end
		dfhack.timeout(1,"ticks",function() update() end)
	end
end
 
--Initial call
 
if dfhack.isMapLoaded() then 
	dfhack.onStateChange.loadTimestream(SC_MAP_LOADED)
end
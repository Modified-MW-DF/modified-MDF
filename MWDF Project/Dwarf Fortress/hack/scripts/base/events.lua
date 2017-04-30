--base/events.lua v1.0

local persistTable = require 'persist-table'

function checkevent(event,chance)
 return function(eventcheck)
  local rando = dfhack.random.new()
  rnum = rando:random(100)+1
  if tonumber(chance) >= rnum then
   dfhack.run_command('events/trigger -event '..event)
  end
  queue(event)
 end
end

function queue(event)
 local events = persistTable.GlobalTable.roses.EventTable
 local x = events[event]
 if x then
  local method = x['Check']
  local chance = x['Chance']
  if method then
   if method == 'YEARLY' then
    curtick = df.global.cur_year_tick
    ticks = 1200*28*3*4-curtick
    if ticks <= 0 then ticks = 1200*28*3*4 end
    dfhack.timeout(ticks+1,'ticks',checkevent(event,chance))
   elseif method == 'SEASON' then
    curtick = df.global.cur_season_tick*10
    ticks = 1200*28*3-curtick
    if ticks <= 0 then ticks = 1200*28*3 end
    dfhack.timeout(ticks+1,'ticks',checkevent(event,chance))
   elseif method == 'MONTHLY' then
    curtick = df.global.cur_year_tick
    moy = curtick/(1200*28)
    ticks = math.ceil(moy)*1200*28 - curtick
    if ticks <= 0 then ticks = 1200*28 end
    dfhack.timeout(ticks+1,'ticks',checkevent(event,chance))
   elseif method == 'WEEKLY' then
    curtick = df.global.cur_year_tick
    woy = curtick/(1200*7)
    ticks = math.ceil(woy)*1200*7 - curtick
    if ticks <= 0 then ticks = 1200*7 end
    dfhack.timeout(ticks+1,'ticks',checkevent(event,chance))
   elseif method == 'DAILY' then
    curtick = df.global.cur_year_tick
    doy = curtick/1200
    ticks = math.ceil(doy)*1200 - curtick
    if ticks <= 0 then ticks = 1200 end
    dfhack.timeout(ticks+1,'ticks',checkevent(event,chance))
   else
    curtick = df.global.cur_season_tick*10
    ticks = 1200*28*3-curtick
    if ticks <= 0 then ticks = 1200*28*3 end
    dfhack.timeout(ticks+1,'ticks',checkevent(event,chance))
   end
  end
 end
end

local events = persistTable.GlobalTable.roses.EventTable
for _,i in pairs(events._children) do
 queue(i)
end
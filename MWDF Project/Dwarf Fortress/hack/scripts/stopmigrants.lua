local function removeMigrantWaves()
    local indexesToErase={}
    for k,v in ipairs(df.global.timed_events) do
        if v.type==df.timed_event_type['Migrants'] then
            table.insert(indexesToErase,k)
        end
    end
    for i=#indexesToErase,1,-1 do
        df.global.timed_events:erase(indexesToErase[i])
    end
end

require('repeat-util').scheduleEvery('remove migrant waves',1,'ticks',removeMigrantWaves)
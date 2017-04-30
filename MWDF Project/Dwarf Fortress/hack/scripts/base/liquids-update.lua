local persistTable = require 'persist-table'

liquidTable = persistTable.GlobalTable.roses.LiquidTable

for _,i in pairs(liquidTable._children) do
 liquid = liquidTable[i]
 if liquid.Type == 'Source' then
  dfhack.script_environment('functions/map').liquidSource(i)
 elseif liquid.Type == 'Sink' then
  dfhack.script_environment('functions/map').liquidSink(i)
 end
end
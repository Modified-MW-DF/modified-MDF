local persistTable = require 'persist-table'

flowTable = persistTable.GlobalTable.roses.FlowTable

for _,i in pairs(flowTable._children) do
 dfhack.script_environment('functions/map').flowSource(i)
end
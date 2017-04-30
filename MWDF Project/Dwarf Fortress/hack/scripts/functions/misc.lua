
function getChange(current,value,mode)
 local change = 0
 if mode == 'Fixed' or mode == 'fixed' then
  change = tonumber(value)
 elseif mode == 'Percent' or mode == 'percent' then
  local percent = (100+tonumber(value))/100
  change = current*percent - current
 elseif mode == 'Set' or mode == 'set' then
  change = tonumber(value) - current
 else
  print('No method for change defined')
  return
 end 
 return change
end

function permute(tab)
 -- Randomly permutes a given table. Returns permuted table
 if true then
  n = #tab-1
  for i = 0, n do
   local j = math.random(i, n)
   tab[i], tab[j] = tab[j], tab[i]
  end
  return tab
 else
  n = #tab
  for i = 1, n do
   local j = math.random(i, n)
   tab[i], tab[j] = tab[j], tab[i]
  end
  return tab
 end
end

function changeCounter(counter,amount,extra)
 local persistTable = require 'persist-table'
 local roses = persistTable.GlobalTable.roses
 if not roses then return end
 local utils = require 'utils'
 local split = utils.split_string
 counterTable = persistTable.GlobalTable.roses
 counters = split(counter,':')

 for i,x in pairs(counters) do
  if i == #counters then
   endc = x
   break
  end
  if (x == '!UNIT' or x == '!BUILDING' or x == '!ITEM') then
   if not counterTable[tostring(extra)] then
    counterTable[tostring(extra)] = {}
   end
   counterTable = counterTable[tostring(extra)]
  elseif not counterTable[x] then
   if i ~= #counters then
    counterTable[x] = {}
   else
    if tonumber(amount) then
     counterTable[x] = '0'
    else
     counterTable[x] = amount
    end
   end
   counterTable = counterTable[x]
  else
   counterTable = counterTable[x]
  end
 end

 if tonumber(amount) then
  if not counterTable[endc] then
   counterTable[endc] = '0'
  end
  if tonumber(counterTable[endc]) then
   counterTable[endc] = tostring(counterTable[endc] + tonumber(amount))
  else
   print("Can't add an integer to a string counter")
   return
  end
 else
  counterTable[endc] = amount
 end

 return counterTable[endc]
end

function checkCounter(counter,extra)
 local persistTable = require 'persist-table'
 local roses = persistTable.GlobalTable.roses
 if not roses then return end

 local utils = require 'utils'
 local split = utils.split_string

 counterTable = persistTable.GlobalTable.roses
 counters = split(counter,':')
 
 for i,x in pairs(counters) do
  if (x == '!UNIT' or x == '!BUILDING' or x == '!ITEM') then
   if not counterTable[tostring(extra)] then
    return false
   end
   counterTable = counterTable[tostring(extra)]
  elseif not counterTable[x] then
   return false
  else
   counterTable = counterTable[x]
  end
 end

 return true
end

function getCounter(counter,extra)
 local persistTable = require 'persist-table'
 local roses = persistTable.GlobalTable.roses
 if not roses then return end

 local utils = require 'utils'
 local split = utils.split_string

 counterTable = persistTable.GlobalTable.roses
 counters = split(counter,':')

 for i,x in pairs(counters) do
  if (x == '!UNIT' or x == '!BUILDING' or x == '!ITEM') then
   if not counterTable[tostring(extra)] then
    counterTable[tostring(extra)] = {}
   end
   counterTable = counterTable[tostring(extra)]
  elseif not counterTable[x] then
   print('Counter not found')
   return
  else
   counterTable = counterTable[x]
  end
 end
 return counterTable
end

function checkResistance(resistance,temp)
 local persistTable = require 'persist-table'
 local utils = require 'utils'
 local split = utils.split_string
 
 resistances = temp or {}
 baseTable = persistTable.GlobalTable.roses.BaseTable.CustomResistances
 for i,x in ipairs(split(resistance,':')) do
  if baseTable[x] then
   baseTable = baseTable[x]
  else
   return
  end
 end
 if baseTable._children then
  for _,x in ipairs(baseTable._children) do
   checkResistance(resistance..':'..x,resistances)
  end
 else
  resistances[resistance] = true
 end
 return resistances
end
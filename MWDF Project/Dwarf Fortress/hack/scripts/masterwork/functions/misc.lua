-- Miscellanious functions, v42.06a
--[[
 getChange(current,value,mode) - Get the amount changed from the current depending on value and mode, returns a number
 permute(tahle) - Takes a table and randomly permutes it, returns the permuted table
 changeCounter(counter,amount,extra) - Change the counter by a certain amount, returns the ending value of the counter
 checkCounter(counter,extra) - Checks if a counter exists, returns true/false
 getCounter(counter,extra) - Get the value of a certain counter, returns a number
]]
function fillEquation(source,target,spell,equation)
 local utils = require 'utils'
 local split = utils.split_string 
 equation = string.upper(equation)
 local persistTable = require 'persist-table'
 local equationTable = persistTable.GlobalTable.roses.baseTable.Equations
 if equationTable[equation] then
  spellSourceEquations = { MAGICAL_EXHAUSTION_MODIFIER = true,
                           MAGICAL_SPEED_PERC = true,
                           MAGICAL_HIT_CHANCE = true,
                           MAGICAL_CRIT_CHANCE = true,
                           MAGICAL_CRIT_BONUS = true,
                           PHYSICAL_EXHAUSTION_MODIFIER = true,
                           PHYSICAL_SPEED_PERC = true,
                           PHYSICAL_HIT_CHANCE = true,
                           PHYSICAL_CRIT_CHANCE = true,
                           PHYSICAL_CRIT_BONUS = true }
  spellTargetEquations = { DODGE_CHANCE = true }
  local temp = equationTable[equation]
  if spellSourceEquations[equation] then
   temp = temp:gsub('ATTRIBUTE','SOURCE.ATTRIBUTE')
   temp = temp:gsub('SKILL','SOURCE.SKILL')
   temp = temp:gsub('STAT','SOURCE.STAT')
   temp = temp:gsub('RESISTANCE','SOURCE.RESISTANCE')
  elseif spellTargetEquations[equation] then
   temp = temp:gsub('ATTRIBUTE','TARGET.ATTRIBUTE')
   temp = temp:gsub('SKILL','TARGET.SKILL')
   temp = temp:gsub('STAT','TARGET.STAT')
   temp = temp:gsub('RESISTANCE','TARGET.RESISTANCE')
  end
  equation = temp
 end
 if source then
  if tonumber(source) then source = df.unit.find(tonumber(source)) end
  sourceID = source.id
 end
 if target then
  if tonumber(target) then target = df.unit.find(tonumber(target)) end
  targetID = target.id
 end
 if spell then
  local spellTable = persistTable.GlobalTable.roses.SpellTable
  if not spellTable[spell] then
   spell = nil
  end
 end
 local unitFunctions = dfhack.script_environment('functions/unit')
 local spellFunctions = dfhack.script_environment('functions/spell')
 for _,check in pairs({'SOURCE','TARGET'}) do
  if check == 'SOURCE' then
   if not sourceID then
    break
   else
    unitID = sourceID
   end
  elseif check == 'TARGET' then
   if not targetID then
    break
   else
    unitID = targetID
   end
  end
  while equation:find(check) do
   look = string.match(equation..'+',check..".(.-)[+%-*/]")
   array = split(look,"%.")
   if array[1] == 'ATTRIBUTE' then
    if array[2] == 'WEIGHT' then
     value = unitFunctions.calculateWieght(unitID,false)
    elseif array[2] == 'FULL_WEIGHT' then
     value = unitFunctions.calculateWieght(unitID,true)
    elseif array[2] == 'PRIMARY' and spell then
     value = spellFunctions.calculateAttribute(sourceID,spell,'PRIMARY',check)
    elseif array[2] == 'SECONDARY' and spell then
     value = spellFunctions.calculateAttribute(sourceID,spell,'SECONDARY',check)
    else
     value = unitFunctions.getUnit(unitID,'Attributes',array[2])
    end
   elseif array[1] == 'SKILL' then
    if array[2] == 'WEAPON' then
     value = unitFunctions.getWeaponSkill(unitID)
    elseif array[2] == '!_SPELL_CASTING' and spell then
     value = spellFunctions.calculateSkill(unitID,spell,'SPELL_CASTING')
    else
     value = unitFunctions.getUnit(unitID,'Skills',array[2])
    end
   elseif array[1] == 'STAT' then
    if array[2] == '!_HIT_CHANCE' and spell then
     value = spellFunctions.calculateStat(unitID,spell,'HIT_CHANCE')
    elseif array[2] == '!_CASTING_SPEED' and spell then
     value = spellFunctions.calculateStat(unitID,spell,'CASTING_SPEED')
    elseif array[2] == '!_ATTACK_SPEED' and spell then
     value = spellFunctions.calculateStat(unitID,spell,'ATTACK_SPEED')
    elseif array[2] == '!_CRITICAL_CHANCE' and spell then
     value = spellFunctions.calculateStat(unitID,spell,'CRITICAL_CHANCE')
    elseif array[2] == '!_CRITICAL_BONUS' and spell then
     value = spellFunctions.calculateStat(unitID,spell,'HIT_CHANCE')
    elseif array[2] == '!_SKILL_PENETRATION' and spell then
     value = spellFunctions.calculateStat(unitID,spell,'SKILL_PENETRATION')
    else
     value = unitFunctions.getUnit(unitID,'Stats',array[2])
    end
   elseif array[1] == 'RESISTANCE' then
    if array[2] == '!_TDDS' then
     value = spellFunctions.calculateResistance(unitID,spell)
    else
     value = unitFunctions.getUnit(unitID,'Resistances',array[2])
    end
   elseif array[1] == 'TRAIT' then
    value = unitFunctions.getUnit(unitID,'Traits',array[2])
   elseif array[1] == 'COUNTER' then
    value = unitFunction.getCounter(unitID,string.lower(array[2]))
   end
   equation = equation:gsub(string.match(equation..'+',"("..check..".-)[+%-*/]"),tostring(value)) 
  end
 end
 while equation:find('EQUATION') do
  look = string.match(equation..'+',"EQUATION.(.-)[+%-*/]")
  array = split(look,"%.")
  value = fillEquation(sourceID,targetID,spell,array[1])
  equation = equation:gsub(string.match(equation..'+',"(EQUATION.-)[+%-*/]"),tostring(value)) 
 end
 
 equals = assert(load("return "..equation))
 value = equals()
 return value 
end

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
 counterTable = persistTable.GlobalTable.roses.CounterTable
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
 counterTable = persistTable.GlobalTable.roses.CounterTable
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
 counterTable = persistTable.GlobalTable.roses.CounterTable
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

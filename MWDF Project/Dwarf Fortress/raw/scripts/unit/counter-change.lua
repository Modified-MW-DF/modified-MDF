--unit/counter-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'counter',
 'mode',
 'amount',
 'dur',
 'unit',
 'announcement'
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/counter-change.lua
  Change the value(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -counter TYPE
     REQUIRED
     token to be changed
     valid types:
      webbed
      stunned
      winded
      unconscious
      suffocation
      pain
      nausea
      dizziness
      paralysis
      numbness
      fever
      exhaustion
      hunger
      thirst
      sleepiness
      blood
      infection
   -mode Mode Type
     Valid Types:
      Fixed
      Percent
      Set
   -amount #
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   unit/counter-change -unit \\UNIT_ID -mode fixed -amount 10000 -token stunned -dur 10
   unit/counter-change -unit \\UNIT_ID -mode set -amount [ 0 0 0 0 ] -token [ nausea dizziness numbness fever ]
   unit/counter-change -unit \\UNIT_ID -mode percent -amount \-100 -token blood
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

value = args.amount

dur = tonumber(args.dur) or 0
if dur < 0 then return end
if type(value) == 'string' then value = {value} end
if type(args.counter) == 'string' then args.counter = {args.counter} end
if #value ~= #args.counter then
 print('Mismatch between number of tokens declared and number of changes declared')
 return
end

for i,counter in ipairs(args.counter) do
 if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness' or counter == 'suffocation') then
  location = unit.counters
 elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
         or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
  if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
  location = unit.counters2
 elseif counter == 'blood' or counter == 'infection' then
  location = unit.body
 else
  print('Invalid counter token declared')
  print(counter)
  return
 end
 current = location[counter]

-- if counter == 'pain' or counter == 'nausea' or counter == 'dizziness' or counter == 'paralysis' or counter == 'numbness' or counter == 'fever' then
--  print('Counter = ', counter)
--  print('Declared counter is not meant to be changed with this script, see http://www.bay12forums.com/smf/index.php?topic=154798 for information.')
-- end
 
 change = dfhack.script_environment('functions/misc').getChange(current,value[i],args.mode)
 dfhack.script_environment('functions/unit').changeCounter(unit,counter,change,dur)
 if args.announcement then
--add announcement information
 end
end
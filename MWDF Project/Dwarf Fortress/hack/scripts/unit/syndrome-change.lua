--unit/syndrome-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'syndrome',
 'class',
 'add',
 'erase',
 'terminate',
 'alterDuration',
 'dur',
 'announcement',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/syndrome-change
  Change the syndrome(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -syndrome SYN_NAME
     declares the given SYN_NAME to be changed (can be a table of syndrome names)
   -class SYN_CLASS
     declares the given SYN_CLASS to be changed (can be a table of syndrome classes)
   -add
     adds syndromes to unit
   -erase
     removes syndromes from unit
   -terminate
     triggers termination
   -alterDuration #
   -dur #
     length of time, in in-game ticks, for the syndrome to last if added
     0 means the syndrome is permanent
     DEFAULT: 0
   -announcement string
     optional argument to create an announcement and combat log report
  examples:
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end
syndromes = nil
classes = nil
if args.syndrome then
 if type(args.syndrome) ~= 'table' then
  syndromes = {args.syndrome}
 else
  syndromes = args.syndrome
 end
end
if args.class then
 if type(args.class) ~= 'table' then
  classes = {args.class}
 else
  classes = args.class
 end
end
if not syndromes and not classes then
 print('Neither syndrome name(s) or class(es) declared')
 return
end
dur = tonumber(args.dur) or 0
if dur < 0 then return end

if args.add then
 if syndromes then dfhack.script_environment('functions/unit').changeSyndrome(unit,syndromes,'add',dur) end
 if classes then print('Currently unable to add syndromes based on classes') return end
elseif args.erase then
 if syndromes then dfhack.script_environment('functions/unit').changeSyndrome(unit,syndromes,'erase',dur) end
 if classes then dfhack.script_environment('functions/unit').changeSyndrome(unit,classes,'eraseClass',dur) end
elseif args.terminate then
 if syndromes then dfhack.script_environment('functions/unit').changeSyndrome(unit,syndromes,'terminate',dur) end
 if classes then dfhack.script_environment('functions/unit').changeSyndrome(unit,classes,'terminateClass',dur) end
elseif args.alterDuration then
 if syndromes then dfhack.script_environment('functions/unit').changeSyndrome(unit,syndromes,'alterDuration',tonumber(args.alterDuration)) end
 if classes then dfhack.script_environment('functions/unit').changeSyndrome(unit,classes,'alterDurationClass',tonumber(args.alterDuration)) end
else
 print('No method declared (methods are add, erase, terminate, and alterDuration)')
 return
end
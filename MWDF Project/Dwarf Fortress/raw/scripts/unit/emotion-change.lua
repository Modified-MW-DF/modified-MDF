--unit/emotion-change.lua version 42.06a

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'thought',
 'subthought',
 'emotion',
 'number',
 'severity',
 'strength',
 'remove',
 'add',
 'dur',
 'syndrome',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/emotion-change
  Change the emotions/thoughts of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -thought
     Valid Types:
   -subthought
     Valid Types:
   -emotion
     Valid Types:
      Negative
      Positive
      EMOTION_TYPE
   -severity #
   -strength #
   -add
   -remove
     Valid Types:
      Recent
      Random
      All
   -number #
   -syndrome "syndrome name"
   -dur #
     length of time, in in-game ticks, for the emotion to last
     0 means the emotion is permanent (until the game removes it itself)
     DEFAULT: 0
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

if args.thought then
 thought=df.unit_thought_type[args.thought]
else
 thought = 180
end
if not thought then
 print('Invalid Thought')
 return
end

if args.emotion then
 if args.emotion == 'Positive' then
  print('Positive emotions not yet supported, still need to determine what is positive and what is negative')
  return
 elseif args.emotion == 'Negative' then
  print('Negative emotions not yet supported, still need to determine what is positive and what is negative')
  return
 else
  emotion=df.emotion_type[args.emotion]
 end
else
 emotion = -1
end
if not emotion then
 print('Invalid Emotion')
 return
end

if not args.remove and not args.add then
 task = 'Add'
elseif not args.remove and args.add then
 task = 'Add'
elseif args.remove and args.add then
 return
else
 task = args.remove
end

number = tonumber(args.number) or 1
dur = tonumber(args.dur) or 0
severity = tonumber(args.severity) or 0
strength = tonumber(args.strength) or 0
subthought = tonumber(args.subthought) or 0

dfhack.script_environment('functions/unit').changeEmotion(unit,thought,subthought,emotion,strength,severity,task,number,dur,args.syndrome)
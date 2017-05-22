--spells/trigger.lua

local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'

validArgs = validArgs or utils.invert({
 'help',
 'source',
 'target',
 'spell',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[spells/trigger
  arguments:
   -help
     print this help message
   -source id
   -target id
   -spell TOKEN
   -value
   -experience
   -cast_count
   -description
 ]])
 return
end

spell = persistTable.GlobalTable.roses.SpellTable[args.spell]
if not spell then
 print('No spell found in database')
 return
end
if args.source and tonumber(args.source) then
 source = args.source
 source_name = dfhack.unit.getVisibleName(df.unit.find(tonumber(source)))
end
if args.target and tonumber(args.target) then
 target = args.target
 target_name = dfhack.unit.getVisibleName(df.unit.find(tonumber(target)))
end

description = spell.description or ''
description:gsub('TARGET',target_name)
description:gsub('SOURCE',source_name)

script = spell.script or ''
script:gsub('SOURCE',source)
script:gsub('TARGET',target)
script:gsub('DESCRIPTION',description)
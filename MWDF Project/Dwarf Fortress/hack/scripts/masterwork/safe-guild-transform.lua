-- Safe Script written to do guild transformations.  Written by Amostubal.

local usage = [====[

safe-guild-transform
====================
Wrapper for transform, used by Masterwork for the purpose of providing safe
unit transformations for guild mod purposes.  Removes the need to check the 
gender of the unit prior to sending them to be transformed.  This script 
provides the necessary remedies to that issue.  Guild castes tokens should be
written with _MALE and _FEMALE appended to the end of the file.

This Wrapper will also check for "race compliance", to keep non dwarves from
being turned into dwarves.

Arguments::

    -unit id
        set the target unit
    -guild
        guild name as written in caste minus _MALE and _FEMALE
    -race
        race name

]====]
local utils=require 'utils'

validArgs = validArgs or utils.invert ({
 'help',
 'unit',
 'guild',
 'race'
})

local args = utils.processArgs({...}, validArgs)

if not ... or args.help then
  print(usage)
  return
end

if not args.unit then
  error 'specify a unit'
end

if not args.race or not args.guild then
  error 'Specficy a target form.'
end

local unit = df.unit.find(tonumber(args.unit))

if args.race == tostring(df.global.world.raws.creatures.all[unit.race].creature_id) then

  local suffix
  if unit.sex == 1 then
    suffix = "_MALE"
  else
    suffix = "_FEMALE"
  end

  args.guild=args.guild..suffix

  dfhack.run_script('modtools/transform-unit', '-unit', unit.id, '-race', args.race, '-caste', args.guild, '-keepInventory', 1)

else
  error 'attempted to change the race of a unit, reject transformation.'
end


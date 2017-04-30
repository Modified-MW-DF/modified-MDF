-- repeatedly call a lua script
-- eg "repeat -time 1 months -command cleanowned"; to disable "repeat -cancel cleanowned"
-- author expwnent
-- vaguely based on a script by Putnam
local usage = [====[

repeat
======
Repeatedly calls a lua script at the specified interval.  This allows
neat background changes to the function of the game, especially when
invoked from an init file.

Usage examples::

    repeat -name jim -time delay -timeUnits units -command [ printArgs 3 1 2 ]
    repeat -time 1 -timeUnits months -command [ multicmd cleanowned scattered x; clean all ] -name clean

The first example is abstract; the second will regularly remove all contaminants
and worn items from the game.

Arguments:

``-name``
    sets the name for the purposes of cancelling and making sure you
    don't schedule the same repeating event twice.  If not specified,
    it's set to the first argument after ``-command``.
``-time DELAY -timeUnits UNITS``
    DELAY is some positive integer, and UNITS is some valid time
    unit for ``dfhack.timeout`` (default "ticks").  Units can be
    in simulation-time "frames" (raw FPS) or "ticks" (only while
    unpaused), while "days", "months", and "years" are by in-world time.
``-command [ ... ]``
    ``...`` specifies the command to be run
``-cancel NAME``
    cancels the repetition with the name NAME

]====]

local repeatUtil = require 'repeat-util'
local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'cancel',
 'name',
 'time',
 'timeUnits',
 'command'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if args.cancel then
 repeatUtil.cancel(args.cancel)
 if args.name then
  repeatUtil.cancel(args.name)
 end
 return
end

args.time = tonumber(args.time)
if not args.name then
 args.name = args.command[1]
end

if not args.timeUnits then
 args.timeUnits = 'ticks'
end

local callCommand = function()
 dfhack.run_command(table.unpack(args.command))
end

repeatUtil.scheduleEvery(args.name,args.time,args.timeUnits,callCommand)


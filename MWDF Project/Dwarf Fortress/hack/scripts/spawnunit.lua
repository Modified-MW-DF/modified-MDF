-- create unit at pointer or given location
-- wraps modtools/create-unit.lua
local usage = [====[

spawnunit
=========
Provides a simpler interface to `modtools/create-unit`, for creating units.

Usage:  ``spawnunit [-command] RACE CASTE [NAME] [x y z] [...]``

The ``-command`` flag prints the generated `modtools/create-unit` command
instead of running it.  ``RACE`` and ``CASTE`` specify the race and caste
of the unit to be created.  The name and coordinates of the unit are optional.
Any further arguments are simply passed on to `modtools/create-unit`.

]====]

function extend(tbl, tbl2)
    for _, v in pairs(tbl2) do
        table.insert(tbl, v)
    end
end

local show_command = false
local args = {...}
local first_arg = (args[1] or ''):gsub('^-*', '')
if first_arg == 'help' or #args < 2 then
    print(usage)
    return
elseif first_arg == 'command' then
    show_command = true
    table.remove(args, 1)
end

local new_args = {'-race', args[1], '-caste', args[2]}
if #args == 3 then
    extend(new_args, {'-nick', args[3]})
elseif #args == 6 then
    if tonumber(args[4]) and tonumber(args[5]) and tonumber(args[6]) then
        extend(new_args, {'-nick', args[3], '-location', '[', args[4], args[5], args[6], ']'})
    end
else
    local start = 3
    if #args >= 3 and args[3]:sub(1, 1) ~= '-' then
        extend(new_args, {'-nick', args[3]})
        start = 4
    end
    for i = start, #args do
        table.insert(new_args, args[i])
    end
end
if show_command then
    print('modtools/create-unit ' .. table.concat(new_args, ' '))
    return
end
dfhack.run_script('modtools/create-unit', table.unpack(new_args))

-- send a key to the current screen or a parent
--[====[

devel/send-key
==============
Send a key to the current screen or a parent

Usage:

:devel/send-key KEY_NAME:   Send KEY_NAME
:devel/send-key KEY_NAME X: Send KEY_NAME to the screen ``X`` screens above
                                the current screen

]====]
args = {...}
key = df.interface_key[args[1]]
if not key then qerror('Unrecognized key') end
gui = require 'gui'
p = tonumber(args[2])
scr = dfhack.gui.getCurViewscreen()
if p ~= nil then
    while p > 0 do
        p = p - 1
        scr = scr.parent
    end
end
gui.simulateInput(scr, key)

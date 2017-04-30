-- Toggle display of water depth
--[====[

twaterlvl
=========
Toggle between displaying/not displaying liquid depth as numbers.

]====]

df.global.d_init.flags1.SHOW_FLOW_AMOUNTS = not df.global.d_init.flags1.SHOW_FLOW_AMOUNTS
print('Water level display toggled.')

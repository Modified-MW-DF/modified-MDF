--Manipulates the parameters of the region in focus pre embark. Use ? for help. 
--NOTE: Manipulations made are NOT permanent. They will be applied to the embark if the user embarks while
--the region is still in focus, but they will be discarded as soon as the focus is shifted. They are also
--lost for any subsequent embarks in the same region (but the previous embark will still retain the effects
--of the changes in place when it was embarked upon). It is unknown what effects manipulations have on
--Adventure Mode, but weird discontinuities are likely at the border between an abandoned/retired embark
--generated while under manipulation influence and the region itself (which is back to its original state).
--[====[

regionmanipulator
========
]====]
function regionmanipulator ()
  if not dfhack.isWorldLoaded () then
	dfhack.color (COLOR_RED)
    dfhack.print("Error: This script requires a world to be loaded.")
	dfhack.color(COLOR_RESET)
	dfhack.println()
	return
  end

  if dfhack.isMapLoaded() then
	dfhack.color (COLOR_RED)
    dfhack.print("Error: This script requires a world to be loaded, but not a map.")
	dfhack.color(COLOR_RESET)
	dfhack.println()
	return
  end

  local gui = require 'gui'
  local dialog = require 'gui.dialogs'
  local widgets =require 'gui.widgets'
  local guiScript = require 'gui.script'

  local map_width = df.global.world.world_data.world_width
  local map_height = df.global.world.world_data.world_height
  local Excess_Soil_Warning = false
  local cursor_x = df.global.world.world_data.region_details [0].pos.x
  local cursor_y = df.global.world.world_data.region_details [0].pos.y  
--  local biome = df.global.world.world_data.region_map [cursor_x]:_displace(cursor_y)
  local x = 0
  local y = 0
  local max_x = 16
  local max_y = 16
  local focus = "Elevation"
  local region = df.global.world.world_data.region_details [0]

  local keybindings = {
    elevation = {key = "CUSTOM_E",
	             desc = "Displays elevation"},
	biome = {key = "CUSTOM_B",
	         desc = "Displays biome"},
	rivers = {key = "CUSTOM_R",
	         desc = "Displays rivers"},
	change = {key = "CUSTOM_C",
	        desc = "Edit the elevation/biome value of the current region tile"},
	flatten = {key = "CUSTOM_F",
	           desc = "Flatten the region to the elevation of the current region tile"},
    rivers_elevation = {key = "CUSTOM_SHIFT_E",
	                    desc = "Change river elevation on the current region tile"},
	rivers_vertical_active = {key = "CUSTOM_V",
	                          desc = "Change rivers_vertical.active"},
    rivers_vertical_x_min = {key = "CUSTOM_X",
	                         desc = "Change rivers_vertical.x_min"},
    rivers_vertical_x_max = {key = "CUSTOM_SHIFT_X",
	                         desc = "Change rivers_vertical.x_max"},
	rivers_horizontal_active = {key = "CUSTOM_H",
	                          desc = "Change rivers_horizontal.active"},
    rivers_horizontal_y_min = {key = "CUSTOM_Y",
	                         desc = "Change rivers_horizontal.y_min"},
    rivers_horizontal_y_max = {key = "CUSTOM_SHIFT_Y",
	                         desc = "Change rivers_horizontal.y_max"},
    up = {key = "CURSOR_UP",
	      desc = "Shifts focus 1 step upwards"},
    down = {key = "CURSOR_DOWN",
	        desc = "Shifts focus 1 step downwards"},
	left = {key = "CURSOR_LEFT",
	        desc = "Shifts focus 1 step to the left"},
    right = {key = "CURSOR_RIGHT",
	         desc = "Shift focus 1 step to the right"},
	upleft = {key = "CURSOR_UPLEFT",
	          desc = "Shifts focus 1 step up to the left"},
    upright = {key = "CURSOR_UPRIGHT",
	           desc = "Shifts focus 1 step up to the right"},
	downleft = {key = "CURSOR_DOWNLEFT",
	            desc = "Shifts focus 1 step down to the left"},
    downright = {key = "CURSOR_DOWNRIGHT",
	             desc = "Shifts focus 1 step down to the right"},
    help = {key = "HELP",
            desc= " Show this help/info"}}
			
  --============================================================

  function Range_Color (arg)
    if arg < 100 then
      return COLOR_WHITE
    elseif arg < 110 then
      return COLOR_LIGHTCYAN
    elseif arg < 120 then
      return COLOR_CYAN
    elseif arg < 130 then
      return COLOR_LIGHTBLUE
    elseif arg < 140 then
      return COLOR_BLUE
    elseif arg < 150 then
      return COLOR_LIGHTGREEN
    elseif arg < 160 then
      return COLOR_GREEN
    elseif arg < 170 then
      return COLOR_YELLOW
    elseif arg < 180 then
      return COLOR_LIGHTMAGENTA
    elseif arg < 190 then
      return COLOR_LIGHTRED
    elseif arg < 200 then
      return COLOR_RED
    elseif arg < 210 then
      return COLOR_GREY
    else
      return COLOR_DARKGREY
    end
  end

  --============================================================

  function Make_Elevation (x, y)
    local tElevation = 
	  {{text = "Help/Info",
        key = keybindings.help.key,
        key_sep = '()'}, 
		" X = ",
		tostring (x),
		", Y = ",
		tostring (y),
        " Region Elevation\n" ..
		"Current value: " .. tostring (region.elevation [x] [y]) .. "\n\n"}

	local end_x = #region.elevation - 1
	local end_y = #region.elevation [0] - 1
		 
    for k = 0,  end_y do
	  for i = 0, end_x do
	    if i == x and k == y then
          table.insert (tElevation,
             {text = tostring (region.elevation [i] [k] % 10),
              pen = dfhack.pen.parse
                {fg = COLOR_BLACK, bg = Range_Color (region.elevation [i] [k]), tile_color = true}})

          table.insert (tElevation,
						{text = "",
						 pen = dfhack.pen.parse
						  {bg = COLOR_BLACK, tile_color = false}})
							
		else
          table.insert (tElevation,
             {text = tostring (region.elevation [i] [k] % 10),
              pen = dfhack.pen.parse {fg = Range_Color (region.elevation [i] [k]),
              bg = 0}})
		end		
	  end
	  
	  table.insert(tElevation,"\n")
	end

	return tElevation
  end
  
  --============================================================
  
  function Make_Biome (x, y)
    local tBiome = 
	  {{text = "Help/Info",
        key = keybindings.help.key,
        key_sep = '()'}, 
		" X = ",
		tostring (x),
		", Y = ",
		tostring (y),
        " Region Biome\n" .. 
		"Current value: " .. tostring (region.biome [x] [y]) .. "\n\n"}
		
  local end_x = #region.biome - 1
  local end_y = #region.biome [0] - 1
	
    for k = 0, end_y do
	  for i = 0, end_x do
	    if i == x and k == y then
          table.insert (tBiome,
             {text = tostring (region.biome [i] [k]),
              pen = dfhack.pen.parse
                {fg = COLOR_BLACK, bg = Range_Color (region.biome [i] [k] * 10 + 100), tile_color = true}})

          table.insert (tBiome,
						{text = "",
						 pen = dfhack.pen.parse
						  {bg = COLOR_BLACK, tile_color = false}})
							
		else
          table.insert (tBiome,
             {text = tostring (region.biome [i] [k]),
              pen = dfhack.pen.parse {fg = Range_Color (region.biome [i] [k] * 10 + 100),
              bg = 0}})
		end		
	  end
	  
	  table.insert(tBiome,"\n")
	end
	
	return tBiome
  end
  
  --============================================================

  function Fit (Item, Size)
	return Item .. string.rep (' ', Size - string.len (Item))
  end
   
  --===========================================================================

  function Fit_Right (Item, Size)
	return string.rep (' ', Size - string.len (Item)) .. Item
  end
   
  --===========================================================================

  function River_Elevation_Image (elevation)
    if not elevation then
	  return ""
	else
	  return "River Elevation: " .. tostring (elevation)
	end
  end
  
  --============================================================
  
  function Make_Rivers (x, y)
    local river_elevation
	local rivers_vertical_active_string
	local rivers_vertical_x_min_string
	local rivers_vertical_x_max_string
	local rivers_horizontal_active_string
	local rivers_horizontal_y_min_string
	local rivers_horizontal_y_max_string
	
	if region.rivers_vertical.active [x] [y] ~= 0 then
	  river_elevation = region.rivers_vertical.elevation [x] [y]
	  
	elseif region.rivers_horizontal.active [x] [y] ~= 0 then
	  river_elevation = region.rivers_horizontal.elevation [x] [y]
	  
	else
	  river_elevation = NIL
	end
	
	if region.rivers_vertical.active [x] [y] == 0 then
	  rivers_vertical_active_string = Fit ("", 17)
	  rivers_vertical_x_min_string = Fit ("", 17)
	  rivers_vertical_x_max_string = Fit ("", 17)
	
    else	
	  if region.rivers_vertical.active [x] [y] == 1 then
	    rivers_vertical_active_string = "Vertical: South  "	  
	  
	  else
	    rivers_vertical_active_string = "Vertical: North  "
	  end
	  
	  rivers_vertical_x_min_string = Fit ("x Min: " .. tostring (region.rivers_vertical.x_min [x] [y]), 17)
	  rivers_vertical_x_max_string = Fit ("X Max: " .. tostring (region.rivers_vertical.x_max [x] [y]), 17)
	end
	
	if region.rivers_horizontal.active [x] [y] == 0 then
	  rivers_horizontal_active_string = ""
	  rivers_horizontal_y_min_string = ""
	  rivers_horizontal_y_max_string = ""
	  
	else
	  if region.rivers_horizontal.active [x] [y] == 1 then
	    rivers_horizontal_active_string = "Horizontal: West"
	  
	  else
	    rivers_horizontal_active_string = "Horizontal: East"
	  end
	  
	  rivers_horizontal_y_min_string = "y Min: " .. tostring (region.rivers_horizontal.y_min [x] [y])
	  rivers_horizontal_y_max_string = "Y Max: " .. tostring (region.rivers_horizontal.y_max [x] [y])
	end

    local tRivers = 
	  {{text = "Help/Info",
        key = keybindings.help.key,
        key_sep = '()'}, 
		" X = ",
		tostring (x),
		", Y = ",
		tostring (y),
        " Region Rivers\n" ..
		"Current Region elevation: " .. tostring (region.elevation [x] [y]) .. "\n" ..
		River_Elevation_Image (river_elevation) .. "\n" ..
		rivers_vertical_active_string .. rivers_horizontal_active_string .. "\n" ..
        rivers_vertical_x_min_string .. rivers_horizontal_y_min_string .. "\n" ..
        rivers_vertical_x_max_string .. rivers_horizontal_y_max_string .. "\n\n"}
		
	local last = #region.rivers_vertical.elevation - 1
		 
    for k = 0, last do
	  for i = 0, last do
	    if region.rivers_vertical.active [i] [k] ~= 0 then
	      if i == x and k == y then
            table.insert (tRivers,
               {text = tostring (region.rivers_vertical.elevation [i] [k] % 10),
                pen = dfhack.pen.parse
                  {fg = COLOR_BLACK, bg = Range_Color (region.rivers_vertical.elevation [i] [k]), tile_color = true}})

            table.insert (tRivers,
			 			  {text = "",
						   pen = dfhack.pen.parse
						    {bg = COLOR_BLACK, tile_color = false}})
							
		  else
            table.insert (tRivers,
               {text = tostring (region.rivers_vertical.elevation [i] [k] % 10),
                pen = dfhack.pen.parse {fg = Range_Color (region.rivers_vertical.elevation [i] [k]),
                bg = 0}})
		  end	
		  
		elseif region.rivers_horizontal.active [i] [k] ~= 0 then
	      if i == x and k == y then
            table.insert (tRivers,
               {text = tostring (region.rivers_horizontal.elevation [i] [k] % 10),
                pen = dfhack.pen.parse
                  {fg = COLOR_BLACK, bg = Range_Color (region.rivers_horizontal.elevation [i] [k]), tile_color = true}})

            table.insert (tRivers,
			 			  {text = "",
						   pen = dfhack.pen.parse
						    {bg = COLOR_BLACK, tile_color = false}})
							
		  else
            table.insert (tRivers,
               {text = tostring (region.rivers_horizontal.elevation [i] [k] % 10),
                pen = dfhack.pen.parse {fg = Range_Color (region.rivers_horizontal.elevation [i] [k]),
                bg = 0}})
		  end	
		  
		else
	      if i == x and k == y then
            table.insert (tRivers,
               {text = "X",
                pen = dfhack.pen.parse {fg = COLOR_DARKGREY,
                bg = 0}})
		  else
            table.insert (tRivers,
               {text = ".",
                pen = dfhack.pen.parse {fg = COLOR_DARKGREY,
                bg = 0}})
		  end
		end
	  end
		
	  table.insert(tRivers,"\n")
	end

	return tRivers
  end
  
  --============================================================
  
  function Update (x, y, pages)    
    local elevationPage = widgets.Panel {
      subviews =
        {widgets.Label {text = Make_Elevation (x, y),
           frame = {l = 1, t = 1, yalign = 0}}}}

    pages.subviews [1].subviews [1].text_lines = elevationPage.subviews [1].text_lines

    local biomePage = widgets.Panel {
      subviews =
        {widgets.Label {text = Make_Biome (x, y),
           frame = {l = 1, t = 1, yalign = 0}}}}

    pages.subviews [2].subviews [1].text_lines = biomePage.subviews [1].text_lines

    local riversPage = widgets.Panel {
      subviews =
        {widgets.Label {text = Make_Rivers (x, y),
           frame = {l = 1, t = 1, yalign = 0}}}}

    pages.subviews [3].subviews [1].text_lines = riversPage.subviews[1].text_lines	
  end
  
  --============================================================

  function Pan_Help ()
    local helptext = {{text="Help/Info"}, NEWLINE, NEWLINE}
	 
	for i = 1, help_length do
	  if i <= normal_key_index then
	    table.insert (helptext, {text = normal_key [i].desc, key = normal_key [i].key, key_sep = ": "})
	  else
	    table.insert (helptext, string.rep (" ", string.len (normal_key [1].desc) + 3))
	  end
	  
	  if i <= move_key_index then
	    table.insert (helptext, {text = move_key [i].desc, key = move_key [i].key, key_sep = ": "})
	  end
	  table.insert (helptext, NEWLINE)
	end

    table.insert(helptext, NEWLINE)

--    for line = help_y, #help_screen do
--	  for column = help_x, #help_screen [line] do
--	    table.insert (helptext, help_screen [line] [column])
--	  end
--	end
	
	return helptext
  end

  --============================================================

  RegionManipulatorUi = defclass (RegionManipulatorUi, gui.FramedScreen)
  RegionManipulatorUi.ATTRS = {
    frame_style = gui.GREY_LINE_FRAME,
    frame_title = "Region Manipulator",
  }

  --============================================================

  function RegionManipulatorUi:onHelp ()
    self.subviews.pages:setSelected (4)
	base_focus = focus
	focus = "Help"
  end

  --============================================================

  function Disclaimer ()
    local helptext = {{text = "Help/Info"}, NEWLINE, NEWLINE}
	 
   for i, v in pairs (keybindings) do
        table.insert (helptext, {text = v.desc, key = v.key, key_sep = ': '})
        table.insert (helptext, NEWLINE)
	end

    table.insert (helptext, NEWLINE)
    local dsc = 
	  {"The Region Manipulator is used pre embark to manipulate the region where the embark", NEWLINE,
	   "is intended to be performed. Due to the way DF works, any manipulation performed on", NEWLINE,
	   "the region is lost/discarded once DF's focus is changed to another region and", NEWLINE,
	   "is lost when returned. Similarly, Embarking anew in the same region as a previous", NEWLINE,
	   "fortress will have the region manipulations performed prior to the previous embark", NEWLINE,
	   "reversed on the region level, but their effects are 'frozen' in the fortress itself.", NEWLINE,
	   "However, manipulation and manipulation reversal can probably cause interesting effects", NEWLINE,
	   "if an adventurer was to visit such a fortress.", NEWLINE,
	   "Manipulations are effected immediately in DF, but the 'erase' function inherent in DF", NEWLINE,
	   "can be used to remove them (just swich the focus to a different region and back)", NEWLINE,
	   "The Region Manipulator allows you to change region level elevations, biomes, and rivers.", NEWLINE,
	   "'c' used on the Elevation view allows you to change the elevation value on that tile,", NEWLINE,
	   "while 'f' allows you to flatten the whole region by making all tiles the same elevation", NEWLINE,
	   "as the current one.", NEWLINE,
	   "'c' on the Biome view allows you to select the dominant biome in the tile from the ones", NEWLINE,
	   "associated with the current world tile and the 8 surrounding tiles. This tool does not", NEWLINE,
	   "help you telling what the are, but DF itself does.", NEWLINE,
	   "Manipulating rivers on the Rivers screen is ... messy, but can give rather spectacular", NEWLINE,
	   "results. The River Elevation specifies the level at which the water flows, and DF will", NEWLINE,
	   "cut a sheer gorge down to that level if below the Region Elevation, or make an 'aqueduct'", NEWLINE,
	   "if above it. Waterfalls can be created by making the down river River Elevation lower", NEWLINE,
	   "than the upriver one, while the reverse is ignored (water won't jump up).", NEWLINE,
	   "The messy part is making and changing river courses, and the author hasn't quite figured", NEWLINE,
	   "out what the rules are: you need to experiment. However, it was possible to create a 3*3", NEWLINE,
	   "embark where the center tile was surrounded by a bifurcating river that rejoined at the", NEWLINE,
	   "other side, creating a natural moat with a waterfall one each side. The embark team was", NEWLINE,
	   "spawned at the bottom of the gorge, however, so it was fortunate it was a brook...", NEWLINE,
	   "Elevations are color coded. The color ranges are:", NEWLINE,
	   {text = "WHITE        < 100, with the actual decile lost.", pen = dfhack.pen.parse {fg = COLOR_WHITE, bg = 0}}, NEWLINE,
	   {text = "LIGHT CYAN     100 - 109", pen = dfhack.pen.parse {fg = COLOR_LIGHTCYAN, bg = 0}}, NEWLINE,
	   {text = "CYAN           110 - 119", pen = dfhack.pen.parse {fg = COLOR_CYAN, bg = 0}}, NEWLINE,
	   {text = "LIGHT BLUE     120 - 129", pen = dfhack.pen.parse {fg = COLOR_LIGHTBLUE, bg = 0}}, NEWLINE,
	   {text = "BLUE           130 - 139", pen = dfhack.pen.parse {fg = COLOR_BLUE, bg = 0}}, NEWLINE,
	   {text = "LIGHT GREEN    140 - 149", pen = dfhack.pen.parse {fg = COLOR_LIGHTGREEN, bg = 0}}, NEWLINE,
	   {text = "GREEN          150 - 159", pen = dfhack.pen.parse {fg = COLOR_GREEN, bg = 0}}, NEWLINE,
	   {text = "YELLOW         160 - 169", pen = dfhack.pen.parse {fg = COLOR_YELLOW, bg = 0}}, NEWLINE,
	   {text = "LIGHT MAGENTA  170 - 179", pen = dfhack.pen.parse {fg = COLOR_LIGHTMAGENTA, bg = 0}}, NEWLINE,
	   {text = "LIGHT RED      180 - 189", pen = dfhack.pen.parse {fg = COLOR_LIGHTRED, bg = 0}}, NEWLINE,
	   {text = "RED            190 - 199", pen = dfhack.pen.parse {fg = COLOR_RED, bg = 0}}, NEWLINE,
	   {text = "GREY           200 - 219", pen = dfhack.pen.parse {fg = COLOR_GREY, bg = 0}}, NEWLINE,
	   {text = "DARK GREY    > 219, with the actual decile lost.", pen = dfhack.pen.parse {fg = COLOR_DARKGREY, bg = 0}}, NEWLINE, NEWLINE,
	   "Version 0.1, 2017-05-15", NEWLINE,
	   "Caveats: As indicated above, region manipulation has the potential to mess up adventure", NEWLINE,
	   "mode seriously. Similarly, changing things in silly ways can result in any kind of", NEWLINE,
	   "reaction from DF, so don't be surprised if DF crashes (no crashes have been noted so far).", NEWLINE
       }

    for i, v in pairs (dsc) do
      table.insert (helptext, v)
	end
	
	return helptext
  end

  --============================================================

  function RegionManipulatorUi:init ()
    self.stack = {}
    self.item_count = 0
    self.keys = {}
	
    local elevationPage = widgets.Panel {
        subviews =
         {widgets.Label {text = Make_Elevation (x, y),
            frame = {l = 1, t = 1, yalign = 0}}}}

    local biomePage = widgets.Panel {
        subviews =
         {widgets.Label {text = Make_Biome (x, y),
            frame = {l = 1, t = 1, yalign = 0}}}}

    local riversPage = widgets.Panel {
        subviews =
         {widgets.Label {text = Make_Rivers (x, y),
            frame = {l = 1, t = 1, yalign = 0}}}}

    local helpPage = widgets.Panel {
        subviews = {widgets.Label {text = Disclaimer (),
                    frame = {l = 1, t = 1, yalign = 0}}}}

    local pages = widgets.Pages 
      {subviews = {elevationPage,
	               biomePage,
				   riversPage,
                   helpPage},view_id = "pages"}

    self:addviews {
        pages
    }
  end

  --============================================================

  function RegionManipulatorUi:updateElevation (value)
    if not tonumber (value) or 
	   tonumber (value) < 1 or 
	   tonumber (value) > 250 then
	  dialog.showMessage ("Error!", "The Elevation legal range is 1 - 250", COLOR_RED)
	else
      region.elevation [x] [y] = tonumber (value)
	end
	
	Update (x, y, self.subviews.pages)	  
  end
  
  --==============================================================
  
  function RegionManipulatorUi:updateBiome (value)
    if not tonumber (value) or 
	   tonumber (value) < 1 or 
	   tonumber (value) > 9 then
	  dialog.showMessage ("Error!", "The Biome legal range is 1 - 9", COLOR_RED)
	else
      region.biome [x] [y] = tonumber (value)
	end
	
	Update (x, y, self.subviews.pages)	  
  end
  
  --==============================================================

  function RegionManipulatorUi:flattenRegion ()
	for i = 0, #region.elevation - 1 do
	  for k = 0, #region.elevation [0] -1 do
	    region.elevation [i] [k] = region.elevation [x] [y]
	  end
	end
	
	Update (x, y, self.subviews.pages)
  end
  
  --==============================================================
  
  function RegionManipulatorUi:updateRiversElevation (value)
    if not tonumber (value) or 
	   tonumber (value) < 1 or 
	   tonumber (value) > 250 then
	  dialog.showMessage ("Error!", "The Elevation legal range is 1 - 250", COLOR_RED)

    else
      if region.rivers_horizontal.active [x] [y] ~= 0 then
	    region.rivers_horizontal.elevation [x] [y] = tonumber (value)
	  end

      if region.rivers_vertical.active [x] [y] ~= 0 then
	    region.rivers_vertical.elevation [x] [y] = tonumber (value)
	  end
	end
	
	Update (x, y, self.subviews.pages)
  end
  
  --==============================================================
  
  function RegionManipulatorUi:updateRiversVerticalActive (value)
    if value == 1 or
	   value == 2 then
	  if region.rivers_vertical.active [x] [y] == 0 then
	    region.rivers_vertical.x_min [x] [y] = 23
        region.rivers_vertical.x_max [x] [y] = 25

        if region.rivers_horizontal.active [x] [y] ~= 0 then
		  region.rivers_vertical.elevation [x] [y] = region.rivers_horizontal.elevation [x] [y]
		  
        else
		  region.rivers_vertical.elevation [x] [y] = region.elevation [x] [y]
        end
      end	  

	  if value == 1 then
        region.rivers_vertical.active [x] [y] = 1
	  else
        region.rivers_vertical.active [x] [y] = -1
      end
	  	  
	elseif value == 3 then
	  region.rivers_vertical.active [x] [y] = 0
	  region.rivers_vertical.elevation [x] [y] = 100
	  region.rivers_vertical.x_min [x] [y] = -30000
	  region.rivers_vertical.x_max [x] [y] = -30000
	end
	
	Update (x, y, self.subviews.pages)
  end

  --==============================================================
  
  function RegionManipulatorUi:updateRiversVerticalXMin (value)
    if not tonumber (value) or
	   tonumber (value) < 0 or
	   tonumber (value) > 47 then
	  dialog.showMessage ("Error!", "The X Min legal range is 0 - 47", COLOR_RED)
	
	elseif tonumber (value) > region.rivers_vertical.x_max [x] [y] then
	  dialog.showMessage ("Error!", "The X Min value cannot be larger than X Max", COLOR_RED)
	  
	else
	  region.rivers_vertical.x_min [x] [y] = tonumber (value)
	end
	
	Update (x, y, self.subviews.pages)
  end
  
  --==============================================================
  
  function RegionManipulatorUi:updateRiversVerticalXMax (value)
    if not tonumber (value) or
	   tonumber (value) < 0 or
	   tonumber (value) > 47 then
	  dialog.showMessage ("Error!", "The X Max legal range is 0 - 47", COLOR_RED)
	
	elseif tonumber (value) < region.rivers_vertical.x_min [x] [y] then
	  dialog.showMessage ("Error!", "The X Max value cannot be smaller than X Min", COLOR_RED)
	  
	else
	  region.rivers_vertical.x_max [x] [y] = tonumber (value)
	end
	
	Update (x, y, self.subviews.pages)
  end
  
  --==============================================================
  
  function RegionManipulatorUi:updateRiversHorizontalActive (value)
    if value == 1 or
	   value == 2 then
	  if region.rivers_horizontal.active [x] [y] == 0 then
	    region.rivers_horizontal.y_min [x] [y] = 23
        region.rivers_horizontal.y_max [x] [y] = 25

        if region.rivers_vertical.active [x] [y] ~= 0 then
		  region.rivers_horizontal.elevation [x] [y] = region.rivers_vertical.elevation [x] [y]
		  
        else
		  region.rivers_horizontal.elevation [x] [y] = region.elevation [x] [y]
        end
      end	  

	  if value == 1 then
        region.rivers_horizontal.active [x] [y] = 1
	  else
        region.rivers_horizontal.active [x] [y] = -1
      end
	  	  
	elseif value == 3 then
	  region.rivers_horizontal.active [x] [y] = 0
	  region.rivers_horizontal.elevation [x] [y] = 100
	  region.rivers_horizontal.y_min [x] [y] = -30000
	  region.rivers_horizontal.y_max [x] [y] = -30000
	end
	
	Update (x, y, self.subviews.pages)
  end

  --==============================================================
  
  function RegionManipulatorUi:updateRiversHorizontalYMin (value)
    if not tonumber (value) or
	   tonumber (value) < 0 or
	   tonumber (value) > 47 then
	  dialog.showMessage ("Error!", "The Y Min legal range is 0 - 47", COLOR_RED)
	
	elseif tonumber (value) > region.rivers_horizontal.y_max [x] [y] then
	  dialog.showMessage ("Error!", "The Y Min value cannot be larger than Y Max", COLOR_RED)
	  
	else
	  region.rivers_horizontal.y_min [x] [y] = tonumber (value)
	end
	
	Update (x, y, self.subviews.pages)
  end
  
  --==============================================================
  
  function RegionManipulatorUi:updateRiversHorizontalYMax (value)
    if not tonumber (value) or
	   tonumber (value) < 0 or
	   tonumber (value) > 47 then
	  dialog.showMessage ("Error!", "The Y Max legal range is 0 - 47", COLOR_RED)
	
	elseif tonumber (value) < region.rivers_horizontal.y_min [x] [y] then
	  dialog.showMessage ("Error!", "The Y Max value cannot be smaller than Y Min", COLOR_RED)
	  
	else
	  region.rivers_horizontal.y_max [x] [y] = tonumber (value)
	end
	
	Update (x, y, self.subviews.pages)
  end

  --==============================================================
  
  function RegionManipulatorUi:onInput (keys)
    if keys.LEAVESCREEN_ALL  then
        self:dismiss ()
    end
    
    if keys.LEAVESCREEN then
	  if focus == "Help" then
	    focus = base_focus
		
		if focus == "Elevation" then
          self.subviews.pages:setSelected (1)

	    elseif focus == "Biome" then
          self.subviews.pages:setSelected (2)
		  
		elseif focus == "Rivers" then
		  self.subviews.pages:setSelected (3)
        end
		
	  else
        self:dismiss ()
	  end
    end

    if keys [keybindings.elevation.key] then 
      self.subviews.pages:setSelected (1)
	  focus = "Elevation"

    elseif keys [keybindings.biome.key] then
      self.subviews.pages:setSelected (2)
	  focus = "Biome"

    elseif keys [keybindings.rivers.key] then 
      self.subviews.pages:setSelected (3)
	  focus = "Rivers"
	  
	elseif keys [keybindings.change.key] then
	  if focus == "Elevation" then
        dialog.showInputPrompt ("Elevation",
                                "1 - 99 is ocean\n" ..
			  				    "100 - 149 is normal terrain\n" ..
							    "150 - 250 is mountain\n" ..
	                            "Elevation (" .. tostring (region.elevation [x] [y]) .."):",
							    COLOR_WHITE,
							    "",
							    self:callback ("updateElevation"))
							 
	  elseif focus == "Biome" then
        dialog.showInputPrompt ("Biome",
                                "Take on the biome of a world tile\n" ..
								"7 : NW 8 : N   9 : NE\n" ..
			  				    "4 : E  5 : Own 6 : E\n" ..
								"1 : SW 2 : S   3 : SE\n" ..
	                            "Biome (" .. tostring (region.biome [x] [y]) .."):",
							    COLOR_WHITE,
							    "",
							    self:callback ("updateBiome"))								
	  end
	  
	elseif keys [keybindings.flatten.key] then
	  if focus == "Elevation" then
	    dialog.showYesNoPrompt ("Flatten Terrain?",
		                        "The whole region will be set to an elevation of " .. tostring (region.elevation [x] [y]) .. " on Enter.",
								COLOR_WHITE,
								NIL,
								self:callback ("flattenRegion"))
	  end
	  
	elseif keys [keybindings.rivers_elevation.key] then
	  if focus == "Rivers" then
	    if region.rivers_vertical.active [x] [y] ~= 0 or
		   region.rivers_horizontal.active [x] [y] ~= 0 then
		  local elevation
		   
		  if region.rivers_vertical.active [x] [y] ~= 0 then
		    elevation = region.rivers_vertical.elevation [x] [y]
			 
		  else
		    elevation = region.rivers_horizontal.elevation [x] [y]
		  end
		  
          dialog.showInputPrompt ("River Elevation",
                                  "1 - 99 is ocean\n" ..
			  				      "100 - 149 is normal terrain\n" ..
							      "150 - 250 is mountain\n" ..
	                              "Elevation (" .. tostring (elevation) .. "):",
							      COLOR_WHITE,
							      "",
							      self:callback ("updateRiversElevation"))							 
	    end
	  end
	  
	elseif keys [keybindings.rivers_vertical_active.key] then
	  if focus == "Rivers" then
	      local active_string
          local List = {"South",
		                "North",
						"Disabled"}
		  
		  if region.rivers_vertical.active [x] [y] == 0 then
		    active_string = "Disabled"
			
		  elseif region.rivers_vertical.active [x] [y] == 1 then
		    active_string = "South"
			
		  else
		    active_string = "North"
		  end
		  
	      dialog.showListPrompt ("River Vertical Active:", 
		                         "Current: " .. active_string,
								 COLOR_WHITE,
								 List,
								 self:callback ("updateRiversVerticalActive"))
	  end
	  
	elseif keys [keybindings.rivers_vertical_x_min.key] then
	  if focus == "Rivers" and
	    region.rivers_vertical.active [x] [y] ~= 0 then
        dialog.showInputPrompt ("River Vertical X Min",
                                "0 - 47 in 2 m tiles\n" ..
		  				        "X Min (" .. tostring (region.rivers_vertical.x_min [x] [y]) .. "):",
							    COLOR_WHITE,
							    "",
							    self:callback ("updateRiversVerticalXMin"))							 
	    
	  end
	  
	elseif keys [keybindings.rivers_vertical_x_max.key] then
	  if focus == "Rivers" and
	    region.rivers_vertical.active [x] [y] ~= 0 then
        dialog.showInputPrompt ("River Vertical X Max",
                                "0 - 47 in 2 m tiles\n" ..
		  				        "X Max (" .. tostring (region.rivers_vertical.x_max [x] [y]) .. "):",
							    COLOR_WHITE,
							    "",
							    self:callback ("updateRiversVerticalXMax"))							 	    
	  end
	  
	elseif keys [keybindings.rivers_horizontal_active.key] then
	  if focus == "Rivers" then
	      local active_string
          local List = {"West",
		                "East",
						"Disabled"}
		  
		  if region.rivers_horizontal.active [x] [y] == 0 then
		    active_string = "Disabled"
			
		  elseif region.rivers_horizontal.active [x] [y] == 1 then
		    active_string = "West"
			
		  else
		    active_string = "East"
		  end
		  
	      dialog.showListPrompt ("River Horizontal Active:", 
		                         "Current: " .. active_string,
								 COLOR_WHITE,
								 List,
								 self:callback ("updateRiversHorizontalActive"))
	  end
	  
	elseif keys [keybindings.rivers_horizontal_y_min.key] then
	  if focus == "Rivers" and
	    region.rivers_horizontal.active [x] [y] ~= 0 then
        dialog.showInputPrompt ("River Horizontal Y Min",
                                "0 - 47 in 2 m tiles\n" ..
		  				        "Y Min (" .. tostring (region.rivers_horizontal.y_min [x] [y]) .. "):",
							    COLOR_WHITE,
							    "",
							    self:callback ("updateRiversHorizontalYMin"))							 
	    
	  end
	  
	elseif keys [keybindings.rivers_horizontal_y_max.key] then
	  if focus == "Rivers" and
	    region.rivers_horizontal.active [x] [y] ~= 0 then
        dialog.showInputPrompt ("River Horizontal Y Max",
                                "0 - 47 in 2 m tiles\n" ..
		  				        "Y Max (" .. tostring (region.rivers_horizontal.y_max [x] [y]) .. "):",
							    COLOR_WHITE,
							    "",
							    self:callback ("updateRiversHorizontalYMax"))							 	    
	  end
	  
	elseif keys [keybindings.up.key] then
	  if focus ~= "Help" then
	    if y > 0 then
	      y = y - 1
	    end

	    Update (x, y, self.subviews.pages)
	  end
	  	  
	elseif keys [keybindings.down.key] then
	  if focus ~= "Help" then
	    if y < max_y - 1 then
	      y = y + 1
	    end

		Update (x, y, self.subviews.pages)
	  end
	  	  
	elseif keys [keybindings.left.key] then
	  if focus ~= "Help"  then
	    if x > 0 then
	      x = x - 1
	    end
	  
	    Update (x, y, self.subviews.pages)
	  end
	  
	elseif keys [keybindings.right.key] then
	  if focus ~= "Help" then
	    if x < max_x - 1 then
	      x = x + 1
	    end
		
	    Update (x, y, self.subviews.pages)
	  end
	  
	elseif keys [keybindings.upleft.key] then
	  if focus ~= "Help" then
	    if x > 0 then
	      x = x - 1
	    end
	  
	    if y > 0 then
	      y = y - 1
	    end
	  
	    Update (x, y, self.subviews.pages)
	  end
	  
	elseif keys [keybindings.upright.key] then
	  if focus ~= "Help" then
	    if x < max_x - 1 then
	      x = x + 1
	    end
	  
	    if y > 0 then
	      y = y - 1
	    end
	  
	    Update (x, y, self.subviews.pages)
	  end
	  
	elseif keys [keybindings.downleft.key] then
	  if focus ~= "Help" then
	    if x > 0 then
	      x = x - 1
	    end
	  
	    if y < max_y - 1 then
	      y = y + 1
	    end
	  
	    Update (x, y, self.subviews.pages)
	  end
	  
	elseif keys [keybindings.downright.key] then
	  if focus ~= "Help" then
	    if x < max_x - 1 then
	      x = x + 1
	    end
	  
	    if y < max_y - 1 then
	      y = y + 1
	    end
	  
	    Update (x, y, self.subviews.pages)
	  end	  
	end

    self.super.onInput (self, keys)
  end

  --============================================================

  function Show_Viewer ()
    local screen = RegionManipulatorUi {}
    persist_screen = screen
    screen:show ()
  end

  --============================================================

  Show_Viewer ()
end

regionmanipulator ()
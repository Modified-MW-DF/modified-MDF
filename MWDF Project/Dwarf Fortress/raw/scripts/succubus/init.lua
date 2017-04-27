-- Succubus Dungeon
-- This file will run fixes and tweaks when you load your saves

local debug = false

-- Make sure that commands are only run if you play as a succubus
local function isCiv(civ)
    local entity = df.historical_entity.find(df.global.ui.civ_id)
    return entity.entity_raw.code == civ
end

-- When the save is loaded, check if we're playing the right civ then perform actions
dfhack.onStateChange.loadSuccubusInit = function(code)
    if code == SC_MAP_LOADED and  isCiv('SUCCUBUS') then
        -- Immediate unlocking of magma workshops + hint in the announcement log
        if df.global.gamemode == df.game_mode.DWARF then
            dfhack.run_script('succubus/feature', 'magmaWorkshops')
            dfhack.gui.showAnnouncement("Welcome to the succubus mode, star marked buildings are magma powered.", COLOR_WHITE)
            dfhack.gui.showAnnouncement("You can use the magma well to generate magma.", COLOR_WHITE)
        end
    end
end

if debug then
    print("succubus/init: initialized")
end
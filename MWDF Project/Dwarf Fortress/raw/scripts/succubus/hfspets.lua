-- Will add all the random demons into the succubi's minion poll
local utils = require 'utils'
local addMinionToCiv = dfhack.script_environment('AddMinionToCiv')

-- Check the string's first parts
local function starts(String, Start)
	return string.sub(String, 1, string.len(Start)) == Start
end

-- Inserts all the castes of a creatures into the minion list.
local function insertAllCastes(civ, raw)
	local id, caste

	for id, caste in pairs(raw.caste) do
		addMinionToCiv.insertPet(civ, raw.creature_id, caste.caste_id)
	end
end

-- Scan the raws for DEMON_* creatures, add them to the minion list.
local function addHfsToMinions(civ)
	local caste, id, raw

	for id, raw in pairs(df.global.world.raws.creatures.all) do
		if starts(raw.creature_id, 'DEMON_') then
			insertAllCastes(civ, raw)
		end
	end
end

-- Action
ValidArgs = validArgs or utils.invert({
	'help',
    'civ',
})

local args = utils.processArgs({...}, validArgs)

if args.help then
print([[scripts/succubus/hfspets
Will add the random demons to the target's civ minions, if there is any.

arguments
    -civ <ENTITY_ID>
        The raw id of the target entity
]])
	return
end

if not args.civ then
	qerror('hfspets: No civ designated')
end

if not moduleMode then
	addHfsToMinions(args.civ)
end

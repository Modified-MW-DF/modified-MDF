-- Masterwork anouncement

--[[
 This is simply a called lua script that announces the version of masterwork
the player is using for uniformity of the version announcements, and easier to
edit it and move it around from location to location, if needed.

it doesn't care what args are called with it as it ignores them completely and 
announces the same message every time.
--]]

VersionString="1.28"
DFVersion="43.05 x64"

MDFContributors={
 "Meph",
 "Boltgun",
 "Smakemupagus",
 "Wannabehero",
 "Sackhead",
 "Deon",
 "Kazoo",
 "IndigoFenix",
 "Dirst",
 "Malecus",
 "Umiman",
 "Wastedlabor",
 "Dead elves everywhere",
 "SethCreiyd",
 "LiberCeli",
 "Grimlocke",
 "Stalhansch",
 "Igfig/Button",
 "ZM5!",
 "Xangi",
 "Knight Otu",
 "Phoebus",
 "Obsidian Soul",
 "Khaos",
 "Tali713",
 "Hydraknight",
 "HeyDude6",
 "Dookimiester"
}

dfhack.color(11)
dfhack.println('--------------------------------------------------')
dfhack.color(15)
dfhack.print('Welcome to ')
dfhack.color(13)
dfhack.print('Masterwork Dwarf Fortress ')
dfhack.color(15)
dfhack.print('version ')
dfhack.color(12)
dfhack.println(VersionString)
dfhack.color(15)
dfhack.println(' ')
dfhack.print('Utilizing Dwarf Fortress version ')
dfhack.color(12)
dfhack.println(DFVersion)
dfhack.color(11)
dfhack.println('--------------------------------------------------')
dfhack.color(-1)

if ... == "CREDITS" then
	dfhack.color(2)
	dfhack.println("thanks to the following people:")
		dfhack.color(14)
	for i,n in ipairs(MDFContributors) do
		dfhack.println(n)
	end
	dfhack.color(2)
	dfhack.println("And also everyone in the Community,")
	dfhack.println("and anyone who we may have forgotten to put in the list!")
	dfhack.println("Thank you! Each and everyone of you!")
	dfhack.color(-1)
end


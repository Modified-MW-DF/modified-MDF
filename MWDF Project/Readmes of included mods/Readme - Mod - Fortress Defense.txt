************************************
[0.34.xx] Fortress Defense Mod II
************************************

------------Version 0.12

The goal of this mod is to increase the difficulty and fun of the game by adding more enemy civilizations in the game for the player to war with. No more boring years of peace because the goblins decided your fort was too scary!

Features:
-Ten basic mode civs
-Four bonus mode civs
-Four challenge mode civs

---Changes for 0.12

-Added missing tools to minimod.

---Changes for 0.11

-Raw fixes due to change to 34.06 fixed.

---Changes for 0.10

-ELEPHANTS REWRITTEN
-Elephants and Warwolves should equip armor more regularly
-Elephants and Warwolves have lower natural skills
-Elephants now use weapons and have new bodyparts
-New armor types added to fix bugs with vanilla armor behavior
-Tigermen no longer attack in summer

---Changes for 0.09

-Suicidal Dark Stranglers, weaker Beakwolves
-Helmet Snakemen siege alongside Nagas
-Some Putrid Blendecs drop Cassiterite
-Frogmen use copper in both versions; the difference between wood and copper is meaningless
-Giant Fiend Spiders have a decreased chance of attacking with webs
-Warwolves use steel

---Changes for 0.08 and lower

-Moved Furies to the bonus mode in case folks still wanted to play them for the nostalgia
-Added Ferric Elves as their replacement
-Nerfed Beakwolves
-Graphics for all!!!
-Added one civ to basic mode as an early threat: Beakwolves
-Added three bonus civs: Pandashi, Raptor Men, and Greater Badgermen!
-Upgraded Nightwings to Challenge Mode
-Decreased the active seasons for basic mode civs
-Added kzel's graphics to the main download
-Banditry and castles have been added to certain entities to make for more interesting Adventure Modes
-Creatures have been updated for economies in 0.31.19
-Still compatible with 0.31.18, though probably not earlier versions
-Tigermen and Frogmen restricted to copper, Furies to bronze, Warwolves to Iron, and Elephants to steel
-Nightwings, Blendecs, and Hellfire Imps evaporate if temperature is turned on when slain
-Some creatures have innate skills
-Flails removed from Hellfire Imps

---Contents

Files:
body_fdbody.txt
building_fdreactors.txt
creature_fortdefense.txt
entity_fortdefense.txt
creature_fdchallenge.txt
entity_fdchallenge.txt
creature_fdbonus.txt
entity_fdbonus.txt
inorganic_stone_vaporstonefd.txt
item_armor_fd.txt
reaction_fdmetals.txt

Folders:
individual entity files (basic mode) : Contains an entity file for each basic mode civ
individual entity files (challenge mode) : Contains an entity file for each challenge mode civ
individual entity files (bonus) : Contains an entity file for the three bonus civs
graphics_fd : Contains files necessary to install graphics + installation instructions
Minimods : Optional files: add them to 1) re-enable kobolds and 2) remove clothing from goblins and kobolds


---Purpose of this document

This readme contains instructions to install Fortress Defense Mod and set up either of two possible levels of difficulty. The current version of Fortress Defense Mod also facilitates higher customizability than before. An index is provided with a record of the seasons in which enemies attack and some traits of each civ. Remember that you have to generate a new world for the mod to take effect.


---Simple/Complete Installation

The complete installation of Fortress Defence II requires that you copy all txt files except the txt files in the three folders and the readme into the raws/objects folder. For instruction on the installation of individual parts of Fortress Defence II, read the sections below.


---Installation - Basic Version

To install the Basic version of Fortress Defense, copy only "body_fdbody", "building_fdreactors", "creature_fortdefense", "entity_fortdefense", "inorganic_stone_vaporstonefd", "item_armor_fd", and  "reaction_fdmetals" into the raw/objects folder.

The Basic version of Fortress Defense adds ten races to the game for a total of eleven automatically hostile races. The difficulty of the enemies should increase gradually over time, though the vagaries of Dwarf Fortress world gen tend to mess this up.

---Installation - Challenge version

To install the Challenge version of Fortress Defense, copy, in addition to all the files required for the Basic version, "entity_fdchallenge" and "creature_fdchallenge" into the raw/objects folder.

The Challenge version of Fortress Defense adds four civilizations almost guaranteed to destroy your fort unless you hide away with crossbows...or you have a military hardcore enough to take them in hand to hand combat. It is recommended that only those in search of Fun rather than victory in battle attempt to face them in battle.

---Installation - Bonus

To install the Bonus civilizations, copy "entity_fdbonus" and "creature_fdbonus" into the raw/objects folder in addition to any other modes you are installing.

The four bonus entities are designed to be a bit more challenging than goblins, but to be within the capability of a well-prepared dwarven militia that survives to the point where it faces them. Either one may be installed individually by copying only the file for that entity from the individual entity files folder instead of the "entity_fdbonus" file.

---Customized Installation

Alternately, you may choose instead to install only a few of the civs offered in this mod. If so, copy into the raws only the entity files of the specific desired civs (ex. entity_nagafd.txt, entity_warwolffd.txt), located in the individual entity files. See the civilization index at the bottom of the file for a description of each civ.

You will also need to copy these files in addition to the above:
body_fdbody.txt
building_fdreactors.txt
creature_fortdefense.txt
creature_fdchallenge.txt
creature_fdbonus.txt
inorganic_stone_vaporstonefd.txt
item_armor_fd.txt
reaction_fdmetals.txt

(This works because the game won't spawn the extra creatures in the creature_fortdefense files  at all without a file that includes the corresponding entity. 

***Note that adding both the entity_fortdefense.txt and any individual entity files will result in duplication errors)


---Warnings and minor troubleshooting

If you are having problems getting all potential enemy civs in one site (eleven in Basic due to the ten mod races and goblins, and fourteen in Challenge due to the three challenge races), try genning a new world on a medium or larger region, not island, and increase the number of civilizations placed at embark.

Long worldgens might not work well due to the potential for wars and the game slowing down due to the tracking of so many civs.

The creatures and files in Fortress Defense Mod: Restoration are not compatible with the files of previous Fortress Defense Mod releases except Fortress Defense Mod Lite. It is recommended to undertake a fresh install.

---
---

Index: Description of the Fortress Defense Mod Civilizations:

---
---

===Seasonal Schedule of Attacks:

		Spring	Summer	Autumn	Winter
Stranglers	x			x
Beakwolves              x               x
Frogmen		x			
Tigermen	x			x
Blendecs				x
Nagas		x	x		
Ferric Elves	x			
Hellfire Imps				x
Warwolves				x
Elephants		x	x	
----------------------------------------------
Pandashi        x                       x
Greater Badgers         x
Raptor Men      x       x
Furies		x			
----------------------------------------------
Jotun                                   x
Minotauros              x       x
Spiders                 x       x
Nightwings                      x       x



===Tier 1: 

These enemies start besieging you when you have 20 dwarves, depending on how long it takes to reach your fort from where they are or how much wealth you are exporting from your fort. Luckily, the most they should be able to do is disrupt trade, if you have any form of armor available.

Dark Stranglers (size 40,000)

About 2/3 the size of dwarves and lacking in any form of armor, they are not much of a threat to an early militia. They do, however, have 4 arms and a very vicious bite, and are quite fast. As the weakest of the new enemies, they also attack the soonest.

Beak Wolves (size 50,000+)

These relatives of the familiar mount of Goblins, the Beak Dog, similarly attack dwarves with their crushing beak and sharp claws. However, they fight with greater cunning and skill than their wilder, less organized cousins. These black and white monsters will usually, but not always, attack a little while after the Stranglers.


===Tier 2: 

These enemies come when you have about 50 dwarves, or at the appropriate level of trade. You'll only need a few good men to withstand these sieges.

Frogmen (size: 50,000)

Frogmen are just a little smaller than dwarves. They treat water as no obstacle, and in addition, they only know how to use copper and cannot make many kinds of armor. They will probably flee when it is clear they are no match for you, but watch out for their arrows!

White Tigermen (size: 90,000)

Learning of the servitude their striped brethren have been forced into by the elves and dwarves, these northern avengers have come to wreak vengeance and liberate the enslaved! Though they are bigger than dwarves, their lack of strong armor and inability to smelt anything except copper means that dwarves should nonetheless easily defeat them.


===Tier 3: 

These enemies come when you have about 80 dwarves, or if you carry out a lot of trade. The real battles begin here. In addition to the civs below, vanilla goblins will also begin attacking you.

Nagas (size: 50,000)

Half-serpent and half-man, with poisonous fangs. Their venom varies from merely paralyzing to capable of inflicting necrosis. The striking reflexes of their reptilian halves give them a great deal of speed when fighting.They use bronze and iron weapons, and include archers among their ranks. Nagas have developed some armor making ability; however, they cannot armor their snake-like lower bodies as well as dwarves. Also, they are dextrous enough to avoid traps.

Putrid Blendecs (size: 60,000)

Finally, an enemy the same size as a dwarf! Foul blendecs, which have cloven feet and eyeless skulls for heads, could only be found in evil areas in vanilla. In Fortress Defense, they attack armed with bronze and iron weapons and armor. Because they are a twisted mix of the undead and the living, they know neither pain nor fear, and your traps cannot target them. Lately, some Putrid Blendecs have been discovered to contain lumps of Cassiterite inside their bodies.

Ferric Elves (size: 60,000)

Ferric Elves are the remnants of elven communities who survived the fiery destruction of their forests. Left with no other choice, they learned to smelt iron and silver with the leftover charcoal and forged themselves into a formidable fighting force. Each member of their desperate race is trained to use a ranged weapon from birth, resulting in innate archery skill. Swift and agile, they are too graceful to be caught by traps. Cut off from their connection to nature they no longer wish to live, and experience no fear charging into battle, hoping only to end their internal pain. Please be so good as to oblige them!

Hellfire Imps (size: 60,000)

Fire Imps are normally exceedingly small. Hellfire Imps, however, are their comparatively huge relatives who have grown so fond of setting bonfires that they have formed a marauding horde for the purpose of burning to death as many dwarves and other unlucky victims as possible. They use up to steel armor and weaponry (including fearsome whips), but their most fearsome ability is to throw or breath fire at their prey from range, a capability which is possessed by all of their troops. Shields are heavily advisable against them.
Note: you can cheese your way out of some of this by turning off temperature. (weaklings…)


===Tier 4: 

The previous tier contained enemies that were about equal to dwarves. Now, the enemies outmatch them significantly. Tier 4 enemies attack at about 110-140 population, or if you conduct a ridiculous amount of trade.

Warwolves (size: 120,000)

Twice the size of dwarves, the lightning-fast, steel- and iron-wielding werewolves are guaranteed to defeat any similarly armed unskilled dwarf in single-combat. In addition, they avoid traps, meaning that there is no easy way to deal with them. If you wish to meet them head-on, no less than steel-armed dwarves will suffice.

Elephants (size: 5,000,000)

No, that size is not a typo. Elephants are massive, and they have come to lay waste to your fort just as they did the fortresses of old, only this time they come in heavy steel armor, wielding massive mauls or morningstars. Luckily for the player, Elephants do not wield shields with their trunks, and mainly rely on their tusks, their powerful bulk, and pure animal rage to kill your dwarves.


===Bonus Tier:

The bonus tier enemies attack at the same time as Tier 4 enemies. They are very similar to dwarves in size and most wield steel equipment. One could compare them to a well-trained dwarven militia.

Greater Badgermen (size: 50,000+)

The Greater Badgermen are an ancient and proud race who, like dwarves, build great subterranean communities in the mountains. In battle, they work themselves into berserk rages while charging wildly without regard for their own safety. Throughout their lives, they gradually increase in size; a Greater Badgerman of venerable age will be 1.5x as big as a dwarf.

Pandashi (size: 50,000+)

The Pandashi are a reclusive race, but fond of contests to the death with powerful foes. If you survive long enough, the Pandashi will leave their bamboo forests to challenge you in battle. Their power comes not only from the foreign equipment they wield, but also their innate martial skill and their ability to enter martial trances. Their high awareness and agility allows them to dodge traps. Like Greater Badgermen, they gradually increase in size throughout their lives.

Raptor Men (size: 50,000+)

Raptor Men are essentially lock-picking upgrades of Frogmen. Feathered and scaled, they are capable of using steel weapons but have limited armor options. They can easily cross water to attack your dwarves, and simple locked doors cannot stymie their cunning minds.

Furies (size: 60,000)

Furies, like their cousins Harpies, possess the ability to fly. This resulted in their being removed from the Basic version due to flight pathfinding being broken. Unlike Harpies, however, Furies come in both male and female forms, and can wield weapons. Because they fly, however, Furies are not as well armored as other races. They use bronze only, and they are same size as dwarves.


===Challenge Version enemies: 

If it can be imagined, the power and ferocity of the following four races exceeds those of the previous tier by a ridiculous amount. They will pull no punches in their attempt to end your fort. That is why they have been sequestered into a whole league of their own.

Nightwings (size: 120,000)

These jackal-headed fiends combine the much of the worst of the basic mode foes. They wield cruel weapons of steel, experience neither pain nor fear, disable your traps, are free of any need for breath or nourishment, and worst of all, they can fly on their leathery wings. They represent the most elite conventional fighting force you will face. Good luck to those who face them in battle!

Minotaurossi (size: 220,000)

Minotaurs are the weakest of the semi-megabeasts in vanilla, imagined as solo attackers of fortresses. Their Fortrees Defense Mod cousins have banded together to steal the secret of steel from the dwarves. In battle, they know no restraint: their preferred weapons are whips, scourges, hammers, and halberds.

Jotunar (size: varies, maximum 9,000,000)

If you reach this point (which may be sooner than you think), it means that a race of giants once exiled to the barren wastelands of the world has come to initiate Ragnarok upon your fortress! They come in various shapes and sizes, and some even wield fire. Due to their sheer size (more than 100 times the size of a dwarf!),  It will take legendary warriors, strong defenses, and masterful weaponry (only blunt weapons, and maaaybe spears, can penetrate their armor!) to match these foes. But fear not! The enemies generated by Dwarf Fortress can possess neither great weapon skill nor arms. Weathering their storm is not impossible.

Great Fiend Spiders (size: 100,000)

What happens when you take the bane of the depths of the underground chasms - the Giant Cave Spider - and allow it to breed in such numbers that it spreads across the land? The answer is the eight-legged plague known as the Great Fiend Spider. Though its size is not especially intimidating, its ability to fire silk and its deadly paralytic venom can cripple your dwarves, preventing them from moving or fighting back as they are torn to shreds by the dribbling mandibles of the spiders. Of all the foes in this mod, I fear these the most.
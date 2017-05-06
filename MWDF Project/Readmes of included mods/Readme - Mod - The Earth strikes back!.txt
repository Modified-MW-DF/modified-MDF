The Earth Strikes Back!

A mod for Dwarf Fortress v0.42 and 0.43

Version 2.13
http://dffd.bay12games.com/file.php?id=9915
http://www.bay12forums.com/smf/index.php?topic=144831


===Requirements===
- Dwarf Fortress v42.04 or later
- DFHack 42.04r1 or later

Previous versions, including for Dwarf Fortress v0.40, are available at https://www.dropbox.com/sh/8lwraiy7v7jkifv/AADqFKPo1SCZtQSxp184MeN1a?dl=0

This mod includes new creatures, some new high-value gems to balance the risk posed by the new creatures, new workshops to mitigate the risks, exotic new plants as a side-effect of the new creatures' and gems' origins, and graphics for Stonesense, TWBT, and the main interface.


===Background===
The world is flush with life, anywhere and everywhere we witness an endless variety of living things.  Not only do we see birds in the sky, beasts on the ground and fish in the sea, but ancient trees burrow into the earth itself for sustenance.  Some, such as the Dwarves and Goblins, are aware that life is as boundless below the surface as above it, filling great caverns with fantastic plants and animals and peoples.  Life, it seems, is everywhere.

From where does all of this life come?  Doubtless the gods forged it originally, striking upon the anvil of the world with unimaginable crafts to create the infinite variety of living things we see today.  To those races that have tamed even the simplest metals, it is obvious that the seas and the soil are too soft a foundation upon which to forge anything of consequence... life must have been forged on solid rock.  But we do not need to take this on faith... the Dwarves who mine into solid rock know that this is true.

When the gods forged the first life, their strikes were of such incredible force that even the forgotten embers possessed power beyond mortal comprehension.  These embers, buried deep within the rock, imbue the surrounding stone with the dignity and vigor of a living thing.  Fresh, hot embers are surrounded by Living Stone that can be quite dangerous if awakened by careless mining.  The smaller embers have cooled leaving behind Hidden Gems where they otherwise would not be expected.

Any miner knows that the surest way to prosperity is to strike the earth.  Wise miners know that sometimes the earth strikes back.


===Features===
* Hidden Gems
High-value gems lie hidden within the layer stones, and there is one Hidden Gem type for each of the 24 types of standard layer stone (the 25th and 26th, obsidian and slade, are special enough already).  They resemble common gems, but all are precious due to their special origins.  For example, Hidden Onyx is found within limestone and is much more valuable than common onyx.

* Living Stone
Some stone still burns with enough animating force to react when struck by a pick, and this is when an Awakened Stone pulls itself free of the rock to attack the miner.

* Awakened Stones
A bewildering hybrid of flesh and stone, an Awakened Stone appears to be a boulder with a face and four long, clawed arms.  The core of this creature is nerve and muscle and bone, but it is covered in a thick layer of stone and has mud running through its veins.  Had it been left in peace, its iridescent eyes would have eventually solidified into Hidden Gems.  A single Awakened Stone is no match for a prepared militia, but these creatures usually turn up deep in the mines where the only protection comes from the miner's pick.

* Tributes, Altars and Secrets
Fortunately, Dwarves have learned how to pacify Living Stone so that the Awakened Stones that emerge are tame.  This is accomplished by researching a Secret (like necromancy, but less icky) or building a Tribute workshop from three blocks of that layer stone (or an Altar from a boulder of that stone built inside an appropriate temple) and sacrificing a gem.  Each miner that learns the Secret or sacrifices an appropriate gem at the Tribute will usually be at peace with any Living Stone he or she awakens.  An appropriate sacrifice is expensive: either a large gem or any cut gem of that layer's Hidden Gem.

A Secret or sacrifice is specific to a miner and a layer stone.  A miner who has made Tribute to Limestone will be at peace with any new Awakened Limestones he or she frees from the rock, but would still be considered an enemy by Awakened Granite.  Another miner from the same fortress would anger an Awakened Limestone unless he or she also made an appropriate sacrifice.

* Awakened Magma and Incandescent Stones
Living Stone that was unlucky enough to be awakened by magma is similar to an Awakened Stone, except that it is red-hot with heat and anger.  Tributes are of no use pacifying these creatures because they were not awakened by miners.  Living Stone that melts in magma becomes Awakened Magma, while "magma-safe" Living Stone becomes Incandescent Stone.

* Wyrms
Embers of creation that have cooled leave Hidden Gems, those that are still warm leave Awakened Stones, and the hottest ones leave an egg that hatches into a fast-growing Wyrm.  Although it hatches about the same size as an Awakened Stone, it will be the size of a dragon within a month.

Unlike Awakened Stones, these embers burn so hot that most of a Wyrm remains organic after it is slain.  Unfortunately, these hot embers are very difficult to pacify with Tribute.  A Dwarf who has made an appropriate sacrifice at a Tribute does not calm a Wyrm, but at least the beast won't be berserk when it emerges.  Usually.

* Awakened Storms
Embers of creation that fall onto a lake or river simply burn their way through to the rock below, but an Ember that falls into the ocean stays in contact with the water long enough to affect it.  The boiling region rises above the surface to form a swirling mass of clouds and lightning that can be devastating to a coastal settlement.

* Gem Seeds and Gem Vines
The boundary between animate Living Stone and inanimate Hidden Gem is not always simple or obvious.  Some Hidden Gems still contain enough force that they can be coaxed back to life.  A dwarf can attempt to extract a Gem Seed from a Hidden Gem at an appropriate Tribute.  If the extraction is successful, the Gem Seed can be planted to produce Gem Vines that can be brewed into alcohol and occasionally produce more Hidden Gems.

* Pet Rocks
People often take comfort from talking to their plants or pets, even if there is no obvious response.  Some people have adopted bits of Living Stone as their conversation partners... at least they believe they are talking to Living Stone.  It is very difficult to tell Living Stone apart from regular stone.

* DFHack Scripts
The mod includes seven DFHack scripts: more-item-descriptions, tesb-add-pets, tesb-create-unit, tesb-info, tesb-job-monitor, tesb-wake, and tesb-weather.

The tesb-info script print the mod's version number and gives information on how often Living Stone and Hidden Gems appear.

The other scripts are used internally, but they can be entered into the DFHack console if desired.  Use with "-help" for parameters.


===Installation===
Method A: If you do not use Rubble or the Starter Pack's mod tool.

1. Unzip the file on top of your Dwarf Fortress folder.  ENSURE THAT YOU WILL BE PROMPTED BEFORE OVERWRITING ANYTHING.

2. You will be notified that raw/objects/entity_default.txt already exists.  If you use no other mods, accept this overwrite.

3. You will be notified that stonesense/index.txt already exists.  Again, if you use no other mods, accept this overwrite.

4. You will probably be notified that raw/onload.init already exists.  If this happens, copy the contents of this file into the your existing init file.

5. If you do use other mods, copy the contents of raw/objects/entity_default.insert and paste them into raw/objects/entity_default.txt between the [PERMITTED_BUILDING:SCREW_PRESS] and [PERMITTED_REACTION:TAN_A_HIDE] lines.  Then open the stonesense/index.txt file to add the text "tesb/index.txt" (without quotes) by itself on the last line.

6. If you do not want to use the creature graphics (e.g., want to use ASCII only), delete the file raw/graphics/graphics_TESB_creatures.txt (you can also delete the tesb subfolder if desired).

7. To enable the TWBT overrides, add the contents of data/init/overrides.insert to data/init/overrides.txt (preferably at the end of the file).  Do this after any graphics packs changes you make with a Starter Pack.

8. If you use GemSet, you may wish to search-and-replace [CREATURE_TILE:'W'] with [CREATURE_TILE:'l'] in creature_TESB.txt to use a more Wyrm-like corpse tile.

Method B: If you want to use the Starter Pack's mod tool to manage The Earth Strikes Back.  This method is a bit hackish until I can figure out an elegant solution.

1. Unzip the file into a folder inside the Starter Pack's LNP/Mods folder, such as TESB.

2. Cut the stonesense folder out of this location and paste it into your Dwarf Fortress folder.  You will be notified that stonesense/index.txt already exists.

3. If you use no other mods with Stonesense content, accept this overwrite.  Otherwise, add "tesb/index.txt" (without quotes) by itself on the last line.

4. Cut the grahics folder (which is inside the raw folder just extracted) out of this location and paste it into the same spot under LNP/Graphics/<your graphics pack)/raw.  There should be no conflicts.  If you use GemSet, you may wish to search-and-replace [CREATURE_TILE:'W'] with [CREATURE_TILE:'l'] in creature_TESB.txt to use a more Wyrm-like corpse tile.

5. Cut the data folder out of this location and past into your Dwarf Fortress folder.  To enable the TWBT overrides, add the contents of data/init/overrides.insert to data/init/overrides.txt (preferably at the end of the file).  Do this after any graphics packs changes you make with the Starter Pack.

6. Move the readme_TESB.txt file somewhere convenient if desired. 

7. Double-click "The Earth Strikes Back!" to move it from Available to Merged, where it will be highlighted in yellow due to overwriting a vanilla file.  Mix with other mods if desired, then click Install Mods.

Method C: If you want to use Rubble 8.2.0 or later.

1. Acquire Rubble pack from DFFD at http://dffd.bay12games.com/file.php?id=11912

2. Place ZIP file in Rubble's [tt]addons[/tt] folder.  Do not unzip it.

3. Check The Earth Strikes Back!.  The only prerequisite is the [tt]Base[/tt] module.  This mod is compatible with First Landing.

4. This version of the mod includes several configration variables to customize your experience.
- Creature graphics may toggled be ON or OFF
- Secrets may be toggled ON or OFF
- Gem vines may be toggled ON or OFF
- Pet rocks may be toggled ON or OFF (but who could every toggle off such adorable creatures?)
- Living stone may be set to COMMON, RARE or NEVER
- Hidden gems may be set to COMMON, RARE or NEVER

Setting living stone to NEVER prevents anything from appearing while mining, and disables all of the creatures other than pet rocks.  Setting hidden gems to NEVER has the side-effects of disabling plants and turning Wyrm eyes into common gems.  If living stone and hidden gems are *both* set to NEVER, then Tributes have no function and are disabled.

5. Generate raws normally.



===Future Development Plans===
1. Leverage new DF 0.42/0.43 features.
2. Contribute to research on fixing spawned creature behavior.
3. Make the graphics a little less embarassing.


===Reference===
* Hidden Gems
All Hidden Gems are precious (material value 40) and can be used normally for gemcutting and encrusting once mined.  However, when they are still in the ground their unmined tiles are indistinguishable from the layer stone around them, even to DFHack tools like prospect and reveal.  A notification such as "You have struck hidden amethyst!" will be generated whenever a Hidden Gem is found.  There are twenty-four types of Hidden Gem, one for each of the main layer stones in the game (the 25th and 26th, obsidian and slade, are special enough on their own).

    Hidden amber opal is found in sandstone.
    Hidden amethyst is found in gabbro.
    Hidden aquamarine is found in schist.
    Hidden beryl is a golden-yellow-colored gem found in marble.
    Hidden black opal is found in dolomite.
    Hidden bone opal is a beige-colored gem found in siltstone.
    Hidden cherry opal is a chestnut-colored gem found in rock salt.
    Hidden emerald is found in granite.
    Hidden fire opal is a scarlet-colored gem found in mudstone.
    Hidden garnet is a blue-colored gem found in gneiss.
    Hidden milk opal is a cream-colored gem found in claystone.
    Hidden onyx is a blank and white gem found in limestone.  Like normal onyx, it is colored "black" for game purposes.
    Hidden pinfire opal is a flax-colored gem found in conglomerate.
    Hidden pyrite is a silver-colored gem found in dacite.
    Hidden pyrope is a dark-red-colored gem found in slate.  Like normal black pyrope, it is colored "black" for game purposes.
    Hidden quartz is a cream-colored gem found in andesite.
    Hidden shell opal is an ivory-colored gem found in shale.
    Hidden spinel is a purple-colored gem found in diorite.
    Hidden sunstone is a red gem with yellow flecks found in basalt.  Like normal sunstone, it is colored "pumpkin" for game purposes.
    Hidden tourmaline is an indigo-colored gem found in quartzite.
    Hidden turquoise is found in rhyolite.
    Hidden wax opal is a flax-colored gem found in chert.
    Hidden white opal is found in chalk.
    Hidden zircon is a red-colored gem found in phyllite.

Note that material preferences for Hidden Gems are unrelated to the normal gems with similar names.  That is, a Dwarf with a preference for amethyst will not be impressed by hidden amethyst, and vice versa.  This is due to the same system that makes "gold" and "native gold" unrelated preferences in the vanilla game.

Technical details
Each Hidden Gem has its attributes copied from the vanilla version of the normal gemstone, which might make for slight color differences depending on your graphics pack.  These gems are not present as clusters on the map, rather there is a small chance of a rough Hidden Gem being generated each time a tile of layer stone is mined.


* Living Stone
When a tile of Living Stone is mined, the resulting boulder animates into an Awakened Stone or Wyrm.  Whether that creature is friendly or hostile depends on whether the miner performed a sacrifice at an appropriate Tribute.

Technical details
Since v1.30 there are no clusters of Living Stone the map, rather there is a small chance of spawning an Awakened Stone or Wyrm (and possibly some Pet Rocks) each time a tile of layer stone is mined.  Since v2.13 running tesb-job-monitor in the console without arguments reports the current probabilities of finding Hidden Gems or Living Stone.


* Awakened Stones
When Living Stone is disturbed by mining, it attempts to tear itself free of the surrounding rock to move about on its own.  You will receive an announcement like "Urist McMiner has awakened a creature of Living Limestone" if the miner previously made a sacrifice at an appropriate Tribute, and the Awakened Stone will be tame.  Otherwise you will receive an announcement like "Urist McMiner has incurred the wrath of an Awakened Limestone", and the Awakened Stone will be hostile.  There is a one-in-ten chance that a hostile Awakened Stone will be berserk.  If an Awakened Stone is hostile, it will remain hostile even if it later meets a Dwarf who made an appropriate Tribute.

An Awakened Stone appears to be a boulder with a face and four long, clawed arms.  Its surface is made of rock and its blood is mud, but while still animated it has organic fleshy innards with familiar bones and organs.  Upon death, an Awakened Stone reverts quickly to a normal boulder.

In combat, an Awakened Stone is much more likely to bite than it is to use its claws.  Tame specimens can be trained for hunting or war, but they cannot breed.  Awakened Stones have a high running speed (60kph) but accelerate slowly, and they are not slowed down as much as other creatures by climbing or crawling (19kph).  They are also low-level building destroyers (able to destroy archery targets, slabs, statues, windows, wooden doors, and wooden hatches), making it that much harder to slow them down.

The creature tile for an Awakened Stone is â (although this will only be visible if the creature graphics are disabled).  The tile color is brown, dark gray, gray, light gray, or white depending on the stone type.

Technical details
All 24 types of Awakened Stones are castes of the same TESB_AWAKENED_STONE creature.  The creature's tile color varies by caste, but unfortunately it was not possible to make all of them visually distinct.  Stonesense does a better job of distinguishing Awakened Stones from one another, and it even respects castes that come in a variety of surface colors.

The TESB_AWAKENED_STONE creature appears very rarely in the caverns, but it doesn't appear directly due to mining at worldgen sites.  This means that Legends will be rarer than might be expected from their appearance at player forts.


* Tributes and Altars
A Tribute is a 3x3 workshop constructed from three blocks of a layer stone, while an Altar is a 1x1 workshop constructed from a boulder of layer stone.  An Altar will only function if it is built inside a temple dedicated to a deity associated with an appropriate Sphere (see Secrets below).

The Masonry labor is required to construct a Tribute or Altar and the Mining labor is required to perform sacrifices at one.  These sacrifices are very expensive, so it is recommended that a Manager be used to assign a specific miner to the workshop to ensure that the intended Dwarf performs the sacrifice.

Each Tribute or Altar allows two reactions, either of which has the same effect upon the Dwarf performing the reaction.  The first reaction (shortcut lowercase-L) consumes a large gem, and the second one (shortcut lowercase-H) consumes a normal cut gem of the Hidden Gem associated with that stone.  For example, the Tribute to Marble allows "Sacrifice large gem (l)" and "Sacrifice hidden beryl (h)".

The Dwarf performing the sacrifice will be permanently affected by a syndrome (e.g., "marble favor") that has two effects.  The first effect is to reduce the hostility of any Awakened Stones or Wyrms that the Dwarf releases from Living Stone.  The second effect is that the Dwarf suffers half-damage from anything made of that stone, including falling onto a floor of that material.  Repeated sacrifices do not further reduce the damage.

The third reaction attempts to extract a Gem Seed from a rough Hidden Gem, with a shortcut key of lowercase-X.  For example, the Tribute to Marble allows "Extract hidden beryl seed (x)".  The attempt _always_ destroys the rough Hidden Gem and produces a usable Gem Seed 50% of the time.

Technical details
A Tribute can be constructed from any three blocks, but it will function only if it is constructed from three blocks of the same layer stone.  A non-functional Tribute can be deconstructed to recover the blocks.  The tesb-job-monitor script allows all 25 Tribute types to appear on the building menu as a single generic Tribute building; this is accomplished by converting a generic Tribute into a specific Tribute workshop based on its materials (one of which is "Inactive Tribute" for invalid combinations of blocks).

The script that spawns Awakened Stones (and Wyrms) determines if the miner is affected by the appropriate "favor" syndrome and causes the Awakened Stone to spawn as tame if the "favor" syndrome is present and hostile otherwise ("favor" affects Wyrms to a lesser extent).  The script, tesb-wake, can be run from the DFHack console.  Type "tesb-wake -help" at the console for more information.

A cloud of blue mist appears when a sacrifice is performed at a Tribute or Altar.  This requires temperature to be turned on but is entirely cosmetic; the syndrome is applied through a reaction-trigger in DFHack, so there is no dependence on the Dwarf inhaling gas to contract the "favor" syndrome.


* Secrets
A person can also gain the "favor" syndrome by learning a divine Secret.  The Secret can be written down and learned by others, but unlike necromancy the holders of these secrets do not build towers.  Learning one of the Secrets does not prevent learning the others, so in principle a migrant can arrive who is already at peace with several types of Living Stone.

Sedimentary stones are in the EARTH and MINERALS Spheres.  Rock salt is also in the SALT Sphere.
Metamorphic stones are in the EARTH and MOUNTAINS Spheres.
Igneous intrusive stones are in the MOUNTAINS and CAVERNS Spheres.
Igneous extrusive stones are in the MOUNTAINS and VOLCANOS Spheres.
Flux stones are in the MINERALS and METALS Spheres.

Technical details
Those who learn the secret of peace with a particular kind of Living Stone do not establish towers, so the slabs and books detailing the secret will be stored wherever the person happens to live.  Due to current peculiarities of DF, the same people who seek out these secrets of peace are the same ones trying to become necromancers, and some people accomplish both.  Anyone can learn the secret by reading a (divine) slab or (mundane) book, if they can find one.  Fortunately for the player, necromancers do not migrate to forts.  This means that migrants with these secrets are likely only on worlds that are young (first generation still living) or very, very old (allowing enough time for writings to be lost and rediscovered).


* Awakened Magma and Incandescent Stones
These creatures were Living Stone awakened by natural causes, and as such there is no opportunity to calm them with Tributes.  In fact, these creatures are perpetually angry and completely untrainable.

They are also as hot as magma and always on fire.  The difference between Awakened Magma and Incandescent Stone is that the former has a molten surface while the latter has a red-hot solid surface of magma-safe stone (Basalt, Chert, Dolomite, Gabbro, Quartzite or Sandstone).  They are at home in subterranean magma formations, but often wander across the land in search of prey.

Technical details
The TESB_AWAKENED_MAGMA and TESB_INCANDESCENT_STONE creatures are very similar to the TESB_AWAKENED_STONE creature except that they occur naturally and immolate their surroundings.  Another important difference is that more than one can appear at a time.


* Wyrms
A Wyrm resembles a wingless dragon, although it is covered in rock instead of scales.  Born about the size of an Awakened Stone, a Wyrm quadruples in size each week for four weeks to roughly the size of a dragon.  The initial miner who released the Wyrm will probably have the best chance to kill it.  Any Living Stone hot enough to emerge as a Wyrm will be hostile, but the creture is much less likely to be berserk if the miner had previously made an appropriate Tribute.

These fast-growing beasts attack with their bites, claws and tails, and have special attacks that vary depending on their type:
    Aquifer-bearing stones have a bite that causes all fat tissue to swell up (as it fills with water).
    Igneous extrusive stones can slap the ground with their tail, staggering nearby foes.
    Igneous intrusive stones can spit magma.
    Flux stones have steel for bones, teeth, and their oversized claws.
    The remaining Wyrms spit rocks quite often.

Technical details
All Wyrms are castes of the same TESB_WYRM creature.  When butchered, each eye yields a rough Hidden Gem.  The chance that an [b]Awakened Stone[/b] will turn out to be a Wyrm is the square root of the chance of a tile yielding an Awakened Stone.  At the default rate of .002 of tiles yielding Awakened Stones, 4.47% (about 1 in 22) will turn out to be Wyrms.

The "stagger" effect is implemented as a dizziness syndrome.  It is more severe for creatures adjacent to the Wyrm, but can affect opponents several tiles away.

Like Awakened Stones, Wyrms that appear due to mining are temporarily OPPOSED_TO_LIFE.  This prevents them from immediately pathing to the edge of the map.

* Awakened Storms
An Awakened Storm is a huge, dense formation of clouds with four swirling arms around a central core.  These arms will batter and lash nearby creatures, but the lightning that surrounds them will strike any creature in the vicinity.  Lightning is far more dangerous to creatures standing in water, and that is likely because it is always raining when an Awakened Storm arrives.

An Awakened Storm does not have any vital organs, so killing it requires disrupting its core.  Once that is accomplished, you will be rewarded with a special Hidden Gem that cannot be acquired through mining.

Technical details

The TESB_AWAKENED_STORM is a "naturally" occuring beast native to the oceans, and the tesb-weather script checks for the presence of one every ten ticks.  If one is found, the script sets the weather to rain.


* Gem Seeds and Gem Vines
If the fortress extracts a Gem Seed from a rough Hidden Gem at a Tribute, that seed can be planted in an underground farm plot to produce a Gem Vine.  Each type of Hidden Gem has its own species of Gem Vine. The growths of this plant, known as "clusters," can be processed at a Still to produce 5 units of alcoholic "spirits" and a 20% chance of recovering a rough Hidden Gem.  For example, an amethyst seed can grow into an amethyst vine which produces amethyst clusters; those clusters can be brought to a Still to produce amethyst spirits and possibly a rough hidden amethyst.

The reaction at the Still is "brew gem cluster (g)" and requires a barrel or pot to hold the spirits.

Technical details
There are twenty-four separate species of Gem Vines which are largely identical except for coloration.  The clusters are rocky and inedible, having no value other than being processed at a Still.  The structural material and seeds, however, are normal plant products that are vulnerable to vermin.  The seeds can be cooked into meals if permitted in the Kitchen settings.

The clusters and seeds were given high materials values because (1) they can produce an endless stream of precious gems and (2) they should not be available for embark under normal circumstances.


* Pet Rocks
These small pets are very low-maintenance because rocks don't eat or drink.  Unfortunately, they will not move unless picked up by a dwarf.  Pet Rocks should be pastured in meeting areas to make them more likely to be adopted, then released from the pasture in case the owner wishes to bring the new pet to work.  If any Pet Rock ever did anything, no one witnessed it.


Technical details
The TESB_PET_ROCK creature is immobile, and migrants don't seem to bring immobile pets with them.

There is a chance that a Pet Rock or two will spawn alongside an Awakened Stone or Wyrm when Living Stone is mined.  The types of Pet Rocks available at embark will depend on the layer stones available to your civilization.


* DFHack Scripts

more-item-descriptions adds mod-specific information to the detailed item description screen.

tesb-add-pets adds specific pet castes to the civilizations of a specific entity, making them available at embark.  Here it is used to add Per Rocks associated the layer stones known to that civilization.

tesb-create-unit is version 0.55 of modtools/create-unit.  This mod-specific copy is used if the DFHack version is before 0.43.03-r1.

tesb-info reports the version of the mod and information about the probabilities of striking Living Stone or Hidden Gems while mining.

tesb-job-monitor is used in spawning Hidden Gems, Awakened Stones, Wyrms and some Pet Rocks while mining.  It also monitors the construction of Tributes to ensure they end up as the proper type.  This script is configured from onload.init and running it without arguments in the console will report the grace period.

tesb-wake is discussed in the technical details for Tributes.

tesb-weather is used to force rain when an Awakened Storm is on the map.


* File list
manifest.json
readme_TESB.txt
data/art/TESB_tileset.png
data/init/overrides.insert
raw/onload.init
raw/graphics/graphics_TESB_creatures.txt
raw/graphics/tesb/TESB_graphics.png
raw/objects/building_TESB.txt
raw/objects/creature_TESB.txt
raw/objects/descriptor_pattern_TESB.txt
raw/objects/entity_default.insert
raw/objects/entity_default.txt
raw/objects/inorganic_stone_TESB.txt
raw/objects/interaction_TESB.txt
raw/objects/material_template_TESB.txt
raw/objects/plant_TESB.txt
raw/objects/reaction_TESB.txt
raw/objects/tissue_template_TESB.txt
raw/objects/text/book_TESB.txt
raw/objects/text/secret_TESB_andesite.txt
raw/objects/text/secret_TESB_basalt.txt
raw/objects/text/secret_TESB_chalk.txt
raw/objects/text/secret_TESB_chert.txt
raw/objects/text/secret_TESB_claystone.txt
raw/objects/text/secret_TESB_conglomerate.txt
raw/objects/text/secret_TESB_dacite.txt
raw/objects/text/secret_TESB_diorite.txt
raw/objects/text/secret_TESB_dolomite.txt
raw/objects/text/secret_TESB_gabbro.txt
raw/objects/text/secret_TESB_gneiss.txt
raw/objects/text/secret_TESB_granite.txt
raw/objects/text/secret_TESB_limestone.txt
raw/objects/text/secret_TESB_marble.txt
raw/objects/text/secret_TESB_mudstone.txt
raw/objects/text/secret_TESB_phyllite.txt
raw/objects/text/secret_TESB_quartzite.txt
raw/objects/text/secret_TESB_rhyolite.txt
raw/objects/text/secret_TESB_rocksalt.txt
raw/objects/text/secret_TESB_sandstone.txt
raw/objects/text/secret_TESB_schist.txt
raw/objects/text/secret_TESB_shale.txt
raw/objects/text/secret_TESB_siltstone.txt
raw/objects/text/secret_TESB_slate.txt
raw/scripts/more-item-descriptions.lua
raw/scripts/tesb-add-pets.lua
raw/scripts/tesb-create-unit.lua
raw/scripts/tesb-info.lua
raw/scripts/tesb-job-monitor.lua
raw/scripts/tesb-wake.lua
raw/scripts/tesb-weather.lua
stonesense/index.txt
stonesense/tesb/index.txt
stonesense/tesb/tesb_awakened_stone.png
stonesense/tesb/tesb_awakened_stone.xml
stonesense/tesb/tesb_buildings.png
stonesense/tesb/tesb_buildings.xml
stonesense/tesb/tesb_plants.png
stonesense/tesb/tesb_plants.xml
stonesense/tesb/include/tesb_cirlce.xml
stonesense/tesb/include/tesb_diamond.xml
stonesense/tesb/include/tesb_flat.xml
stonesense/tesb/include/tesb_octagon.xml
stonesense/tesb/include/tesb_square.xml


* Change log
Version 2.13: Fixed interopability issue with Standardized Materials; added a 250-mined-tile grace period before spawning Awakened Stones or Wyrms
Version 2.12: Additional bugfixes to creature raws; fixed pet rocks spawning hostile; clarified installation instructions; Rubble version now generates many small text files by script
Version 2.11: Revert to DFHack's create-unit for 0.43.03-r1 or later only; streamlined mod logic for spawning units; bugfix to creature raws; bugfix to extended item descriptions; cleared out depricated scripts
Version 2.10: Added Altars; added TWBT overrides for Tributes and Altars; bugfix for create-unit; future-proofed tesb-job-monitor by specifying job names instead of index numbers
Version 2.09: Removed forced attack for hostile Awakened Stones and Wyrms; made it more obvious if a Tribute is non-functional; added mod-specific descriptions for the extended item viewscreen; minor bugfix to Wyrm claws
Version 2.08: Fixed bug with building Tribute to Rock Salt; fixed bug with building Tributes out of non-stone blocks; available pet rocks now sorted alphabetically; designed around need for tesb-tame-all script (handled while spawning); combined tesb-mining and tesb-tribute into a single tesb-job-monitor
Version 2.07: tesb-tame-all now accepts one or more creature tokens; limited embarkable pet rocks to civ's available layer stones
Version 2.06: Prevented Awakened Stones and Wyrms from getting skill-related coloring; added trained animal graphics & Stonesense sprites; added profession names; added boasting speech for killing Wyrms
Version 2.05: Fixed spawned unit AI, removing need for OPPOSED_TO_LIFE; included v0.52 of create-unit.lua
Version 2.04: Stopped harmless errors when constructing floors; made pet rocks non-vermin creatures; made spawned hostile creatues temporarily OPPOSED_TO_LIFE
Version 2.03: Added Stonesense sprites for gem vines; fixed Stonesense error
Version 2.02: Added aquatic creature; added descriptions to reactions; several minor fixes to raws; harmonized with Rubble naming conventions
Version 2.01: Squelched harmless error that appeared when farm plots built; tidied up extra white space in raws; removed HEIGHT modifiers
Version 2.00: Updated for DF v0.42 and Rubble 7.3.1; touched up documentation
Version 1.41: Bugfixes to creature raws
Version 1.40: Added special abilities to Secrets; made references to rock salt more internally consistent; made mod compatible with Rubble
Version 1.37: Fixed issue with creatures spawning "friendly"; fixed repeated typo in reaction file
Version 1.36: Improved stability of creature spawning; fixed extracting gem seeds; cleaned up documentation
Version 1.35: Bugfix for tesb-mining and tesb-tribute scripts interfering with one another
Version 1.34: Added special abilities to Wyrms; stability improvements for Tribute construction
Version 1.33: Bug fixes to Tribute reactions; simplified building menu
Version 1.32: Bug fixes to when Awakened Stones or Wyrms emerge; added Starter Pack mod merge metadata
Version 1.31: Added secrets; fixed broken references to a material template; added TESB_ prefix to IDs generally not visible to the player
Version 1.30: Significant change to how Hidden Gems and Awakened Stones appear; eliminated the need for graphics-pack-specific raws, custom material template, custom Stonesense colors and tesb-prospect script; yet another bug fix for tesb-spawn-unit; improved the graphics for pet rocks
Version 1.22: Mod will use standard spawn-unit if present; further bug fixes to the fallback tesb-spawn-unit; fixed graphic glitch with pet rocks; folded CLA in with all other vanilla-like graphic packs
Version 1.21: Added Pet Rocks; Tribute colors now from material (not hardcoded); bug fixes to the tesb-spawn-unit script
Version 1.20: Added gem seeds and gem vines; added support for the Obsidian graphics pack; refactored Lua scripts in anticipation of future DFHack features
Version 1.12: Simplified installation and switching graphics packs
Version 1.11: Various bug fixes; refactored creature raws to improve in-game descriptions; updated entity file
Version 1.10: Added Awakened Magma and Incandescent Stone creatures
Version 1.02: Added tesb-prospect script
Version 1.01: Fixed magenta-background glitch with creature graphics
Version 1.00: Public release
Version 0.12: Corrected error with reaction-trigger registration
Version 0.11: Designated Awakened Stones as "fanciful" so they appear in artwork; clarified readme text; fixed .zip file so that it can be unzipped directly onto the DF folder
Version 0.10: Initial alpha release to solicit feedback


* Known bugs
The only secrets learned during worldgen are associated with the goal of Immortality, so the Peace with Living Stone secrets are associated with Immortality.  Will be changed to Bring Peace to the World when DF allows other goals in worldgen.  This mod's secrets do not interfere with the same person becoming a necromancer.  

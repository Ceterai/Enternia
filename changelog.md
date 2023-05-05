# Changelog

## Update 1.7 - Imperial Arsenal

### 1.7.1

Massive technological structures were located by your geoscanners under the surface of some alterash prime planets. The massive giants are apparently guarding some treasure among the gheatorn caves.  
The `Gheatsyn Droids` are waiting for "visitors".

**Main:**

- finished the gheatsyn droid (no longer WIP), as well as its spawner recipe. Now spawns in Gheatorn biomes on Alterash Prime planets.

**Other:**

- adjusted weapon sounds, animations and timings;
- adjusted drone spawns;
- fixed drone names;
- fixed logic of some drones as well as Alta Mini Drone spawns;
- fixed icons in the upgrader interface;
- fixed teleporter collisions;
- fixed triggers for some new objects;
- fixed wrong status effects on some shields;
- updated stim pack parameters;
- updated most crafting table interfaces;
- minor bug fixes.

### 1.7.0

Your datacenters just finished decrypting large parts of alta technology blueprints! This update adds tons of new upgradeable weapons and drone spawner items (craftable and loot ones), as well as a new tier 6 armor set!  
It also adds more throwable items and a full set of alta objects, traps, decorations and structures!

**Main:**

- added in total 72 objects: 1 sapling, 1 crafting, 64 decor, 2 spawners, 4 teleporters;
- added in total 92 items: 2 materials, 4 throwables, 8 shields, 32 weapons, 26 monster spawners, 14 loot items, 1 collar, 5 set items;
- added in total according recipes.

**Alterash:**

- updated existing biomes with new stuff.

**Alterash Prime:**

- updated existing biomes with new stuff.

**Alta:**

- added [Alta Upgrader](https://github.com/Ceterai/Enternia/wiki/Alta-Upgrader) - can be crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);

- added [Ghearun Set](https://github.com/Ceterai/Enternia/wiki/Ghearun-Set) of tier 6 armor as well as a set item;
- this set can be found in [Gheatsyn Chest](https://github.com/Ceterai/Enternia/wiki/Gheatsyn-Chest) in [Gheatsyn](https://github.com/Ceterai/Enternia/wiki/Gheatsyn) biomes or crafted at [Alta Upgrader](https://github.com/Ceterai/Enternia/wiki/Alta-Upgrader);

- added 32 ranged weapons:
  - tiers 3 (1), 4 (3), 5 (12), 6 (7), 6+1 (6), 6+2 (2), 6+3 (1);
  - press and hold can do different things (try pressing or holding LMB or RMB to see different results);
  - can shoot projectiles and apply effects;
  - projectiles can be piercing, ricosheting, guided, wobbling, exploding, sticky, liquid, etc.;
  - can have `flashlights`, `lazerpointers` and `stabilizers` (increase damage by 1.25);
  - some weapons (mostly rifles) have an alt ability that iterates between attachments above and fire modes:
    - when holding a rifle, press RMB to change attachment, or hold RMB to change firemode.
  - upgradeable to tier 6+1 (only levels 3-5).
- ranged weapons can be crafted or found in according biome chests;

- added 8 shields with unique enhanced mechanics:
  - tiers 4 (2), 5 (4), 6 (1), 6+1 (1);
  - passive status effects (apply when in hand);
  - active status effects (apply when the shield is raised);
  - press and hold can do different things (hold usually raises shield, press does something else);
  - perfect block (basic mechanic);
  - charged block (holding a raised shield will apply an effect/do something on release);
  - upgradeable to tier 6+1, just like weapons (only levels 4-5).
- shields can be crafted or found in according biome chests (Calin, Crystalline Prime, Ioncore, EDS Grounds, Evastaris);

- added 4 throwable items:
  - added a `Ceterteal Glowstick`;
  - added a `Phosphonade`;
  - added a `Vortex Nade`;
  - added an `Astera Tear`;

- added 14 basic alta objects - found in [Alta Tier 1 Pod](https://github.com/Ceterai/Enternia/wiki/Alta-Tier-1-Pod) or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 12 alta city objects - found in [Alta Tier 2 Pod](https://github.com/Ceterai/Enternia/wiki/Alta-Tier-2-Pod) or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 12 alta lab objects - found in [Alta Tier 3 Pod](https://github.com/Ceterai/Enternia/wiki/Alta-Tier-3-Pod) or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 16 alta ship objects - found in [Alta Tier 4 Pod](https://github.com/Ceterai/Enternia/wiki/Alta-Tier-4-Pod) or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 8 EDS objects - found in [EDS Pod](https://github.com/Ceterai/Enternia/wiki/EDS-Pod) or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 10 special alta objects - crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- updated existing alta objects;

- added alta drones & droids and reworked old ones:
  - small alta drones:
    - `Alta Scout Drone` - Tier 1, Peaceful
      - `Alta Crystal Drone`
      - `Alta Orchid Drone`
    - `Alta Security Drone` - Tier 2, Peaceful
      - `Alta Elin Drone`
      - `Alta Companion Drone`
    - `Alta Watcher Drone` - Tier 3, Aggressive
      - `Alta EDS Drone`
      - `Alta Ionic Drone`
    - `Alta Elite Drone` - Tier 4, Aggressive
      - `Alta Defensive Drone`
      - `Alta Lava Drone`
    - `Alta Mini Drone` - Tier 0, Aggressive
  - miniboss alta drones
    - `Alta Shield Drone` - Tier 1, Peaceful
    - `Alta Sentry Drone` - Tier 2, Peaceful
    - `Alta Engineer Drone` - Tier 3, Aggressive
    - `Alta Frigate Drone` - Tier 4, Aggressive
      - `Empty Alta Frigate Drone`
  - small alta droids
    - `Alta Spider Droid` - Tier 3, Aggressive
      - `Alta EDS Droid`
    - `Alta Elite Droid` - Tier 4, Aggressive
      - `Alta Stalker Droid`
  - miniboss alta droids
    - `Alta Defensive Droid` - Tier 3, Aggressive
    - `Alta Gheatsyn Droid` - Tier 4, Aggressive (WIP)

**Other:**

- added more loot items to later create more biome chests;
- added missing recipes for some objects;
- fixed some of the broken effects;
- updated all loot tables with new objects and items;
- reduced the size of the mod and removed unnecessary files, moved more materials to the deprecated folder;
- minor bug fixes.

## Update 1.6 - Crystal Rapture

### 1.6.1

A big bugfix update that brings to life a lot of features that previously were almost or completely broken! This includes elite back armor, turrets, saplings, spawners, etc.  
The update also cleans up the mod significantly and does some restructuring to prepare it for the next version!  
Other small things like adding missing recipes, fixing objects scripts, sounds and positioning and many more.

> **Note**: planning on gradually removing deprecated resources starting from 1.8, use [Deprecation Station](https://github.com/Ceterai/Enternia/wiki/Deprecation-Station) to exchange them if you have any.

**Main:**

- cleaned up the mod significantly by removing unused resources and reusing certain assets;
- restructured certain folders to make them easier to navigate and prepare it for 1.7 update;
- moved all deprecated resources to the deprecated folder (again);
- moved all parallaxes to the parallax folder (left old copies in their places for compatability);
- updated 5 codexes (text, formatting, price).

**Alterash Prime:**

- fixed [Phosphobulb](https://github.com/Ceterai/Enternia/wiki/Phosphobulb) sounds and effects;
- fixed [Isoslime Spawner](https://github.com/Ceterai/Enternia/wiki/Isoslime-Spawner)s - they now work as intended.

**Alta:**

- fixed [Dreamer Set](https://github.com/Ceterai/Enternia/wiki/Dreamer-Set) giving a [Perfectly Generic Item](https://github.com/Ceterai/Enternia/wiki/Perfectly-Generic-Item) instead of the helmet;
- fixed all set and loot item sounds, visuals and particles;

- added proper visuals to [Elite Protector](https://github.com/Ceterai/Enternia/wiki/Elite-Protector) and [Elite Generator](https://github.com/Ceterai/Enternia/wiki/Elite-Generator) items;
- added proper visuals to [Alta Drone Spawner](https://github.com/Ceterai/Enternia/wiki/Alta-Drone-Spawner) and finished it (no longer WIP);
- fixed turrets (no longer crash the game and now work properly, with sound etc).

**Other:**

- added fix recipes for all remaining deprecated objects and items to [Deprecation Station](https://github.com/Ceterai/Enternia/wiki/Deprecation-Station);
- added recipes for all remaining mod objects to [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor) (enterash and stardust ones);
- marked all deprecated objects and items as "Outdated" and updated their descriptions;
- fixed positioning for all crafting tables and other objects;
- fixed [Autoeffect](https://github.com/Ceterai/Enternia/wiki/Autoeffect) and [Electric Aura](https://github.com/Ceterai/Enternia/wiki/Electric-Aura) status effects and their derivatives;
- fixed any resources that were using or linking to deprecated resources;
- removed certain recipes that no longer should exist;
- added small descriptions to every update in the changelog and fixed update descriptions before 1.2;
- minor bug fixes.

### 1.6.0

Welcome to the crystal carnaval! This update adds tons of new crystal-based decorations and items to [Alterash Prime](https://github.com/Ceterai/Enternia/wiki/Alterash-Prime) planets!
It also adds lots of throwable items, like grenades, flares, javelins, toys, etc., as well as ways to obtain them.  
Finally, the update adds a [Guide Book](https://github.com/Ceterai/Enternia/wiki/Guide-Book) that can help you get through the mod and see all of it!

**Main:**

- added in total 80 objects: 1 sapling, 1 misc, 2 crafting, 66 decor, 1 farmable, 9 natural;
- added in total 80 items: 22 throwables, 50 cooked food (8 C, 12 U, 14 R, 16 L), 4 ingredients, 2 store food, 2 material;
- added in total 1 biome: [Gheatorn](https://github.com/Ceterai/Enternia/wiki/Gheatorn);
- added in total 16 tree foliage/stem types: [Yaara](https://github.com/Ceterai/Enternia/wiki/Yaara) 2 stem 3 fol, [Tonnova](https://github.com/Ceterai/Enternia/wiki/Tonnova) 2s 1f, [Aric](https://github.com/Ceterai/Enternia/wiki/Aric) 1s 4f, [Ayaka](https://github.com/Ceterai/Enternia/wiki/Ayaka) 2s 1 roots;
- added in total 12 effects and added icons to all new and old ones;
- added in total 20 codexes;
- added in total more than 100 recipes for all the new and some old items, objects, etc (now total is 483);
- added a goalbook for those who like to have something to work towards - [My Enternia Guide](https://github.com/Ceterai/Enternia/wiki/My-Enternia-Guide).
- the [Guide](https://github.com/Ceterai/Enternia/wiki/Guide) contains a small list of things you can get/do to consider the mod played through;
- the [Guide](https://github.com/Ceterai/Enternia/wiki/Guide) can be bought at Treasured Trophies or Tabula Rasa.

**Alterash:**

- added [Aya Vine](https://github.com/Ceterai/Enternia/wiki/Aya-Vine) ceiling roots that can spawn in [Ayaka Forest](https://github.com/Ceterai/Enternia/wiki/Ayaka-Forest) and drop [Aya](https://github.com/Ceterai/Enternia/wiki/Aya) and [Aya Powder](https://github.com/Ceterai/Enternia/wiki/Aya-Powder);
- added 6 decorative yaara furniture - found in [Yaara Orb](https://github.com/Ceterai/Enternia/wiki/Yaara-Orb) in [Yaara](https://github.com/Ceterai/Enternia/wiki/Yaara) biomes or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 8 decorative warped furniture - found in [Warped Chest](https://github.com/Ceterai/Enternia/wiki/Warped-Chest) in [Warped](https://github.com/Ceterai/Enternia/wiki/Warped) biomes or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added [Warped Hive](https://github.com/Ceterai/Enternia/wiki/Warped-Hive) - a throwable item, an improved analog of a regular throwable hive;
- added [Warped Hive Seed](https://github.com/Ceterai/Enternia/wiki/Warped-Hive-Seed) - can harvest for [Warped Hive](https://github.com/Ceterai/Enternia/wiki/Warped-Hive), found in [Warped](https://github.com/Ceterai/Enternia/wiki/Warped) biomes or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added [Ceternia Core](https://github.com/Ceterai/Enternia/wiki/Ceternia-Core) - drops from [Yaara Heart](https://github.com/Ceterai/Enternia/wiki/Yaara-Heart), used for crafting tier 6 armor instead of [Yaara Root](https://github.com/Ceterai/Enternia/wiki/Yaara-Root);
- added [Yaara Node](https://github.com/Ceterai/Enternia/wiki/Yaara-Node) trees - found in [Yaara](https://github.com/Ceterai/Enternia/wiki/Yaara) biomes - can have 2 stems and 3 foliages with different drops;
- added [Yaara Eye](https://github.com/Ceterai/Enternia/wiki/Yaara-Eye) - drops from [Yaara Bulb](https://github.com/Ceterai/Enternia/wiki/Yaara-Bulb) or some [Yaara Node](https://github.com/Ceterai/Enternia/wiki/Yaara-Node) trees, used for cooking and crafting some decorations;
- updated [Yaara Root](https://github.com/Ceterai/Enternia/wiki/Yaara-Root) from produce to ingredient, now drops from all yaara objects;
- fixed planet horizon graphic freakout (wrong colors);
- updated existing biomes with new stuff.

**Alterash Prime:**

- added 12 decorative bishyn furniture - found in [Bishyn Chest](https://github.com/Ceterai/Enternia/wiki/Bishyn-Chest) in [Bishyn](https://github.com/Ceterai/Enternia/wiki/Bishyn) biomes or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 12 decorative calin furniture - found in [Calin Chest](https://github.com/Ceterai/Enternia/wiki/Calin-Chest) in [Calin](https://github.com/Ceterai/Enternia/wiki/Calin) biomes or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 12 decorative hevika furniture - found in [Hevika Chest](https://github.com/Ceterai/Enternia/wiki/Hevika-Chest) in [Hevika](https://github.com/Ceterai/Enternia/wiki/Hevika) biomes or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 16 decorative gheatsyn furniture - found in [Gheatsyn Chest](https://github.com/Ceterai/Enternia/wiki/Gheatsyn-Chest) in [Gheatsyn](https://github.com/Ceterai/Enternia/wiki/Gheatsyn) biomes or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added 8 natural gheatsyn objects - they drop [Gheatsyn Shard](https://github.com/Ceterai/Enternia/wiki/Gheatsyn-Shard) used in crafting, cooking or as a throwable;
- added [Gheatorn](https://github.com/Ceterai/Enternia/wiki/Gheatorn) biome - a [shallow underground](https://github.com/Ceterai/Enternia/wiki/shallow-underground) layer biome;
- added [Bulbonid](https://github.com/Ceterai/Enternia/wiki/Bulbonid) natural object - a very tall plant that grows in the dark, found in [Bionid](https://github.com/Ceterai/Enternia/wiki/Bionid) biomes;
- added [Isoslime Ball](https://github.com/Ceterai/Enternia/wiki/Isoslime-Ball) - throwable resource that now drops in [Isoslime](https://github.com/Ceterai/Enternia/wiki/Isoslime) biomes instead of regular slime;
- added [Tonna](https://github.com/Ceterai/Enternia/wiki/Tonna) - a throwable cooking ingredient, now drops from [Tonnova](https://github.com/Ceterai/Enternia/wiki/Tonnova) trees in [Tonnova Grove](https://github.com/Ceterai/Enternia/wiki/Tonnova-Grove) biomes;
- updated existing biomes with new stuff.

**Alta:**

- reworked all cooked food and divided it into 4 cuisines + mixed one;
- each cuisine uses specific ingredients and has shared effects specific to this cuisine;

- added [Gear Set](https://github.com/Ceterai/Enternia/wiki/Gear-Set) items - when used they give you a full set of armor and gear of certain type (useful for testing etc);
- added [Gear Set](https://github.com/Ceterai/Enternia/wiki/Gear-Set) items for all gear added by this mod;
- certain codexes are now included with some gear sets as lore of that set;

- added a number of toy items, that can be found randomly in chests;
- added 5 grenades - can be crafted at [Alta Crafting Station](https://github.com/Ceterai/Enternia/wiki/Alta-Crafting-Station) in [Equipment](https://github.com/Ceterai/Enternia/wiki/Equipment) tab;
- added 2 new color glowsticks and advanced [Hevika Flare](https://github.com/Ceterai/Enternia/wiki/Hevika-Flare) items;
- added [Hevika Javelin](https://github.com/Ceterai/Enternia/wiki/Hevika-Javelin) throwable hunting spears that can be upgraded at [Alta Crafting Station](https://github.com/Ceterai/Enternia/wiki/Alta-Crafting-Station);
- new glowsticks, flares and javelins can be found in [Hevika Chest](https://github.com/Ceterai/Enternia/wiki/Hevika-Chest) in [Hevika](https://github.com/Ceterai/Enternia/wiki/Hevika) biomes;

- [Alta Crafting Station](https://github.com/Ceterai/Enternia/wiki/Alta-Crafting-Station) now has a tier 6 tab for all gear/throwables that normally can only be found as loot;
- [Alta Crafting Station](https://github.com/Ceterai/Enternia/wiki/Alta-Crafting-Station) now has a tab for all gear sets as items - [Gear Sets](https://github.com/Ceterai/Enternia/wiki/Gear-Sets);
- [Alta Crafting Station](https://github.com/Ceterai/Enternia/wiki/Alta-Crafting-Station) now requires certain codexes to be upgraded (can be found in chests or crafted at [Alta Datacenter](https://github.com/Ceterai/Enternia/wiki/Alta-Datacenter));

- added [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor) - crafting table (6 tiers) for all objects and loot tables added by the mod and more;
- added [Alta Datacenter](https://github.com/Ceterai/Enternia/wiki/Alta-Datacenter) - crafting table (1 tier) for all codexes added by the mod;
- moved object recipes and tabs from [Alta Crafting Station](https://github.com/Ceterai/Enternia/wiki/Alta-Crafting-Station) to [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- tier 6 of [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor) allows to craft naturally occuring objects and loot tables, which are unobtainable otherwise;
- both new crafting tables can be crafted at [Alta Crafting Station](https://github.com/Ceterai/Enternia/wiki/Alta-Crafting-Station);

- reworked mod saplings, they now [Uncommon](https://github.com/Ceterai/Enternia/wiki/Uncommon) and can be sold for pixels and crafted with default params ([Garden Ayaka](https://github.com/Ceterai/Enternia/wiki/Garden-Ayaka));
- ayaka saplings are now called [Alterash Sapling](https://github.com/Ceterai/Enternia/wiki/Alterash-Sapling) and are also used for [Yaara Bush Tree](https://github.com/Ceterai/Enternia/wiki/Yaara-Bush-Tree);
- added [Alta Lab Sapling](https://github.com/Ceterai/Enternia/wiki/Alta-Lab-Sapling) - [Rare](https://github.com/Ceterai/Enternia/wiki/Rare) sapling used for [Aric](https://github.com/Ceterai/Enternia/wiki/Aric) and [Tonnova](https://github.com/Ceterai/Enternia/wiki/Tonnova) trees, can be sold or crafted with default params ([Tonnova](https://github.com/Ceterai/Enternia/wiki/Tonnova));

- added [EDS Lifechamber](https://github.com/Ceterai/Enternia/wiki/EDS-Lifechamber) - an improved version of [Lifechamber](https://github.com/Ceterai/Enternia/wiki/Lifechamber). Found in [EDS Grounds](https://github.com/Ceterai/Enternia/wiki/EDS-Grounds) or crafted at [Alta Constructor](https://github.com/Ceterai/Enternia/wiki/Alta-Constructor);
- added [EDS Table](https://github.com/Ceterai/Enternia/wiki/EDS-Table) - a decorative table;
- updated [EDS Status Pod](https://github.com/Ceterai/Enternia/wiki/EDS-Status-Pod), which now has proper visuals/params and can spawn on tier 4-5 planets added by the mod;

- updated same gear sets and fixed their effects.

**Other:**

- enhanced [Ayaka](https://github.com/Ceterai/Enternia/wiki/Ayaka) stem, [Tonnova](https://github.com/Ceterai/Enternia/wiki/Tonnova) stem and [Aric](https://github.com/Ceterai/Enternia/wiki/Aric) foliage variations;
- adjusted and reworked params and descriptions for many objects;
- fixed codexes not appearing in library after discovering;
- fixed broken effects of certain sets;
- updated all loot tables with new codexes, objects and items;
- added alta shop items to all vending machines (protectorate, space station, peacekeeper, hylotl);
- added more useful recipes;
- moved all recipes that turn mod materials into standard ones to [Deprecation Station](https://github.com/Ceterai/Enternia/wiki/Deprecation-Station);
- minor bug fixes.

## Update 1.5 - Alterash Prime

### 1.5.0

[Alterash Prime](https://github.com/Ceterai/Enternia/wiki/Alterash-Prime) is here! Explore a new planet type added by this mode - like alterash, but colder, harder to traverse, with lots of layers and new biomes!  
The update also adds tier 5 and 6 armor sets, as well as loot items and set items! Loot items contain loot from corresponding chests, and set items contain full sets of armor of a specific type.

**Main:**

- added new planet type - [Alterash Prime](https://github.com/Ceterai/Enternia/wiki/Alterash-Prime);
- added in total 48 objects, 5 items, 18 biomes;
- added in total 26 tree types, 1 bush type, over 100 recipes;
- updated [EDS Table](https://github.com/Ceterai/Enternia/wiki/EDS-Table) (now [Alta Crafting Station](https://github.com/Ceterai/Enternia/wiki/Alta-Crafting-Station)) with new interface, new recipes and categories;
- added level 6 upgrade to [Alta Crafting Station](https://github.com/Ceterai/Enternia/wiki/Alta-Crafting-Station) with recipes for every mod object and more;
- added [Loot Box](https://github.com/Ceterai/Enternia/wiki/Loot-Box) items - when used they drop loot from certain (biome) chests from the mod;
- updated some ids (use the [Deprecation Station](https://github.com/Ceterai/Enternia/wiki/Deprecation-Station) to convert deprecated items or get rewards for lost items).

**Alterash Prime:**

- added 1 atmosphere biome ([Eva Prime](https://github.com/Ceterai/Enternia/wiki/Eva-Prime)) with clouds and bg stat effects;
- added 4 surface biomes ([Alterash Prime Gardens](https://github.com/Ceterai/Enternia/wiki/Alterash-Prime-Gardens), [Alta Prime Labs](https://github.com/Ceterai/Enternia/wiki/Alta-Prime-Labs), [EDS Grounds](https://github.com/Ceterai/Enternia/wiki/EDS-Grounds), [Tavriya](https://github.com/Ceterai/Enternia/wiki/Tavriya));
- added 4 subsurface biomes ([Calocaves](https://github.com/Ceterai/Enternia/wiki/Calocaves), [Crystalline Prime](https://github.com/Ceterai/Enternia/wiki/Crystalline-Prime), [Isoslime Plasts](https://github.com/Ceterai/Enternia/wiki/Isoslime-Plasts), [Phospholion Mines](https://github.com/Ceterai/Enternia/wiki/Phospholion-Mines));
- added 2 shallow underground biomes ([Hidden Alta Labs](https://github.com/Ceterai/Enternia/wiki/Hidden-Alta-Labs), [Tonnova Grove](https://github.com/Ceterai/Enternia/wiki/Tonnova-Grove));
- added 4 mid underground biomes ([Alta Lab Debris](https://github.com/Ceterai/Enternia/wiki/Alta-Lab-Debris), [Bishyn Halls](https://github.com/Ceterai/Enternia/wiki/Bishyn-Halls), [Hevika](https://github.com/Ceterai/Enternia/wiki/Hevika), [Shroomic Depths](https://github.com/Ceterai/Enternia/wiki/Shroomic-Depths));
- added 2 deep underground biomes ([Hevika Tunnels](https://github.com/Ceterai/Enternia/wiki/Hevika-Tunnels), [Ionic Hive](https://github.com/Ceterai/Enternia/wiki/Ionic-Hive));
- added 1 core biome ([Barren Ion Core](https://github.com/Ceterai/Enternia/wiki/Barren-Ion-Core));
- added 37 new natural objects that can be found on [alterash prime](https://github.com/Ceterai/Enternia/wiki/alterash-prime) planets.

**Alterash:**

- updated planet descriptions;
- fixed a crash because of the [Snowy Alterash Ridges](https://github.com/Ceterai/Enternia/wiki/Snowy-Alterash-Ridges) biome generation;
- rebalanced object spawns for some biomes.

**Alta:**

- added [EDS Haulter](https://github.com/Ceterai/Enternia/wiki/EDS-Haulter)s - 5 different types of alta tank traps;
- added [EDS Status & Defensive Pod](https://github.com/Ceterai/Enternia/wiki/EDS-Status-Pod)s (WIP), [EDS Turret](https://github.com/Ceterai/Enternia/wiki/EDS-Turret)s (WIP), [EDS Retainer](https://github.com/Ceterai/Enternia/wiki/EDS-Retainer)s (WIP);
- added 2 other alta misc objects - [Alta Energy Source](https://github.com/Ceterai/Enternia/wiki/Alta-Energy-Source) and [Alta Drone Spawner](https://github.com/Ceterai/Enternia/wiki/Alta-Drone-Spawner) (WIP);
- added alta soda recipes to more original vending machines;
- added [Combat Set](https://github.com/Ceterai/Enternia/wiki/Combat-Set) - lvl 5 alta armor set (WIP);
- added [Elite Set](https://github.com/Ceterai/Enternia/wiki/Elite-Set) - lvl 6 alta armor set (WIP);
- added [Dreamer Set](https://github.com/Ceterai/Enternia/wiki/Dreamer-Set) - lvl 6 alta armor set (WIP);
- added 3 bonus helmets to already existing alta sets;
- added [VR Headset](https://github.com/Ceterai/Enternia/wiki/VR-Headset) - lvl 1 cosmetic hat;
- fixed some codexes.

**Other:**

- added palettes folder with palettes commonly used in the mod;
- updated coloring options for all armors & clothing;
- updated icons for some effects;
- updated biome chest loot tables;
- biome chest loot tables now can also drop their according loot boxes as bonus loot, meaning loot boxes can also drop themselves;
- minor bug fixes.

## Update 1.4 - Exploration & Restoration

### 1.4.2

This is an urgent update that fixes a game-crashing bug related to biome generation on some [Alterash](https://github.com/Ceterai/Enternia/wiki/Alterash) planets.  
It also does some minor fixes related to biome spawns and treasure.

**Main:**

- updated icons for some effects;
- adjusted rarity, price, other params of more objects;
- minor bug fixes.

**Alterash:**

- adjusted biome spawns;
- adjusted chest loot tables;
- fixed a major liquid generation bug with the [Flooded Caves](https://github.com/Ceterai/Enternia/wiki/Flooded-Caves) biome that caused the game to crash.

### 1.4.1

This update does a rework of all loot found in chests across the mod, as well as focuses on updating status effects and expanding the crafting station.

**Main:**

- added icons and names to some effects;
- updated [Ionic Stroke](https://github.com/Ceterai/Enternia/wiki/Ionic-Stroke) effect;
- changed effects of some decorative clothing items;
- fixed visuals and coloring of some clothing items;
- adjsuted prices and rarity of some clothing items;
- adjusted rarity, price, other params of some objects;
- minor bug fixes.

**Alterash:**

- adjusted spawns in some biomes;
- reworked chest loot tables.

**EDS Station:**

- updated interface and descriptions;
- added tier 5 and [Envirosuit Set](https://github.com/Ceterai/Enternia/wiki/Envirosuit-Set);
- added missing recipes for some items and objects;
- fixed recipes for certain resources;
- reworked some of the recipes.

### 1.4.0

A major update that significantly expands alterash planets by adding a lot of unique biomes, weather, plants and decorative clothing items.  
It also adds the [Deprecation Station](https://github.com/Ceterai/Enternia/wiki/Deprecation-Station) - a crafting table where you can exchange any deprecated items for new ones, or trade [Perfectly Generic Item](https://starbounder.org/Perfectly_Generic_Item)s for some gifts. Here you can also convert mod crafting materials and other items into standard Starbound resources.

**Main:**

- added in total 24 objects, 45 items, 6 biomes, 10 effects, 1 weather type;
- added the [Deprecation Station](https://github.com/Ceterai/Enternia/wiki/Deprecation-Station) - for converting deprecated items into useful, for converting perfectly generic items into decorative clothing/objects;
- updated some ids (...again. Sorry for that. Use the [Deprecation Station](https://github.com/Ceterai/Enternia/wiki/Deprecation-Station) to convert deprecated items or get rewards for lost items).

**Alterash:**

- added 1 asteroid biome ([Moonrock Space Islands](https://github.com/Ceterai/Enternia/wiki/Moonrock-Space-Islands)) with custom objects and enemies (and rewards);
- added 1 atmosphere biome ([Evostaris](https://github.com/Ceterai/Enternia/wiki/Evostaris)) with prism ore and crystals;
- added 4 surface biomes (2 common ([Alterash Riversides](https://github.com/Ceterai/Enternia/wiki/Alterash-Riversides), [Ayaka Forest](https://github.com/Ceterai/Enternia/wiki/Ayaka-Forest)), 2 uncommon ([Snowy Alterash Ridges](https://github.com/Ceterai/Enternia/wiki/Snowy-Alterash-Ridges), [Enchanted Meadows](https://github.com/Ceterai/Enternia/wiki/Enchanted-Meadows)));
- added new objects to surface biome [Alterash Labs](https://github.com/Ceterai/Enternia/wiki/Alterash-Labs);
- added new objects to underworld biome [Underworld Forests](https://github.com/Ceterai/Enternia/wiki/Underworld-Forests);
- added new tree type for the [Alterash Riversides](https://github.com/Ceterai/Enternia/wiki/Alterash-Riversides) biome;
- added 1 object (reeds) for the [Alterash Riversides](https://github.com/Ceterai/Enternia/wiki/Alterash-Riversides) biome;
- added bg bushes (reeds) for the [Alterash Riversides](https://github.com/Ceterai/Enternia/wiki/Alterash-Riversides) biome;
- added beakseed spawns to the [Enchanted Meadows](https://github.com/Ceterai/Enternia/wiki/Enchanted-Meadows) biome;
- added snowy dungeons to surface biome [Snowy Alterash Ridges](https://github.com/Ceterai/Enternia/wiki/Snowy-Alterash-Ridges);
- added 2 more possible planet descriptions;
- added 1 weather type ([Ionic Peak](https://github.com/Ceterai/Enternia/wiki/Ionic-Peak)) - creates radiowaves that worsen player's overall condition;
- moved tsay wild crops to the [Yaara Groves](https://github.com/Ceterai/Enternia/wiki/Yaara-Groves) biome;
- rebalanced object spawns for some biomes;
- enhanced [Alterash](https://github.com/Ceterai/Enternia/wiki/Alterash) tier 1 and 2 chest loot tables with themed decorative clothing, furniture and other (music, drills);
- removed [Orbital Strike](https://github.com/Ceterai/Enternia/wiki/Orbital-Strike) from weather configs - replaced with [Ionic Peak](https://github.com/Ceterai/Enternia/wiki/Ionic-Peak).

**Other:**

- added 6 objects (2 lights, 2 hazards, 2 decor);
- added 38 clothing items (7 hats, 3 backs) - paintable;
- added 1 augment and 1 collar;
- added 10 effects ([Life Support System](https://github.com/Ceterai/Enternia/wiki/Life-Support-System), [Asirai's Potential](https://github.com/Ceterai/Enternia/wiki/Asirai's-Potential), [Asirai's Energy](https://github.com/Ceterai/Enternia/wiki/Asirai's-Energy), [Ionic Stroke](https://github.com/Ceterai/Enternia/wiki/Ionic-Stroke), [Electroblockade](https://github.com/Ceterai/Enternia/wiki/Electroblockade), [Energizer](https://github.com/Ceterai/Enternia/wiki/Energizer), etc.);
- rebalanced prices for many objects;
- rebalanced weapon damage for some weapons;
- changed abilities of the spear, renamed it and added Asirai as a separate secret weapon with slightly different abils and params.

## Update 1.3 - Alterash

### 1.3.1

A small bugfix update that focuses on recipes and biome content. Oh, and also the water on all mod planets is now electric. Enjoy!

- fixed recipes;
- changed some item colors and attributes;
- updated treasurepools;
- updated biome spawns;
- water is now electrified;
- bug fixes.

### 1.3.0

Welcome to **Alterash**! This update adds alterash planets that can be found mainly around temperate stars and replace the old planet type.

- 14 new biomes (including 4 core biomes and 8 cave biomes);
- complete rework of old 6 biomes;
- 5 new weather conditions and rework of old 3 ones;
- 4 new weather presets;
- weather will now be chosen randomly for each planet from presets;
- 15+ new objects;
- 8+ new monsters and complete rework of old 3 ones;
- technical stuff like custom terrain generators and projectiles;
- a unique horizon graphic;
- custom parallaxes for surface biomes;
- codexes that make more sense;
- recipe rework;
- crafting station (4 levels) for everything mod-related;
- major changes to ids and descriptions;
- added underworld;
- made mode file structure closer to that of the game itself;
- reworked treasure throughout the planet majorly;
- added lots of categories of custom shrubbery for different biomes;
- 4 augments and 3 pet collars;
- 1 unique upgradeable weapon;
- 10+ new materials.

## Update 1.2 - Enternia Enhanced

### 1.2.1

A small preparation update that cleans up the mod a little and fixes minor bugs.

- minor improvements;
- slight restructuring;
- major code refactor;
- preparation for 1.3.

### 1.2.0

This update finally fixes the bug where the planet appears much, much bigger than it is. This was due to allowing incorrect liquids in the main biome that don't have a celestial graphic (mainly the healing water - don't put it in the main biome).

- fixed 'large planet' bug;
- added 2 new surface biomes and 3 underground biomes;
- completely reworked and rebalanced the planet - the old biome, all recipes, item stats, etc.;
- added 3 new capturable monsters, 1 new EPP and 2 new crafting materials;
- made the planet much harder to survive - added a planet hazard - ionized air, new weather - ionized rain, added teslaspikes and other hazards to spawn;
- reworked all monster spawns;
- changed possible planet difficulty to 4-6;
- changed possible dungeons;
- minor improvements.

## Update 1.1 - Enternia

### 1.1.0

This is a general expansion that adds a planet type and some content to it.

- desided to give the mod a proper name;
- added new planet type - [Enternia](https://github.com/Ceterai/Enternia/wiki/Enternia);
- added 1 new biome with a similar name;
- added a tree type for the new biome;
- added food and crops - [Aya](https://github.com/Ceterai/Enternia/wiki/Aya), [Gil](https://github.com/Ceterai/Enternia/wiki/Gil) and [Tsay](https://github.com/Ceterai/Enternia/wiki/Tsay), as well as prepared food made from them;
- added 1 upgradeable sword.

## Update 1.0 - Little Expansion

### 1.0.1

A small correction update that balances out the guns a little bit.

- adjusted gun prices;
- added piercing shot to SMGs.

### 1.0.0

Welcome to my mod! Hope you'll enjoy it as much as I do! ^^

- added a set of armor - the [C.T. Set](https://github.com/Ceterai/Enternia/wiki/C.T.-Set), including chest, legs and 2 helmets with unique abilities;
- added 2 upgradeable one-handed guns - [Fixed Point SMG](https://github.com/Ceterai/Enternia/wiki/Fixed-Point-SMG) and [Fixed Point Hyperblaster](https://github.com/Ceterai/Enternia/wiki/Fixed-Point-Hyperblaster);
- added 2 crafting materials - [Cetereye](https://github.com/Ceterai/Enternia/wiki/Cetereye) and [Ceter-Sphere](https://github.com/Ceterai/Enternia/wiki/Ceter-Sphere), that are needed to craft most of the mod items;
- these materials can be purchased at [Treasured Trophies](https://starbounder.org/Treasured_Trophies) or in [Tabula Rasa](https://steamcommunity.com/sharedfiles/filedetails/?id=737353165) if installed.

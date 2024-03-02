> Main page: [[ Modding ]]

This page contains technical information on support for other mods.

Currently supported mods:

- [Tabula Rasa](https://steamcommunity.com/sharedfiles/filedetails/?id=737353165) (most items and objects are available at the table);
- [Spawnable Item Pack](https://steamcommunity.com/sharedfiles/filedetails/?id=733665104) (all objects and a lot of items are available here, though less than at Tabula Rasa. I would recommend using max tier Alta Crafting Station, Alta Constructor and Alta Datacenter for all recipes);
- [Equivalent Exchange](https://steamcommunity.com/sharedfiles/filedetails/?id=1790667104) (all plant-based and non-organic materials can be studied at the Farm Table and the Mine Table respectfully. Nothing fot the Hunt Table);
- [Improved Food Descriptions](https://steamcommunity.com/sharedfiles/filedetails/?id=731354142) (proper support for all effects added by this mod);
- [More Planet Info](https://steamcommunity.com/sharedfiles/filedetails/?id=1117007107) (proper support for all effects, weather and biomes of this mod);
- [True Space](https://steamcommunity.com/sharedfiles/filedetails/?id=730684624) (planets added by this mod are able to spawn near True Space stars. ![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/interface/bookmarks/icons/ct_alterash_planet.png) [Alterash](https://github.com/Ceterai/Enternia/wiki/Alterash) can spawn as a mild/cool planet or satellite, ![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/interface/bookmarks/icons/ct_alterash_prime_planet.png) [Alterash Prime](https://github.com/Ceterai/Enternia/wiki/Alterash-Prime) as a cool/cold planet or satellite);
- [Race Traits](https://steamcommunity.com/sharedfiles/filedetails/?id=2622273194) (check mod screenshots for stats);
- [Frackin' Races](https://steamcommunity.com/sharedfiles/filedetails/?id=763259329)/[Frackin' Universe](https://steamcommunity.com/sharedfiles/filedetails/?id=729480149) (PARTIAL: no FU BYOS support. If you need it, you can get it here: [Alta FU Patch+](https://steamcommunity.com/sharedfiles/filedetails/?id=3048977458)).

Generating support files/data for all these mods is done through running the following file: [`/.meta/scripts/update_all.py`](https://github.com/Ceterai/Enternia/blob/main/.meta/scripts/update_all.py)

Navigation:

- [Tabula Rasa](#tabula-rasa)
- [Spawnable Item Pack](#spawnable-item-pack)
- [Equivalent Exchange](#equivalent-exchange)
- [Improved Food Descriptions](#improved-food-descriptions)
- [More Planet Info](#more-planet-info)
- [True Space](#true-space)
- [Race Traits](#race-traits)
- [Frackin' Races](#frackin-races)

### Tabula Rasa

The support for this mod consists of 2 parts:

1. Most recipes have `mod` listed in them as a recipe group, as well as relevant categories to put the recipes in proper tabs: `materials`, `armors`, `weapons`, `consumables`, `tools`, `objects` and `other`.
1. There are 2 custom category buttons - **My Enternia** and **Alta Species**:

   - **My Enternia** button filters by all recipes from this mod;
   - **Alta Species** button filters by all recipes from this mod that belong to altas or are considered alta technology.

   The patch is located here: [`/objects/wired/tabularasa/tabularasa.object.patch`](https://github.com/Ceterai/Enternia/blob/main/objects/wired/tabularasa/tabularasa.object.patch)

> Previously to 2.2.1, this only included species clothing and certain cosmetics added by the mod, and no custom category buttons or correct category groups were present. More details about these changes: [Update 2.2.1](https://github.com/Ceterai/Enternia/blob/main/.meta/changelog.md#221)

### Spawnable Item Pack

Support for this mod was made following this guide: [Spawnable Item Pack: Adding Items](https://github.com/Silverfeelin/Starbound-SpawnableItemPack/blob/master/sipMods/README.md)

Currently, the way SIP compiles the list of its "recipes" doesn't allow passing parameters, which are used by a lot of items in this mod, so a lot of items are not available through SIP.

### Equivalent Exchange

Made in accordance to the general guide made by the author of the mod: [Tutorial: How to add support between your mod and EE for Starbound.](https://steamcommunity.com/workshop/filedetails/discussion/1790667104/1642042464747956675/)

The script can be found here: [`/.meta/scripts/EES_support_script.py`](https://github.com/Ceterai/Enternia/blob/main/.meta/scripts/EES_support_script.py)

The resulting file is [`/EES_transmutationstudylist.config.patch`](https://github.com/Ceterai/Enternia/blob/main/EES_transmutationstudylist.config.patch).

### Improved Food Descriptions

The config for IFD is located in a file called `/IFD_statuseffects.config`. In order to provide support for that mod, we need to patch this file with our data.

To do that, I've made a python script that goes accross the mod directories, finds all status effects, and creates a ready-to-use patch file called [`/IFD_statuseffects.config.patch`](https://github.com/Ceterai/Enternia/blob/main/IFD_statuseffects.config.patch).

That's it!

The script can be found here: [`/.meta/scripts/IFD_support_script.py`](https://github.com/Ceterai/Enternia/blob/main/.meta/scripts/IFD_support_script.py)

### More Planet Info

Similarly to IFD, MPI gets most of it's parameters form a config file. Except this time it's a standard Starbound file called `/interface/cockpit/cockpit.config`. In MPI, there's already a patch file present, that adds new keys that have the need data in them.

Additionally, this mod (My Enternia) already has it's own patch data for that file.

Thus, we need to create a patch file, that conditionally either applies all MPI-related data + regular planet/weather data if MPI is installed, or only applies reqular planet/weather data if MPI isn't installed.

Sounds complicated, but I was able to get this done with a python script similar to the one used for IFD.

It creates a batch patch file (a patch file consisting of separate lists of batches), where first patch is unconditional (applies always) and has regular pre-made data copied from a file called [`/.meta/cockpit.config.patch`](https://github.com/Ceterai/Enternia/blob/main/.meta/cockpit.config.patch), and second patch is conditional, only applies if a specific key is present in cockpit.config that was added there by MPI, and this second patch contains MPI data generated by going around mod directories similar to IFD.

The resulting file is [`/interface/cockpit/cockpit.config.patch`](https://github.com/Ceterai/Enternia/blob/main/interface/cockpit/cockpit.config.patch).

The script can be found here: [`/.meta/scripts/MPI_support_script.py`](https://github.com/Ceterai/Enternia/blob/main/.meta/scripts/MPI_support_script.py)

### True Space

To make it so the planets appear near TS stars, we need to create a conditional patch for the `/celestial.config` file.

This is because TS, just like MPI, is working off of patches of standard Starbound files and add custom keys to them that are not normally present.

Thankfully, there's no script needed for this since it's easy to do.

The resulting file is [`/celestial.config.patch`](https://github.com/Ceterai/Enternia/blob/main/celestial.config.patch).

### Race Traits

There are two parts to making your mod support Race Traits:

- have your traits listed in a `/stats/effects/om_customstats/om_racetraits/om_racetraits.statuseffect.patch` file;
- have your species include an extended description listing said traits.

This is done automatically via the following script: [`/.meta/scripts/RT_support_script.py`](https://github.com/Ceterai/Enternia/blob/main/.meta/scripts/RT_support_script.py)

The script uses initial data (such as original species description and a general list of all possible species-specific traits) from this file: [`/.meta/alta.config`](https://github.com/Ceterai/Enternia/blob/main/.meta/alta.config)

The resulting file is [`/stats/effects/om_customstats/om_racetraits/om_racetraits.statuseffect.patch`](https://github.com/Ceterai/Enternia/blob/main/stats/effects/om_customstats/om_racetraits/om_racetraits.statuseffect.patch).

### Frackin' Races

Support for this mod is similar to Race Traits:

- have your traits listed in a `/species/<species>.raceeffect` file;
- have your species include an extended description listing said traits;
- have your food have specific effects to make it correspond to diets (WIP).

This is done automatically via the following script: [`/.meta/scripts/FU_support_script.py`](https://github.com/Ceterai/Enternia/blob/main/.meta/scripts/FU_support_script.py)

The script uses initial data (such as original species description and a general list of all possible species-specific traits) from this file: [`/.meta/alta.config`](https://github.com/Ceterai/Enternia/blob/main/.meta/alta.config)

The resulting file is [`/species/alta.raceeffect`](https://github.com/Ceterai/Enternia/blob/main/species/alta.raceeffect).

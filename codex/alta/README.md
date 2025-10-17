# Alta Codex

> Main page: [Alta Species](https://github.com/Ceterai/Enternia/wiki/Alta)

This folder contains all codex definitions for the alta species.

Each `.codex` file here is a codex definition that includes both the codex entry itself, and the related codex item that contains the entry.

## Types

Alta codexes come in three different types:

- **Datamass** - compact devices containing various information;
- **Ebook** - electronic holographic devices that contain information in an easily-readable form;
- **Paper** - information printed on regular paper, usually made from ayaka wood. Uses a `docs` tag.

Each codex item has an appropriate item tag to indicate that, as it is used for assigning a pickup radio message.

## Example Structure

```jsonc
{
  // This file contains a guide on alta botanics, focusing on plant types, fertilizers, and cultivation techniques.
  "id" : "ct_alta_botanics",  // Unique identifier for the codex entry (the item containing this entry will have a "-codex" suffix: "ct_alta_botanics-codex").
  "title" : "Alta Botanics Guide ^#2080f0;^reset;",  // A human-readable name both for the codex entry and the codex item containing it.
  "description" : "This guide describes main objectives of working with plants and is designed to help inexperienced altas learn how plants work! ^gray;(Unlocks tier 2 recipes)^reset;",  // A short description of the codex entry, shown in the codex item tooltip.
  "longdescription" : "Mainly, the guide goes over types of Io flora, such as ionic plants, crystallic plants, toxic plants, bionic plants, mushrooms and corals.",  // An additional description of the codex entry, only shown when the item is scanned with the alta scanner in the game.
  "altaDescription" : "Useful when trying to master dendrarium.",  // A short comment about the item made from a perspective of an alta. Only shown when the item is scanned with the alta scanner in the game.
  "icon" : "ebook/gyera.png",  // The icon of the codex entry, shown in the codex item tooltip and in the codex itself.
  "species" : "alta",  // The species this codex entry belongs to. Used for filtering in the codex library.
  "contentPages" : [  // The content of the codex entry, shown when reading the codex entry in the codex library.
    "Just like mobile creatures, categorized as fauna, flora, or plants, also need certain prerequisites to stay healthy, live longer and perform better at various physical and chemical prospects.\n\nThis guide is meant to quickly start you on more complicated side of dealing with wild and domesticated plants, different plant types, fertilizers and how to use them.",
    "Plant Types\n\nThe lifeforms covered by alta botanics can be divided into following family groups:\n- Herbal Plants\n- Aquatic Herbal Plants\n- Crystal Plants\n- Plant-like Crystals\n- Bubble Plants\n- Corals\n- Bionicas\n- Arics or Mushrooms"
  ],
  "itemConfig" : {  // Additional item configuration for the codex item containing this entry.
    "level" : 5,  // The level of the item, used for determining its rarity and power.
    "tooltipKind" : "ct_alta_item_long",  // The kind of tooltip to show when hovering over the item in the inventory.
    "itemTags" : [ "data_source", "ebook" ],  // Tags for the item, used for filtering and categorization.
    "learnBlueprintsOnPickup" : [ "ct_boost_fertilizer", "ct_lush_grass_seeds", "ct_ayaka_young_tree" ],  // Blueprints (recipes) to learn when the item is picked up, allowing the player to craft related items.
    "builder" : "/items/buildscripts/alta/codex.lua"  // The script used to build the item, allowing for custom item creation logic.
  }
}
```

## Modding

Great example to use for context is the **Alta Botanics** codex entry: [`ct_alta_botanics.codex`](ct_alta_botanics.codex)

More about modding items in this mod: [Modding: Items](https://github.com/Ceterai/Enternia/wiki/Modding-Items)

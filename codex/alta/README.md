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

## Page Sizing Guidelines

Starbound codex pages have specific character and line limits:

### Display Limits

- **Width:** `32` characters per line
- **Height:** `16` lines per page
- **Maximum:** `≤512` characters per page (32 × 16)

### How Line Counting Works

The game calculates lines by wrapping text:

- **Short lines (≤32 chars):** Count as 1 line each
- **Long lines (>32 chars):** Split by word wrapping
- **Empty lines:** Count as 1 line each

**Examples:**

```text
"Short line"              // 11 chars = 1 line
"This is a longer line that exceeds the width"  // 45 chars = 2 lines, word-wrapped
""                        // Empty = 1 line
```

### Best Practices

**Keep important content together:**

- Headers + their paragraphs should stay on same page
- Don't split lists across pages unnecessarily

**Estimate your line usage:**

```text
Header (15 chars)         // 1 line
Empty line                // 1 line  
Paragraph (60 chars)      // 2 lines
Another paragraph (80)    // 3 lines
List item (20 chars)      // 1 line
List item (25 chars)      // 1 line
                          // Total: 9 lines (fits comfortably!)
```

**Color codes don't count toward character limits:**

```text
"^#2080f0;Alta Technology^reset;"  // Visible: 15 chars, not 36!
```

**Warning signs of overflow:**

- More than 5-6 paragraphs
- Lists with 10+ items  
- Multiple sections with headers
- Very long sentences (80+ chars)

### Testing Your Codex

**Manual check:**

1. Count lines (including empty ones)
2. For lines `>32` chars: divide by `32`, round up (or split by words)
3. Total should be `≤16` lines per page

**In-game check:**

- Craft the codex and read it
- If text cuts off mid-sentence → page overflow!
- If new page starts awkwardly → adjust page breaks

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
    "builder" : "/items/buildscripts/alta/codex.lua"  // The script used to build the item, allowing for custom item creation logic. See /items/buildscripts/alta/README.md for more information.
  }
}
```

## Modding

Great example to use for context is the **Alta Botanics** codex entry: [`ct_alta_botanics.codex`](ct_alta_botanics.codex)

See the builder script used for alta codex items: [`/items/buildscripts/alta/codex.lua`](/items/buildscripts/alta/codex.lua)

More about modding items in this mod: [Modding: Items](https://github.com/Ceterai/Enternia/wiki/Modding-Items)

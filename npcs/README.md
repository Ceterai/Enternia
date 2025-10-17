# My Enternia NPCs

This folder contains all NPC definitions, configurations, and shop pools for the My Enternia mod. NPCs are organized by theme, with subfolders for specific professions, biomes, and specializations.

## Structure

- [`alta.npctype`](alta.npctype): Main alta NPC type definition.
- [`alta/`](alta/): Contains alta profession and themed NPCs (e.g., artist, collectioner, dancer, designer, party, social, service, androids, guards, officials, scientists, etc.).
  - [`artist.npctype`](alta/artist.npctype), [`collectioner.npctype`](alta/collectioner.npctype), ...: Profession-specific alta NPC definitions.
  - [`shop.config`](alta/shop.config): Defines shop pools for merchant-type NPCs in this category.
  - [`android/`](alta/android/): Alta android NPCs.
  - [`biome/`](alta/biome/): Biome merchant NPCs.
    - [`shop.config`](alta/biome/shop.config): Biome-specific shop pools.
  - [`food/`](alta/food/): Alta cooking and gardening NPCs.
    - [`shop.config`](alta/food/shop.config): Food and garden-themed shop pools.
  - [`guard/`](alta/guard/): Alta guard NPCs.
  - [`official/`](alta/official/): Alta officers and officials.
  - [`outpost/`](alta/outpost/)
  - [`science/`](alta/science/): Alta science and tech NPCs.
    - [`shop.config`](alta/science/shop.config): Science and tech-themed shop pools.
  - [`service/`](alta/service/)
    - [`shop.config`](alta/service/shop.config): Service and utility-themed shop pools.
  - [`tech/`](alta/tech/)
  - [`themed/`](alta/themed/)
  - [`tiered/`](alta/tiered/): Material tier-dependent alta guard NPCs.
- [`viona/`](viona/): Viona-themed NPCs.

## Shop Config Files

Shop configuration files (e.g., `shop.config`) define the inventory pools for merchant NPCs. Each file is a JSON object with one or more pool categories (such as `"rare"`, `"shop"`, etc.), each containing a list of item pools. Each pool is an array of `[minLevel, [items...]]`, where each item entry includes:

- `"item"`: The item definition (with optional parameters).
- `"rarity"`: The relative chance for this item to appear.
- `"price"` (optional): The price override for this item.

Example:

```jsonc
{
  "rare": [
    [0, [
      { "item": { "name": "prismlamp1" }, "rarity": 0.01 },
      { "item": { "name": "ct_alta_ai_chip" }, "rarity": 0.01 }
    ]]
  ],
  "shop": [
    [0, [
      { "item": { "name": "flashlight" }, "rarity": 0.15, "price": 250 }
    ]]
  ]
}
```

- There are comments indicating total rarity for each pool.
- Pools are referenced in `.npctype` files via the `poolsFile` field.

## .npctype File Structure

Each `.npctype` file defines an NPC type and its properties. Common fields include:

- **type**: Unique identifier for this NPC type (e.g., `"ct_alta_artist"`).
- **baseType**: Inherits properties from another NPC type.
- **matchColorIndices**: (Optional, boolean) Whether to match color indices for items.
- **items**: Defines the equipment and clothing for the NPC.
  - **override**: List of item sets by level, each with `head`, `chest`, and `legs` arrays.
- **scriptConfig**: Configuration for NPC behavior and merchant/shop settings.
  - **behavior**: (Optional) NPC behavior type (e.g., `"merchant"`).
  - **behaviorConfig**: (Optional) Additional behavior settings.
  - **questGenerator**: (Optional) Quest pool and graduation settings.
  - **merchant**: Merchant/shop settings:
    - **waitTime**: Time between shop refreshes.
    - **storeRadius**: Shop interaction radius.
    - **poolsFile**: Path to the shop config file.
    - **buyFactorRange**: Range for buy price multipliers.
    - **sellFactorRange**: Range for sell price multipliers.
    - **numItems**: Number of items shown in shop.
    - **categories**: Shop categories (affects item selection).
  - **dialogMode**: (Optional) How dialog is selected (e.g., `"random"`).
  - **dialog**: Dialog configuration, with references to dialog pools.

Example:

```jsonc
{
  "type": "ct_alta_artist",
  "baseType": "ct_alta",
  "items": {
    "override": [
      [0, [
        {
          "head": [ { "name": "ct_head_mimic", "parameters": { "preset": "scarf" } } ],
          "chest": [ { "name": "ct_alta_artist_croptop" } ],
          "legs": [ { "name": "ct_alta_artist_shorts" } ]
        }
      ]]
    ]
  },
  "scriptConfig": {
    "behavior": "merchant",
    "merchant": {
      "poolsFile": "/npcs/alta/shop.config",
      "numItems": 16,
      "categories": { "default": [ "art", "plushies" ] }
    },
    "dialog": { "merchant": { "tout": "/dialog/alta.config:artist" } }
  }
}
```

### Field Explanations

- **type**: Unique string for this NPC type.
- **baseType**: Inherits from another NPC type (for shared behavior/equipment).
- **matchColorIndices**: If true, matches color indices for equipped items.
- **items.override**: List of equipment sets by level.
  - **head/chest/legs**: Arrays of item objects (with optional parameters).
- **scriptConfig.behavior**: NPC behavior (e.g., merchant, guard).
- **scriptConfig.behaviorConfig**: Extra settings for the behavior.
- **scriptConfig.questGenerator**: Quest pool and graduation logic.
- **scriptConfig.merchant**: Shop settings (see above).
- **scriptConfig.dialogMode**: Dialog selection mode.
- **scriptConfig.dialog**: Dialog pools and references.

# Alta Item Builders

> Main pages (wiki links): [Modding: Items](https://github.com/Ceterai/Enternia/wiki/Modding-Items)

This folder contains build scripts used by all items and objects in this mod. These scripts enhance tooltips, add alta-specific functionality, and integrate with mod systems like the [Alta Scanner](https://ceterai.github.io/MyEnternia/Wiki/AltaScanner).

## How Builders Work

**Build scripts are called before an item is created** - they run when:

- Items are spawned via commands (`/spawnitem`)
- Items drop from containers, monsters, or NPCs
- Any UI opens that contains items (inventory, chests, shops, etc.)
- **Game loads** - every item and object is built once on startup

This means builders should be efficient and handle all item property generation and enhancement.

Very often there's no way to post-process an item after it's created, so builders must set up everything during the build phase, while balancing performance.

## Using Builders

To use a builder in your item file, add the `"builder"` field:

```json
{
  "itemName": "ct_example_item",
  "builder": "/items/buildscripts/alta/item.lua",
  ...
}
```

All alta item builders extend vanilla builders and add mod-specific features while maintaining compatibility.

## Quick Reference

| Script | Use For | Example Files | Documentation |
| - | - | - | - |
| `item.lua` | Materials, produce, throwables | `/items/generic/produce/*.item`<br>`/items/throwables/*.thrownitem` | - |
| `consumable.lua` | Food, produce, medicine | `/items/generic/produce/*.consumable`<br>`/items/generic/food/**/*.consumable` | - |
| `spawner.lua` | Monster eggs, robot spawners | `/items/active/alta/spawners/**/*.activeitem` | - |
| `object.lua` | Furniture, crafting stations, tech | `/objects/alta/**/*.object`<br>`/objects/biome/**/*.object` | - |
| `sapling.lua` | Tree & mushroom saplings | `/objects/alta/**/sapling/*.object`<br>`/objects/biome/**/shrooms/*.object` | - |
| `augment.lua` | EPP augments (back slot) | `/items/augments/back/*.augment` | - |
| `collar.lua` | Pet collars | `/items/augments/pet/*.augment` | - |
| `codex.lua` | Codex entries | `/codex/alta/*.codex` | [Codex README](../../codex/alta/README.md) |
| `dye.lua` | Armor dyes | `/items/generic/dyes/alta/*.augment` | - |
| `glowstick.lua` | Throwable light sources | `/items/active/alta/glowsticks/*.activeitem` | - |
| `loot.lua` | Loot boxes | `/items/active/alta/loot/**/*.activeitem` | [Treasure README](../../treasure/alta/README.md) |
| `rod.lua` | Fishing rods | `/items/active/alta/tools/rods/**/*.activeitem` | - |
| `set.lua` | Equipment packs | `/items/active/alta/sets/*.activeitem`<br>`/items/active/alta/packs/**/*.activeitem` | [Sets README](../active/alta/sets/README.md) |
| `shield.lua` | Shields | `/items/active/shields/*.activeitem` | - |
| `tool.lua` | Tools (scanner, nets, tillers, etc) | `/items/active/alta/scanner/*.activeitem`<br>`/items/active/alta/tools/**/*.activeitem` | - |

## Key Features

All scripts provide:

- **Enhanced tooltips** with lore and technical details
- **Alta Scanner integration** for extended item information
- **Color-coded descriptions** using alta palette (see `/.meta/world.json`)
- **Automatic metadata** generation for wiki and documentation

## Scripts

### Items

[`item.lua`](item.lua) script is a base script used by most regular items, like crafting materials, armors and weapons. More: [Modding: Basic Items](https://github.com/Ceterai/Enternia/wiki/Modding-Items#items)

### Consumables

[`consumable.lua`](consumable.lua) script enhances the base item script and is used by produce, prepared food and medicine. More: [Modding: Consumable Items](https://github.com/Ceterai/Enternia/wiki/Modding-Items#consumable-items)

### Spawners

[`spawner.lua`](spawner.lua) script enhances the base item script and is used by monster eggs and robot spawners. More: [Modding: Spawner Items](https://github.com/Ceterai/Enternia/wiki/Modding-Items#monster-spawners)

### Objects

[`object.lua`](object.lua) script enhances the base item script and is used by most objects. More: [Modding: Objects](https://github.com/Ceterai/Enternia/wiki/Modding-Items#objects)

### Saplings

[`sapling.lua`](sapling.lua) script enhances the object script and is used by sapling objects. More: [Modding: Saplings](https://github.com/Ceterai/Enternia/wiki/Modding-Items#saplings)

### Augments

[`augment.lua`](augment.lua) - EPP augments for back slot equipment enhancements with stat bonuses, special abilities, and energy type integrations.

### Collars

[`collar.lua`](collar.lua) - Pet collars that modify capture pod companions with stat modifications and special abilities.

### Codex Entries

[`codex.lua`](codex.lua) - Codex entries (Datamass, Ebook, Paper) containing lore, technical guides, and Alta Scanner extended descriptions.

### Dyes

[`dye.lua`](dye.lua) - Armor dyes for color customization with alta-themed palettes and faction-specific colors.

### Glowsticks

[`glowstick.lua`](glowstick.lua) - Throwable light sources with faction and biome themed colors for temporary illumination.

### Loot Boxes

[`loot.lua`](loot.lua) - Loot boxes containing randomized rewards (tier-based 0-5, biome-specific, event loot).

### Fishing Rods

[`rod.lua`](rod.lua) - Fishing rods with tier progression and special abilities for catching fish and treasures.

### Equipment Sets

[`set.lua`](set.lua) - Equipment packs containing full armor/weapon sets, farming packs, and specialized bundles.

### Shields

[`shield.lua`](shield.lua) - Shields with enhanced tooltips showing block damage stats and special abilities.

### Tools

[`tool.lua`](tool.lua) - Tools including the Alta Scanner, farming equipment (tillers, hoes, watering cans), bug nets, and utility tools (relocator, preserver, sprayer).

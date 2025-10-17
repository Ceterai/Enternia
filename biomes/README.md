# My Enternia Biomes

This folder contains all custom biome definitions for the Enternia mod, introducing new environments, regions, and world layers for the mod's planets.

## Structure

- Biomes are organized by planet or world type (e.g., `alterash/`, `alterash_prime/`, `core/`, `space/`).
- Each `.biome` file defines a unique biome, with properties such as name, friendlyName, description, icon, blocks, spawn profiles, and music.
- Subfolders group biomes by planetary region (e.g., `surface/`, `underground/`, `antorash/`, `evarus/`, etc).

## Key Folders

- `alterash/`: Biomes for alterash planets, including surface, underground, and special regions.
- `alterash_prime/`: Biomes for alterash prime planets, with unique environments, caves, and surface areas.
- `core/`: Biomes for the planet's core layer, shared for alterash and alterash prime.
- `space/`: Space and asteroid field biomes.

## Biome File Example

```jsonc
{
  "name" : "ct_alterash_caves",
  "friendlyName" : "Alterash Caves",
  "description" : "Lush shallow caves full of growth and prisms.",
  "longdescription" : "These caves are teeming with life, featuring bioluminescent plants and unique crystal formations.",
  "altaDescription" : "A vibrant ecosystem hidden beneath the surface.",
  "icon" : "/items/active/alta/loot/tier1.png",
  "mainBlock" : "moonstone",
  "subBlocks" : [ "moonrock", "moondust" ],
  "ores" : "ct_alterash_depth1",
  // ...other biome properties...
}
```

## Integration

- Biomes are referenced in planet generation configs, treasure pools, and world scripts.
- For adding new biomes, follow the structure and naming conventions in this folder.
- See the [Modding: Biomes](https://steamcommunity.com/sharedfiles/filedetails/?id=2128333589) for detailed explanation on how biomes work.

## See Also

- [Worldbuilding: Biomes & Regions](../../.meta/world.json)
- [Planet & Region Lore](https://github.com/Ceterai/Enternia/wiki/Alterash)

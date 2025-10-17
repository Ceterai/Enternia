# My Enternia Tenants

> Main page: [My Enternia NPCs](../npcs/README.md)

This folder contains all tenant definitions for the My Enternia mod, including custom alta, floran, and other species tenants, as well as themed, biome, and tiered tenants. Tenants are special NPCs that can be spawned in player-built colonies or specific environments, each with unique requirements, roles, and rewards.

## Folder Structure

- **alta.tenant**: Main alta tenant definition (generic alta tenant).
- **alta/**: Contains all alta-related tenants, organized by:
  - **calin.tenant, capital.tenant, dancer.tenant, gamer.tenant**: Specialized alta tenants for unique roles or locations.
  - **androids/**: Tenants for alta androids and droids, including security, lab, elite, and faction-specific androids.
  - **biome/**: Tenants themed around specific biomes (calline, stardust, viona, warped, yaara).
  - **guards/**: Security and guard tenants, organized by tier (tier3–tier7) and faction (EDS, Faradea, etc.).
  - **merchants/**: Shopkeeper tenants for various alta professions (artist, botanics, chef, designer, etc.).
  - **official/**: Official and government-related tenants (city, capital, citadel, EDS, security, etc.).
  - **researchers/**: Researcher tenants, further divided into field, lab, themed, and trade researchers.
  - **service/**: Service and support tenants (agent, cargo, merchant, social, security, etc.).
  - **tech/**: Technical profession tenants (engineer, mechanic, miner, rescue).
  - **themed/**: Themed tenants (colors, cosplay, holiday, human, miniknog, order, retro, travel, tropical).
  - **tiered/**: Tenants organized by progression tier (tier0–tier10).
- **floran/**: Floran and plant-themed tenants (arigaran, yaara, etc.).
- **other/**: Miscellaneous tenants (aric, viona creature, etc.).

## .tenant File Structure

Each `.tenant` file defines a tenant NPC and includes:

- **"name"**: Unique tenant ID (should use the `ct_` prefix for custom tenants).
- **"type"**: NPC type or species (e.g., alta, floran, android).
- **"requireTags"**: List of tags required in the room for the tenant to spawn (e.g., furniture, objects, biome tags).
- **"priority"**: Determines spawn priority if multiple tenants are eligible.
- **"colonyTags"**: Tags that the tenant adds to the colony (affects other tenants).
- **"itemPools"**: Defines rent rewards or items given by the tenant.
- **"npc"**: The NPC type or reference (links to a `.npctype` file in `/npcs`).
- **"uniqueId"**: (Optional) Used for unique or story tenants.
- **Other fields**: May include dialogue, quest hooks, or custom behaviors.

See the [My Enternia NPCs README](../npcs/README.md) for more details on NPC and tenant configuration, shop pools, and advanced behaviors.

## Adding or Modifying Tenants

- Place new tenant definitions in the appropriate subfolder by role, biome, or tier.
- Use the `ct_` prefix for all custom tenant IDs to avoid conflicts.
- Reference the correct NPC type in the `npc` field (see `/npcs`).
- For complex tenants (e.g., androids, guards, merchants), review similar files for conventions and required tags.
- For rent/item pools, see the loot conventions in `/treasure/alta/README.md`.

## More Information

- [My Enternia NPCs README](../npcs/README.md)
- [My Enternia Wiki: Tenants](https://github.com/Ceterai/Enternia/tree/main/.meta/wiki/tenants.md)
- [Starbound Wiki: Tenants](https://starbounder.org/Tenant)

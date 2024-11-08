A patch that makes the new critters actually spawn into the world, and also focuses on rebalancing armor prices and adding an "author" field to the **Alta Scanner**. It also makes the **Security Set** fully upgradeable.

### Main

- armor improvements;
- bug fixes.

### Alta

- **Alta Scanner** now displays the item/object author, if it was set within the item's config or parameters;
- alta armor and clothing now supports [Futara's Dragon Pixel Full Bright Shader](https://steamcommunity.com/sharedfiles/filedetails/?id=2422986190);
- added upgrades to the **Security Set**.

### Translation

- moved drone (`_drone`) spawner items from `/items/active/unsorted/alta/spawner/` root to `/items/active/unsorted/alta/spawner/drones/` subdirectory;
- moved drone (`_droid`) spawner items from `/items/active/unsorted/alta/spawner/` root to `/items/active/unsorted/alta/spawner/droids/` subdirectory;
- added an author-related label to `/items/buildscripts/ct_texts.config:scan.author`;
- reworked lines in `/items/armors/alta/tier4/security/helmet/ct_alta_security_helmet.head`;
- added lines in:
  - `/items/armors/alta/tier4/security/chest/ct_alta_security_chest.head`;
  - `/items/armors/alta/tier4/security/legwear/ct_alta_security_legwear.legs`;
  - `/items/armors/alta/tier4/security/pack/ct_alta_security_pack.back`.

### Dev

- further enhancement to the deploy script to add pre-deployment checks and a release message;
- updated armor config values to have unified tags and rely on automatical price & rarity assignment;
- updated clothing config values to have unified tags and rely on automatical price & rarity assignment.

### Other

- minor grammar fixes in robohelper spawner items added in the last update;
- minor bug fixes.

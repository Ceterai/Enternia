This patch focuses on fixing a critical bug with one of the weapons found in the Koywa biome and a cape in a Stardust Merchant's shop (no more Tool Mimic errors).

It also introduces a new food balancing system called Alta BGMR2.

Finally, the patch prepares the game for the 2.4 update.

### Main

- added support for [Many Tabs](https://steamcommunity.com/sharedfiles/filedetails/?id=1119086325):
  - also added a fallback alta category button for when the mod is not installed.  
  ![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/.meta/images/showcase/2.3.4e/tabs1.png)![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/.meta/images/showcase/2.3.4e/tabs2.png)
- fixed some critical and other issues.

### Alta

- updated icons for **Alta Tier 0 Pad**, **Gyera Loot Crate** and **Haven Loot Crate**;
- updated rent loot for most **Alta Tenants** to make it level-dependent and more related to their character/profession;
- updated prices and rarities for most codexes;
- updated **Alta Datacenter** to depend on discovering blueprints:
  - all codexes now discover themselves and other items.

### Translation

- fixed typos in the **Ayaka Tree** sapling description;
- fixed typos in the **Tavriya Codex** and **Alta Lab Tanks**;
- moved food aging strings from `items/generic/food/ct_ionic_rotting.config:rotTimeDescriptions` to `items/buildscripts/ct_texts.config:aging.descriptions` and made them a `dict` instead of a `list`.

### Dev

- added a new consumable item balance system - **Alta Bromatology, Gastronomy & Medicine Regulation M2**, or **Alta BGMR2** for short:
  - it calculates food value, rot time and effect time based on several values that keep items of the same level roughly similar in power;
  - updated default values for food, prepared food, drinks and cooking ingredients;
  - updated existing shop items, produce and cooking ingredients to reflect these changes;
  - unified and refactored food build and aging scripts;
  - improved expiry/aging/fermenting messages:
    - made them more granular (`5` -> `20` messages) divided into 4 categories:
      - **Fermenting** (up to 30 minutes);
      - **Fresh** (up to 8 hours);
      - **Preserved** (up to 2 weeks);
      - **Unexpirable** (up to 256 years).
    - gave them a broader range (`300 - 999999` seconds range to `10 - 8078579712`, or `10` seconds to `256` years);
    - moved them to a shared translation file and made them easier to translate.  
  ![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/.meta/images/showcase/2.3.4e/food1.png)![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/.meta/images/showcase/2.3.4e/food2.png)![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/.meta/images/showcase/2.3.4e/food3.png)![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/.meta/images/showcase/2.3.4e/food4.png)![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/.meta/images/showcase/2.3.4e/food5.png)![ ](https://raw.githubusercontent.com/Ceterai/Enternia/main/.meta/images/showcase/2.3.4e/food6.png)
- added `alta_loot` and `alta_ancient` recipe groups for items that normally can only be found through loot and item anvil upgrades;
- added **Alta Universal Information & Knowledge Accumulation**, or **Alta UIKA** - a generated `.json` document:
  - contains information on how to obtain & use all items in the mod;
  - can be used by items in the game to access enhanced information without having to calculate it on the spot;
  - can be used for generating the wiki.
- updated Steam and Starbound Forums descriptions;
- updated the README by adding alternative text and lazy loading to images.

### Other

- decreased **Yaara Heart**'s object collision from 8x8 blocks to 7x7 blocks and added gaps in it to make it easier for world gen to spawn it;
- fixed incorrect item mimics in the **Koywa Chest** and in the **Stardust Merchant** shop;
- updated colony tags on crops;
- minor bug fixes.

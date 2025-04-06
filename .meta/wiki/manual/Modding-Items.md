> Main page: [[ Modding ]]

This page contains modding information about [[ items ]] added by this mod, including item builders, item scripts, weapon abilities, etc.

- [Items](#items)
  - [Item Builder Parameters](#item-builder-parameters)
- [Weapons](#weapons)
  - [Weapon Builder Parameters](#weapon-builder-parameters)
  - [Abilities](#abilities)
- [Objects](#objects)
  - [Object Builder Parameters](#object-builder-parameters)
  - [Object Logic](#object-logic)
    - [Switch Logic](#switch-logic)
  - [Saplings](#saplings)
- [Consumable Items](#consumable-items)
  - [Consumable Builder Parameters](#consumable-builder-parameters)
  - [Variants](#variants)
- [Monster Spawners](#monster-spawners)
  - [Spawner Builder Parameters](#spawner-builder-parameters)
  - [Spawner Logic](#spawner-logic)
    - [Spawner Projectile](#spawner-projectile)

> Note: Read more about item and object build scripts here: [Alta Item Builders](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/README.md)

## Items

Most items in this mod use a custom item builder. It extracts as much information as possible from an asset and calculates params and tooltips based on them.

It is currently used for:

- [[ Crafting Materials & Cooking Ingredients|Generic-Items ]]
- [[ Epp Augments & Pet Collars|Enhancement-Items ]]
- [[ Active Items (Weapons, Shields, Loot Items)|Active-Items ]]
- [[ Clothing|Clothing ]]
- [[ Codexes|Codexes ]]

The builder is located here: [`/items/buildscripts/alta/item.lua`](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/item.lua)

Refer to the builder file for more documentation.

### Item Builder Parameters

More info: [Alta Item Builders - Items](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/README.md#items)

All listed parameters are optional.

| Parameter | Default | Description |
| - | - | - |
| `level` | 1 | Item level. Will not be overridden by custom levels if `fixedLevel` is set to `true`. |
| `price` | 0 | Can be fixed if `fixedPrice` is `true`, or level-dependant. |
| `race` | `nil` | Will be displayed in a tooltip if set. |
| `fixedLevel` | `true` | Prevents the level param from being overwritten with custom values. |
| `fixedPrice` | `false` | If false, the price will be calculated based on level using `itemLevelPriceMultiplier` calc function. |
| `damageLevelMultiplier` | 1.0 | Calculates based on item level using the `weaponDamageLevelMultiplier` calc function. |
| `elementalType` | `"physical"` | Can match any existing element, just like with original Starbound weapons. If set, replaces the `<elementalType>` patterns in asset's data. |
| `primaryAbility` | `nil` | Primary ability, supports `elementalConfig`. Not used by majority of items. |
| `altAbility` | `nil` | Special ability, supports `elementalConfig`. Not used by majority of items. |
|   |   |   |
| `palette` | `nil` | Used for color swaps like with original Starbound weapons. |
| `colorIndex` | 1 | Used for color swaps like with original Starbound weapons. |
|   |   |   |
| `baseDps` or `primaryAbility.baseDps` | 0 | Item's DPS. If set, will be displayed in some tooltips. |
| `fireTime` or `primaryAbility.fireTime` | 0.0 | Item's general Fire Rate. If set, will be displayed in some tooltips. |
| `energyUsage` or `primaryAbility.energyUsage` | 0 | Item's general Energy Usage. If set, will be displayed in some tooltips. |
|   |   |   |
| `baseShieldHealth` | 0.0 | Item's leveled Shield Health. If set, will be displayed in some tooltips. |
| `cooldownTime` | 0 | Item's general Cooldown Time. If set, will be displayed in some tooltips. |
| `knockback` | 0 | Item's general Knockback. If set, will be displayed in some tooltips. |
| `minActiveTime` | 0 | Item's general Min Time. If set, will be displayed in some tooltips. |
| `perfectBlockTime` | 0 | Item's general Parry Time. If set, will be displayed in some tooltips. |
| `forceWalk` | `false` | Item's general "Heaviness" determinator, used in shields to determine whether it will force you to walk when raise. Not currently displayed. |
|   |   |   |
| `primaryAbility.name` | `"unknown"` | Primary ability name for tooltips. |
| `primaryAbility.description` | `""` | Primary ability description for tooltips. |
| `altAbility.name` | `"unknown"` | Special ability name for tooltips. If not set, tries to use the ability default first, and only then the default mentioned here. |
| `altAbility.description` | `""` | Special ability description for tooltips. |
| `passiveAbility.name` | `"unknown"` | Passive ability name for tooltips. Will replace Special if set. |
| `passiveAbility.description` | `""` | Passive ability description for tooltips. Will replace Special if set. |
| `upgradeParameters` | `nil` | For upgrades: [Weapons: Upgrades](Weapons#Upgrades). |
| `upgradeParameters.shortdescription` | `nil` | Upgrade name for tooltips. |

## Weapons

> Main page: [[ Weapons ]]

Most [[ weapons and shields|Active-Items ]] in this mod use a custom item builder, custom logic and custom abilities.

The builder used is the same mentioned in the previous section.

### Weapon Builder Parameters

Weapons and shields support the same parameters as in [[ Supported Item Parameters|Modding-Items#Supported Item Parameters ]].

### Abilities

Used custom weapon scripts and abilities can be found here:

Weapon Base:

- [`/items/active/weapons/ct_alta_weapon.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/weapons/ct_alta_weapon.lua)

Melee Bases:

- [`/items/active/weapons/melee/alta/melee.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/weapons/melee/alta/melee.lua)
- [`/items/active/weapons/melee/alta/enhanced.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/weapons/melee/alta/enhanced.lua)
- [`/items/active/weapons/melee/alta/special.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/weapons/melee/alta/special.lua)

Ranged Bases:

- [`/items/active/weapons/ranged/alta/ranged.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/weapons/ranged/alta/ranged.lua)
- [`/items/active/weapons/ranged/alta/rifle.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/weapons/ranged/alta/rifle.lua)

Special Ranged Abilities:

- [`/items/active/weapons/ranged/alta/abils/chakram/chakram.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/weapons/ranged/alta/abils/chakram/chakram.lua)
- [`/items/active/weapons/ranged/alta/abils/grapple/grapple.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/weapons/ranged/alta/abils/grapple/grapple.lua)
- [`/items/active/weapons/ranged/alta/abils/orbs/orbs.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/weapons/ranged/alta/abils/orbs/orbs.lua)

Read more about supported weapon abilities: [[ Weapon Mechanics|Weapons#Mechanics ]]

## Objects

Most [[ objects ]] in this mod use a custom item builder. It enhances the item builder mantioned above.

The builder is located here: [`/items/buildscripts/alta/object.lua`](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/object.lua)

### Object Builder Parameters

More info: [Alta Item Builders - Objects](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/README.md#objects)

All listed parameters are optional.

| Parameter | Default | Description |
| - | - | - |
| Item Builder Params | - | All parameters mentioned in the **Supported Item Parameters** section. |
| `smashOnBreak` or `smashable` | `false` | If set, displays tooltip note "This object doesn't drop itself when broken/smashed!" |
| `slotCount` | `nil` | If set, displays in a tooltip. |
| `lightColor` | `nil` | If set, displays the color in a form of a star in a tooltip. |
| `colonyTags` | `[]` | If set, displays in a tooltip. |
| `health` | 1.0 | Displays in a tooltip, multiplied by 10. |
|   |   |   |
| `touchDamage.baseDamage` or `touchDamage.damage` or `touchDamage.power` or `baseDamage` or `damage` or `power` | `nil` | If set, displays in a tooltip. |
| `touchDamage.fireTime` or `fireTime` | `nil` | If set, displays in a tooltip. |
| `touchDamage.energyUsage` or `energyUsage` | `nil` | If set, displays in a tooltip. |
| `touchDamage.knockback` or `knockback` | `nil` | If set, displays in a tooltip. |

### Object Logic

Some objects use scripts to function, with a lot of them using custom scripts made for this mod.

#### Switch Logic

Most switch-like and light-like objects in the mod use a single custom script with many parameters.  
This script can be found here: [`/objects/alta/switch.lua`](https://github.com/Ceterai/Enternia/blob/main/objects/alta/switch.lua)

### Saplings

More info: [Alta Item Builders - Saplings](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/README.md#saplings)

## Consumable Items

[[ Consumable items like Food, Medicine, etc.|Consumable-Items ]] in this mod use a custom item builder. It enhances the original **buildfood.lua**.

The builder is located here: [`/items/buildscripts/alta/consumable.lua`](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/consumable.lua)

### Consumable Builder Parameters

More info: [Alta Item Builders - Consumables](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/README.md#consumables)

All listed parameters are optional.

| Parameter | Default | Description |
| - | - | - |
| Item Builder Params | - | All parameters mentioned in the **Supported Item Parameters** section. |
| `fixedPrice` | `true` | Unlike for other items, this value is true by default. |
|   |   |   |
| `rotConfig` | [`"/items/generic/food/ct_ionic_rotting.config"`](https://github.com/Ceterai/Enternia/blob/main/items/generic/food/ct_ionic_rotting.config) | Path to rotting config, if used. |
| `timeToRot` | `nil` | If set, sets fixed max rotting time without multipliers. |
| `rottingMultiplier` | 1.0 | If `timeToRot` isn't set, this is used to dynamically determine those parameters. |
| `foodValue` | `nil` | If set, displays in a tooltip. |
|   |   |   |
| `variants` | `[]` | If set, displays in a tooltip. If the item has an aging spript attached, this might be used to turn the item into one of possible variants. |

### Variants

Consumable items that have a `variants` parameter set and use an aging scripted called [`/items/generic/food/ct_food_aging.lua`](https://github.com/Ceterai/Enternia/blob/main/items/generic/food/ct_food_aging.lua) have a chance to turn into one of the variants shortly after crafting.

This is mainly used for the [[ Perfectly Cooked Food|Food#Perfectly-Cooked-Food ]] mechanic.

## Monster Spawners

[[ Monster Spawners|Throwable-Items#monster-spawners ]] in this mod use a custom item builder.

The builder is located here: [`/items/buildscripts/alta/spawner.lua`](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/spawner.lua)

### Spawner Builder Parameters

More info: [Alta Item Builders - Spawners](https://github.com/Ceterai/Enternia/blob/main/items/buildscripts/alta/README.md#spawners)

All listed parameters are optional except for `asset`.

| Parameter | Default | Description |
| - | - | - |
| Item Builder Params | - | All parameters mentioned in the **Supported Item Parameters** section. |
|   |   |   |
| `asset` | `nil` | Path to the `.monstertype` file to load config from. |
| `subtitle` | `Tool` | An item subtitle displayed in the tooltip. |
| `pets` | `nil` | If set, a random monster is selected from this list. |

### Spawner Logic

The logic is similar to how [Capture Pods](https://starbounder.org/Capture_Pod) work - on use, a monster spawner releases a creature contained within it.  
The file with the logic is located here: [`/items/active/alta/spawner.lua`](https://github.com/Ceterai/Enternia/blob/main/items/active/alta/spawner.lua)

#### Spawner Projectile

Activating a monster spawner item involves throwing a special projectile containing custom logic.  
This logic can be found here: [`/projectiles/spawner/ct_monster_spawner.lua`](https://github.com/Ceterai/Enternia/blob/main/projectiles/spawner/ct_monster_spawner.lua)

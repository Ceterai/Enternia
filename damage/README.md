# My Enternia Damage Types

This folder contains custom damage type definitions for the My Enternia mod.

## Structure

- Each `.damage` file defines a unique damage type used by weapons, monsters, or effects in the mod.
- Each damage type has a corresponding `.png` icon for use in tooltips, UI, or effect popups.

## Included Damage Types

| File                | Description                              |
|---------------------|------------------------------------------|
| `ct_impulse.damage` | Defines the impulse/pulse damage type, associated with impulse energy and certain weapons or abilities. |
| `ct_ionic.damage`   | Defines the ionic/ion/ionized damage type, used for ionic energy attacks and effects. |
| `ct_plasma.damage`  | Defines the plasma/plasmic damage type, used for plasma-based weapons and abilities. |

Each `.png` file provides the icon for its respective damage type.

## Usage

- These damage types are referenced in weapon, effect, and monster configuration files throughout the mod (see `items/active/alta/`, `monsters/`, and `stats/effects/`).
- To add a new damage type, create a `.damage` file and a matching `.png` icon, then reference them in your item or effect configs.

## See Also

- [Color Codes & Lore Terms](../../.meta/world.json)
- [Weapons & Tools](../items/active/alta/), [Status Effects](../stats/effects/)

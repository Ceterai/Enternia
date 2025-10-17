# Alta Treasure

> Main pages (wiki links): [Modding](https://github.com/Ceterai/Enternia/wiki/Modding)

This folder contains loot table and treasure chest definitions for the alta species.

## Loot Tables

Loot table definitions used for alta items, creatures and objects.

### Basic

Base alta treasure that defines casual drops used by other loot tables.

Location: [`basic.treasurepools`](./basic.treasurepools)

### Pods

Alta pod loot. Used for randomly generated pods.

Location: [`pods.treasurepools`](./pods.treasurepools)

Treasure chest definitions for alta pods: [Treasure Chests](#treasure-chests)

### Robotics

Loot dropped by alta robots, like drones, droids and androids.

Location: [`robotics.treasurepools`](./robotics.treasurepools)

### GSR

Possible rewards from a GSR pod, mainly weapons.

Location: [`gsr.treasurepools`](./gsr.treasurepools)

### Sets

Contents of armor sets found here: [Modding: Alta Sets](/items/active/alta/sets/README.md#sets)

Location: [`robotics.treasurepools`](./robotics.treasurepools)

### Rent

Rent is periodically given to the player by tenants of colonies built by the player. Full tenant list: [Tenants](/.meta/wiki/tenants.md)

Location: [`rent.treasurepools`](./rent.treasurepools)

### Loot Table Sctructure

Most loot tables follow the structure below:

```jsonc
{
  "<Table ID>" : [
    [<Min Level>, {
      "poolRounds" : [
        [<Round Option Weight>, <Round Option Count>],  // Each round option chooses how many times to pull from the "pool".
        [0.4, 2]
      ],
      "pool" : [
        // Weights don't have to add up to 1.
        {"weight" : <Item Weight>, "item" : "<Item ID>"},  // It's possible to only pass item ID in the "item" field.
        {"weight" : <Item Weight>, "item" : [ "<Item ID>", <Item Amount> ] }, // But it's also possible to pass amount and parameters in the as well - as a list.
        {"weight" : <Item Weight>, "item" : [ "<Item ID>", <Item Amount>, { "<Parameter 1>" : <Value 1> } ] }
      ]
    } ]
  ]
}
```

#### Loot Table Example

```jsonc
{
  "ct_alta_loot" : [
    [0, {
      "poolRounds" : [ [0.1, 1], [0.4, 2], [0.4, 3], [0.1, 4] ],
      "pool" : [
        {"weight" : 0.01, "item" : "nanowrap"},
        {"weight" : 0.02, "item" : [ "ct_alta_dye", 2 ] },
        {"weight" : 0.045, "item" : [ "ct_catalyst", 1, { "preset" : "repell" } ] },
        {"weight" : 0.0025, "item" : "ct_alta_roomba"}
      ]
    } ],
    [2.5, {
      "poolRounds" : [ [0.1, 3], [0.3, 4], [0.5, 5], [0.1, 6] ],
      "pool" : [
        {"weight" : 0.01, "item" : "nanowrap"},
        {"weight" : 0.02, "item" : [ "ct_alta_dye", 2 ] },
        {"weight" : 0.045, "item" : [ "ct_catalyst", 1, { "preset" : "repell" } ] },
        {"weight" : 0.0025, "item" : "ct_alta_roomba"}
      ]
    } ]
  ],
  "ct_alta_codexes" : [ [0, { "poolRounds" : [ [1.0, 1] ],
        "pool" : [
          {"weight" : 0.08, "item" : "ct_docs_cen-codex"},
          {"weight" : 0.08, "item" : "ct_docs_datamass-codex"},
          {"weight" : 0.08, "item" : "ct_docs_drones-codex"},
          {"weight" : 0.08, "item" : "ct_docs_energy-codex"}
        ]
  } ] ]
}
```

## Treasure Chests

Alta chest definitions for the pod loot tables in [Loot Tables: Pods](#pods) and alta pods found at `/objects/alta/`

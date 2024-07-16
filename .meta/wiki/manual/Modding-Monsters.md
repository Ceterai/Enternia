> Main page: [[ Modding ]]

This page contains technical information regarding [[ monsters ]] added by this mod.

### Effects

Monsters created in this mod can have permanent status effects on them. This is due to a custom **monster builder**.

The builder is located here: [/monsters/ct_ioterash_monster.lua](https://github.com/Ceterai/Enternia/blob/main/monsters/ct_ioterash_monster.lua)

Example: [[ Scout Drone ]]

### Abilities

You may notice that most monsters have fields like `primaryAbility` and `passiveAbility` in their files. This is mainly for use by [[ Monster Spawners|Modding-Items#Monster Spawners ]] for display in tooltips, and for display on the **wiki**.

Example: [[ Scout Drone ]]

### Behavior

Currently there is a WIP alarm behavior in place. It is not used as of right now.

### Ship Pets

Species pets in this mod can make sounds (often) and sing (rarely).

Scripts implementing that:

- [/monsters/alta/pets/drone/petBehavior.lua](https://github.com/Ceterai/Enternia/blob/main/monsters/alta/pets/drone/petBehavior.lua)
- [/monsters/alta/pets/drone/singState.lua](https://github.com/Ceterai/Enternia/blob/main/monsters/alta/pets/drone/singState.lua)
- [/monsters/alta/pets/drone/soundState.lua](https://github.com/Ceterai/Enternia/blob/main/monsters/alta/pets/drone/soundState.lua)

Pet example: [[ Personal Drone ]]

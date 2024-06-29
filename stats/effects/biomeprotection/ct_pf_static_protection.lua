-- Default Starburst init
local SRinit = init


-- ### Biome Static Protection
-- Mod support for Starburst Rework  
-- Read more here: https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#starburst-rework
function init()
  if SRinit then SRinit() end
  local immunities = {
    {stat = "ionicStatusImmunity", amount = 1},
  }
  effect.addStatModifierGroup(immunities)
end

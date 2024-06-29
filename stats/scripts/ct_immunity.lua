require "/stats/scripts/ct_animation.lua"


-- ### Immunity Effect
-- Sets element-related stats like resistance and immunity to the player while the effect is active, or strips of them.
function init()
  initAnimation()
  initImmunityStats()
  script.setUpdateDelta(0)
end

-- Sets element-related stats like resistance and immunity to the player while the effect is active, or strips of them.
--
-- Supported stats:
-- - `protection`: number value (default is `0`)
-- - `physicalResistance`: percentage value (default is `0.0`)
-- - `<element>Resistance`: percentage value (default is `0.0`)
-- - `<element>StatusImmunity`: boolean value (default is `false`) - if `true`, sets according stat to `1.0`
-- - `<alta element>StatusImmunity`: boolean value (default is `false`) - if `true`, sets according stat to `1.0`
-- - `<mod element>StatusImmunity`: boolean value (default is `false`) - if `true`, sets according stat to `1.0`
-- - `remove<Element>Immunity`: boolean value (default is `false`) - if `true`, sets according immunity stat to `0.0`
--
-- `<element>` is any of the following: `ice`, `fire`, `poison`, `electric`  
-- `<alta element>` is any of the following: `impulse`, `plasma`, `ionic`, `hevikai`, `dream`, `void`  
-- `<mod element>` is any of the following: `pf_biomelightning`, `pf_mildBiomeLightningImmunity`
function initImmunityStats()
  local modifiers = jarray()
  modifiers = getVanillaResistanceStats(modifiers)
  modifiers = getVanillaImmunityStats(modifiers)
  modifiers = getMEImmunityStats(modifiers)
  modifiers = getSRImmunityStats(modifiers)
  effect.addStatModifierGroup(modifiers)
end

function getVanillaResistanceStats(modifiers)
  params = {
    "protection",
    "physicalResistance",
    "electricResistance",
    "poisonResistance",
    "fireResistance",
    "iceResistance",
  }
  for _, param in ipairs(params) do
    local val = config.getParameter(param, 0)
    if val ~= 0 then table.insert(modifiers, {stat = param, amount = val}) end
  end
  return modifiers
end

function getVanillaImmunityStats(modifiers)
  params = {
    "electricStatusImmunity",
    "poisonStatusImmunity",
    "fireStatusImmunity",
    "iceStatusImmunity",
  }
  for _, param in ipairs(params) do
    local val = config.getParameter(param, false)
    if val then table.insert(modifiers, {stat = param, amount = 1.0}) end
  end
  if config.getParameter("removeElectricImmunity", false) then
    table.insert(modifiers, {stat = "electricStatusImmunity", effectiveMultiplier = 0.0})
  end
  if config.getParameter("removePoisonImmunity", false) then
    table.insert(modifiers, {stat = "poisonStatusImmunity", effectiveMultiplier = 0.0})
  end
  if config.getParameter("removeFireImmunity", false) then
    table.insert(modifiers, {stat = "fireStatusImmunity", effectiveMultiplier = 0.0})
  end
  if config.getParameter("removeIceImmunity", false) then
    table.insert(modifiers, {stat = "iceStatusImmunity", effectiveMultiplier = 0.0})
  end
  return modifiers
end

-- My Enternia immunities
function getMEImmunityStats(modifiers)
  params = {
    "impulseStatusImmunity",
    "plasmaStatusImmunity",
    "ionicStatusImmunity",
    "hevikaiStatusImmunity",
    "dreamStatusImmunity",
    "voidStatusImmunity",
  }
  for _, param in ipairs(params) do
    local val = config.getParameter(param, false)
    if val then table.insert(modifiers, {stat = param, amount = 1.0}) end
  end
  return modifiers
end

-- Mod support area

-- Mod support for Starburst Rework  
-- Read more here: https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#starburst-rework
function getSRImmunityStats(modifiers)
  -- `root.itemConfig("antidote").config.effects[1][1]` is `antidote` in vanilla.
  -- it's a table in SR, and the `effect` value is `pf_biomepoisonprotection`.
  if root.itemConfig("antidote").config.effects[1][1].effect == "pf_biomepoisonprotection" then
    params = {
      "pf_biomelightningImmunity",
      "pf_mildBiomeLightningImmunity",
    }
    for _, param in ipairs(params) do
      local val = config.getParameter(param, false)
      if val then table.insert(modifiers, {stat = param, amount = 1.0}) end
    end
    return modifiers
  end
  return modifiers
end

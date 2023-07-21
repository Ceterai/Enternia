require "/stats/scripts/ct_animation.lua"


-- ### Immunity Effect
-- Sets element-related stats like resistance and immunity to the player while the effect is active, or strips of them.
function init()
  initAnimation()
  initImmunityStats()
end

-- Sets element-related stats like resistance and immunity to the player while the effect is active, or strips of them.
--
-- Supported stats:
-- - `protection`: number value (default is `0`)
-- - `physicalResistance`: percentage value (default is `0.0`)
-- - `<element>Resistance`: percentage value (default is `0.0`)
-- - `<element>StatusImmunity`: boolean value (default is `false`) - if `true`, sets according stat to `1.0`
-- - `<alta element>StatusImmunity`: boolean value (default is `false`) - if `true`, sets according stat to `1.0`
-- - `remove<Element>Immunity`: boolean value (default is `false`) - if `true`, sets according immunity stat to `0.0`
--
-- `<element>` is any of the following: `ice`, `fire`, `poison`, `electric`  
-- `<alta element>` is any of the following: `impulse`, `plasma`, `ionic`, `hevikai`, `dream`, `void`
function initImmunityStats()
  effect.addStatModifierGroup({{stat = "protection", amount = config.getParameter("protection", 0)}})
  effect.addStatModifierGroup({{stat = "physicalResistance", amount = config.getParameter("physicalResistance", 0.0)}})
  effect.addStatModifierGroup({{stat = "electricResistance", amount = config.getParameter("electricResistance", 0.0)}})
  effect.addStatModifierGroup({{stat = "poisonResistance", amount = config.getParameter("poisonResistance", 0.0)}})
  effect.addStatModifierGroup({{stat = "fireResistance", amount = config.getParameter("fireResistance", 0.0)}})
  effect.addStatModifierGroup({{stat = "iceResistance", amount = config.getParameter("iceResistance", 0.0)}})

  if config.getParameter("removeElectricImmunity", false) then
    effect.addStatModifierGroup({{stat = "electricStatusImmunity", effectiveMultiplier = 0.0}})
  end
  if config.getParameter("removePoisonImmunity", false) then
    effect.addStatModifierGroup({{stat = "poisonStatusImmunity", effectiveMultiplier = 0.0}})
  end
  if config.getParameter("removeFireImmunity", false) then
    effect.addStatModifierGroup({{stat = "fireStatusImmunity", effectiveMultiplier = 0.0}})
  end
  if config.getParameter("removeIceImmunity", false) then
    effect.addStatModifierGroup({{stat = "iceStatusImmunity", effectiveMultiplier = 0.0}})
  end

  if config.getParameter("electricStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "electricStatusImmunity", amount = 1.0}})
  end
  if config.getParameter("poisonStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "poisonStatusImmunity", amount = 1.0}})
  end
  if config.getParameter("fireStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "fireStatusImmunity", amount = 1.0}})
  end
  if config.getParameter("iceStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "iceStatusImmunity", amount = 1.0}})
  end

  if config.getParameter("impulseStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "impulseStatusImmunity", amount = 1.0}})
  end
  if config.getParameter("plasmaStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "plasmaStatusImmunity", amount = 1.0}})
  end
  if config.getParameter("ionicStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "ionicStatusImmunity", amount = 1.0}})
  end
  if config.getParameter("hevikaiStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "hevikaiStatusImmunity", amount = 1.0}})
  end
  if config.getParameter("dreamStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "dreamStatusImmunity", amount = 1.0}})
  end
  if config.getParameter("voidStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "voidStatusImmunity", amount = 1.0}})
  end
end

function update(dt)
end

function uninit()
end

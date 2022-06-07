function init()
  effect.addStatModifierGroup({{stat = "protection", amount = config.getParameter("protection", 0)}})
  effect.addStatModifierGroup({{stat = "electricResistance", amount = config.getParameter("electricResistance", 0.00)}})

  if config.getParameter("electricStatusImmunity", false) then
    effect.setStatModifierGroup({{stat = "electricStatusImmunity", amount = 1.0}})
  end
  if config.getParameter("ionicStatusImmunity", false) then
    effect.setStatModifierGroup({{stat = "ionicStatusImmunity", amount = 1.0}})
  end
end

function update(dt)
  
end

function uninit()
  
end
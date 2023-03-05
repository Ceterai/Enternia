require "/items/active/shields/shield.lua"

shield_init = init
shield_uninit = uninit
shield_raiseShield = raiseShield

function init()
  shield_init()
  self.effects = config.getParameter("statusEffects", { })
  self.raisedEffects = config.getParameter("raisedStatusEffects", { })
  if self.effects then
    status.setPersistentEffects(activeItem.hand().."ShieldPassive", self.effects)
  end
end

function uninit()
  shield_uninit()
  if self.effects then
    status.clearPersistentEffects(activeItem.hand().."ShieldPassive", self.effects)
  end
end

function raiseShield()
  shield_raiseShield()
  if self.raisedEffects then
    status.addPersistentEffects(activeItem.hand().."Shield", self.raisedEffects)
  end
end

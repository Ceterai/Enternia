function init()
  animator.setParticleEmitterOffsetRegion("electricalburn", mcontroller.boundBox())
  animator.setParticleEmitterActive("electricalburn", true)

  effect.addStatModifierGroup({{stat = "electricResistance", amount = config.getParameter("electricResistance", 0.00)}})
  effect.addStatModifierGroup({{stat = "poisonResistance", amount = config.getParameter("poisonResistance", 0.00)}})

  if config.getParameter("removeElectricStatusImmunity", false) then
    effect.addStatModifierGroup({{stat = "electricStatusImmunity", effectiveMultiplier = 0.0}})
  end

  -- effect.setParentDirectives(config.getParameter("directives", ""))

  self.movementModifiers = config.getParameter("movementModifiers", {})

  self.energyCost = config.getParameter("energyCost", 10)
  self.healthDamage = config.getParameter("healthDamage", 10)
  
  script.setUpdateDelta(config.getParameter("tickRate", 100) / 2)
  self.doPenalty = false

  effect.addStatModifierGroup({{stat = "energyRegenPercentageRate", effectiveMultiplier = 1}})

  if config.getParameter("queueRadioMessage", false) then
    world.sendEntityMessage(entity.id(), "queueRadioMessage", "ctbiomeelectric", 5.0)
  end
end

function update(dt)
  if self.doPenalty then
    self.doPenalty = false
  else
    self.doPenalty = true
  end
  if mcontroller.liquidId() == 1 and status.stat("electricStatusImmunity") == 0.0 then
    mcontroller.controlModifiers(self.movementModifiers)
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.healthDamage / 2,
        damageSourceKind = "electric",
        sourceEntityId = entity.id()
      })
  end
  if not status.overConsumeResource("energy", self.energyCost) and self.doPenalty and status.stat("electricStatusImmunity") == 0.0 then
    mcontroller.controlModifiers(self.movementModifiers)
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.healthDamage,
        damageSourceKind = "electric",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()

end

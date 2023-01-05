function init()
  animator.setParticleEmitterOffsetRegion("electricalburn", mcontroller.boundBox())
  animator.setParticleEmitterActive("electricalburn", true)

  -- effect.setParentDirectives(config.getParameter("directives", ""))

  self.movementModifiers = config.getParameter("movementModifiers", {})

  self.energyCost = config.getParameter("energyCost", 1)
  self.healthDamage = config.getParameter("healthDamage", 1)
  
  script.setUpdateDelta(config.getParameter("tickRate", 1) / 2)
  self.doPenalty = false

  effect.addStatModifierGroup({{stat = "energyRegenPercentageRate", effectiveMultiplier = 1}})

  world.sendEntityMessage(entity.id(), "queueRadioMessage", "ct_ionized_air", 5.0)
end

function update(dt)
  if self.doPenalty then
    self.doPenalty = false
  else
    self.doPenalty = true
  end
  if mcontroller.liquidId() == 1 then
    mcontroller.controlModifiers(self.movementModifiers)
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.healthDamage / 2,
        damageSourceKind = "electric",
        sourceEntityId = entity.id()
      })
  end
  if not status.overConsumeResource("energy", self.energyCost) and self.doPenalty then
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

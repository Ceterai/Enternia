function init()
  effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0.5}})
  animator.setParticleEmitterOffsetRegion("feathers", mcontroller.boundBox())
  animator.setParticleEmitterActive("feathers", true)
end

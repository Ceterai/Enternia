function init()
  effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = config.getParameter("fallDamageMultiplier", 0.5)}})
  animator.setParticleEmitterOffsetRegion("feathers", mcontroller.boundBox())
  animator.setParticleEmitterActive("feathers", true)
  animator.setParticleEmitterActive("jumpparticles", false)
end

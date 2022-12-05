require "/scripts/util.lua"

function init()
  animator.setParticleEmitterOffsetRegion("sparks", mcontroller.boundBox())
  animator.setParticleEmitterActive("sparks", true)
  effect.setParentDirectives("fade=7733AA=0.25")

  script.setUpdateDelta(60)

  self.damageClampRange = config.getParameter("damageClampRange")
  self.damageKind = config.getParameter("damageKind", "ct_ionic")

  self.tickTime = config.getParameter("boltInterval", 1.0)
  self.tickTimer = self.tickTime
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  local boltPower = util.clamp(status.resourceMax("health") * config.getParameter("healthDamageFactor", 1.0), self.damageClampRange[1], self.damageClampRange[2])
  if status.stat("electricStatusImmunity") > 0.0 and boltPower > 1 then boltPower = 1 end
  status.applySelfDamageRequest({
    damageType = "IgnoresDef",
    damage = boltPower,
    damageSourceKind = self.damageKind,
    sourceEntityId = entity.id()
  })
end

function uninit()

end

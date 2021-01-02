function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterActive("healing", config.getParameter("particles", true))

  script.setUpdateDelta(5)

  self.healingRate = 0.005 / config.getParameter("healTime", 1)
end

function update(dt)
  status.modifyResourcePercentage("health", self.healingRate * dt)
end

function uninit()
  
end

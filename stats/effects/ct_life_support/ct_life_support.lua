function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterActive("healing", config.getParameter("particles", true))
  script.setUpdateDelta(5)

  self.healingBase = config.getParameter("healBase", 0.005)
  self.healingTime = config.getParameter("healTime", 1)
  self.healingRate = self.healingBase / self.healingTime
end

function update(dt)
  status.modifyResourcePercentage("health", self.healingRate * dt)
end

function uninit()
  
end

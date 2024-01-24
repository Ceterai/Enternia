-- ### Healing Effect
-- Everytime you get hit you burst with particles. An analog of **Thorns**.
function init() initHealStats() end
function update(dt) healTick(dt) end
function uninit() end

-- Initializes params related to the **Healing Effect**.
function initHealStats()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterActive("healing", config.getParameter("particles", true))
  script.setUpdateDelta(5)
  self.healingStat = config.getParameter("healStat", "health")
  self.healingBase = config.getParameter("healBase", 0.005)
  self.healingTime = config.getParameter("healTime", 1)
  self.healingRate = self.healingBase / self.healingTime
end

function healTick(dt)  -- Replenishes `healStat`. Doesn't apply in case where a non-player entity has <= 5 health, if `healStat` set to health.
  if not (self.healingStat == "health" and entity.entityType() ~= 'player' and status.resource(self.healingStat) <= 5) then
    status.modifyResourcePercentage(self.healingStat, self.healingRate * dt)
  end
end

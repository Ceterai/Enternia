function init()
  self.maxShieldHealth = 0.0
  replenishShieldHealth()

  self.expirationTime = config.getParameter("expirationTime", 0.5)
  self.expirationTimer = self.expirationTime
  self.active = true

  self.visuals = config.getParameter("visuals", "border=3;00FFFF99;00000000")
  addVisualEffect()
end

function update(dt)
  if not status.resourcePositive("damageAbsorption") then
    if self.active then removeVisualEffect() end
    if self.expirationTimer <= 0 then effect.expire() end
    self.expirationTimer = self.expirationTimer - dt
    self.active = false
  else
    if not self.active then addVisualEffect() end
    self.expirationTimer = self.expirationTime
    self.active = true
  end
end

function replenishShieldHealth()
  local baseValue = config.getParameter("shieldBase", 0.0)
  local baseHealth = status.stat("maxHealth")
  local modHealth = config.getParameter("shieldFromHealthPercent", 0.0)
  local baseEnergy = status.stat("maxEnergy")
  local modEnergy = config.getParameter("shieldFromEnergyPercent", 0.0)
  local overall = math.min(math.abs(config.getParameter("shieldInitialPercent", 1.0)), 1.0)
  self.maxShieldHealth = (baseValue + (baseHealth * modHealth) + (baseEnergy * modEnergy)) * overall
  status.setResource("damageAbsorption", self.maxShieldHealth)
end

function addVisualEffect()
  if not config.getParameter("hideBorder") then effect.setParentDirectives(self.visuals) end
  animator.setAnimationState("shield", "on")
end

function removeVisualEffect()
  animator.setAnimationState("shield", "off")
  effect.setParentDirectives("")
end

function onExpire()
  status.setResource("damageAbsorption", 0)
end

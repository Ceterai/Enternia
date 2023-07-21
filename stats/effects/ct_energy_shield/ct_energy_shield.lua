-- ### Energy Shield Effect
-- Gives you damage absorbtion for a certain period of time.
function init()
  self.maxShieldHealth = 0.0
  replenishShieldHealth()

  self.expirationTime = config.getParameter("expirationTime", effect.duration())
  self.expirationTimer = self.expirationTime - 0.5
  self.active = true

  self.visuals = config.getParameter("visuals")
  addVisualEffect()
end

function update(dt) shieldTick(dt) end
function onExpire() status.setResource(getShieldStat(), 0) end
function uninit() status.setResource(getShieldStat(), 0) end

function shieldTick(dt)
  if self.active then
    if self.expirationTimer == 0 or not status.resourcePositive(getShieldStat()) then
      removeVisualEffect()
      self.active = false
      self.expirationTimer = 0.5
    end
  else if self.expirationTimer == 0 then effect.expire() end end
  self.expirationTimer = math.max(0, self.expirationTimer - dt)
end

function replenishShieldHealth()
  local baseValue = config.getParameter("shieldBase", 0.0)
  local baseHealth = status.stat("maxHealth")
  local modHealth = config.getParameter("shieldFromHealthPercent", 0.0)
  local baseEnergy = status.stat("maxEnergy")
  local modEnergy = config.getParameter("shieldFromEnergyPercent", 0.0)
  local overall = math.min(math.abs(config.getParameter("shieldInitialPercent", 1.0)), 1.0)
  self.maxShieldHealth = (baseValue + (baseHealth * modHealth) + (baseEnergy * modEnergy)) * overall
  status.setResource(getShieldStat(), self.maxShieldHealth)
end

function addVisualEffect()
  if self.visuals ~= nil then effect.setParentDirectives(self.visuals) end
  animator.setAnimationState("shield", "on")
  animator.playSound("shieldOn")
end

function removeVisualEffect()
  effect.setParentDirectives("")
  animator.setAnimationState("shield", "off")
  animator.playSound("shieldOff")
end

function getShieldStat()
  if status.isResource("shieldHealth") then return "shieldHealth" end
  if status.isResource("damageAbsorption") then return "damageAbsorption" end
  return "health"
end

-- ### Autoeffect
-- Attaches an ephemeral effect after a condition is met.
function init() initAutoeffectParams() end
function update(dt) autoeffectTick(dt) end
function uninit() effectDeactivate() end

-- The effect to be added is configured in the `effectConfig` param.
function initAutoeffectParams()
  self.energyUsage = 0
  if status.isResource("energy") then self.energyUsage = config.getParameter("energyUsage", 0) end
  self.cooldown = config.getParameter("cooldown", 30)
  self.cooldownTimer = 0

  local effectConfig = {}
  effectConfig.duration = nil
  effectConfig.type = "electrified"
  effectConfig.animActivate = "effectActivate"
  effectConfig.animActive = "effectActive"
  effectConfig.animDeactivate = "effectDeactivate"
  self.effectConfig = sb.jsonMerge(effectConfig, config.getParameter("effectConfig", {}))
  self.minHealthCoef = config.getParameter("minHealthPercent", 0.2)
end

function autoeffectTick(dt)
  if self.cooldownTimer <= 0 then
    if status.resourcePercentage("health") <= self.minHealthCoef and not self.active then
      effectActivate()
      self.cooldownTimer = self.cooldown
    end
  elseif not self.active then
    self.cooldownTimer = math.max(0, self.cooldownTimer - dt)
  end
  effectLoop(dt)
end

function effectActivate()
  if not self.active then
    status.addEphemeralEffect(self.effectConfig.type, self.effectConfig.duration)
    animator.playSound(self.effectConfig.animActivate)
    self.activeTimer = self.effectConfig.duration
    animator.playSound(self.effectConfig.animActive, -1)
    self.active = true
  end
end

function effectLoop(dt)
  if self.active then
    self.activeTimer = math.max(0, self.activeTimer - dt)
    if (self.energyUsage > 0 and not status.overConsumeResource("energy", self.energyUsage / 4 * dt)) or self.activeTimer == 0 then
      effectDeactivate()
    end
  end
end

function effectDeactivate()
  if self.active then
    status.removeEphemeralEffect(self.effectConfig.type)
    animator.stopAllSounds(self.effectConfig.animActive)
    animator.playSound(self.effectConfig.animDeactivate)
  end
  self.active = false
end

function init()
  self.energyUsage = config.getParameter("energyUsage", 20)
  self.cooldownTime = config.getParameter("cooldown", 30)
  self.cooldownTimer = 0

  local effectConfig = {}
  effectConfig.duration = 12
  effectConfig.name = "Auto Placed Effect"
  effectConfig.type = "electrified"
  effectConfig.animActivate = "effectActivate"
  effectConfig.animActive = "effectActive"
  effectConfig.animDeactivate = "effectDeactivate"
  self.effectConfig = sb.jsonMerge(effectConfig, config.getParameter("effectConfig", {}))
  self.minHealthCoef = config.getParameter("minHealthPercent", 0.2)
end

function update(dt)
  if self.cooldownTimer <= 0 then
    if status.resourcePercentage("health") <= self.minHealthCoef then
      effectActivate()
      self.cooldownTimer = self.cooldownTime
    end
  else
    self.cooldownTimer = self.cooldownTimer - dt
  end
  effectLoop(dt)
end

function effectActivate()
  status.setPersistentEffects(self.effectConfig.name, { self.effectConfig.type })
  animator.playSound(self.effectConfig.animActivate)
  self.activeTimer = self.effectConfig.duration
  if not self.active then
    animator.playSound(self.effectConfig.animActive, -1)
  end
  self.active = true
end

function effectLoop(dt)
  if self.active then
    self.activeTimer = math.max(0, self.activeTimer - dt)
    if not status.overConsumeResource("energy", self.energyUsage / 4 * dt) or self.activeTimer == 0 then
      self:effectDeactivate()
    end
  end
end

function effectDeactivate()
  status.clearPersistentEffects(self.effectConfig.name)
  animator.stopAllSounds(self.effectConfig.animActive)
  animator.playSound(self.effectConfig.animDeactivate)
  self.active = false
end

function uninit()

end

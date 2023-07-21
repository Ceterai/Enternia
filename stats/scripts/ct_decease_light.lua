require "/stats/scripts/ct_immunity.lua"
require "/stats/scripts/ct_immune.lua"
require "/stats/scripts/ct_animation.lua"
require "/stats/scripts/ct_message.lua"


-- ### Light Decease Effect
-- Includes following effects: **Immunity**.
function init()
  queueImmuneMessage()
  initAnimation()
  initImmunityStats()
  self.stat = config.getParameter("deceaseStat", "hevikaiStrike")
  self.expireTime = effect.duration()
end

function update(dt)
  if self.expireTime == effect.duration() then checkStatus() end
end

function uninit()
end

function checkStatus()
  if status.stat(self.stat) > 0 then
    status.addEphemeralEffect(config.getParameter("deceaseEffect", "ct_hevikai"))
    effect.expire()
  else
    effect.addStatModifierGroup({{stat = self.stat, amount = 1.0}})
  end
end

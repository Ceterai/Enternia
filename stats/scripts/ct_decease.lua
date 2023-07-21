require "/stats/scripts/ct_draining.lua"
require "/stats/scripts/ct_immunity.lua"


-- ### Decease Effect
-- Includes following effects: **Draining**, **Immunity**.
function init()
  queueImmuneMessage()
  initAnimation()
  initDrainStats()
  initImmunityStats()
  if semiImmune(true) then effect.modifyDuration(effect.duration()) end
end

function update(dt)
  drainTick(dt)
  if effect.duration() <= 0.75 then status.setResource("health", 0) end
end

function uninit()
end

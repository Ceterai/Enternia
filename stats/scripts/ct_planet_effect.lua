require "/stats/scripts/ct_draining.lua"
require "/stats/scripts/ct_liquid.lua"
require "/stats/scripts/ct_immunity.lua"


-- ### Planet Effect
-- Includes following effects: **Draining**, **Liquid**, **Immunity**.  
-- Does nothing but initiate and update those effects accordingly.
function init()
  queueImmuneMessage()
  initAnimation()
  initDrainStats()
  initLiquidStats()
  initImmunityStats()
end

function update(dt)
  drainTick(dt)
  liquidTick(dt)
end

function uninit()
end

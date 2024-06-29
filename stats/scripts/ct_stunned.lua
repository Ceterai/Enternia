require "/stats/scripts/ct_immune.lua"
require "/stats/scripts/ct_animation.lua"


-- ### Stunned Effect
-- A proper highly customizable stunned effect.
function init()
  initAnimation()
  -- stopping the entity in place
  mcontroller.setVelocity({0, 0})
  -- retrieving desired stun time from the `stunTime` parameter or the effect duration
  self.ct_stunTime = calculateImmunityToDamage(config.getParameter("stunTime", effect.duration()))
  -- setting stun to current stun time or the `stunTime` parameter or the effect duration (if entity can be stunned via resource at all)
  if status.isResource("stunned") then status.setResource("stunned", math.max(status.resource("stunned"), self.ct_stunTime)) end
  -- adding EMI Jam in not immune at all and `emi` set to `true`
  if not (barelyImmune(true)) and config.getParameter("emi", false) then effect.addStatModifierGroup({{stat = "emiJam", amount = 1.0}}) end
end

function update(dt)
  mcontroller.controlModifiers({ facingSuppressed = true, movementSuppressed = true })
end

function uninit()
end

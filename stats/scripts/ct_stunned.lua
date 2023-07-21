require "/stats/scripts/ct_immune.lua"
require "/stats/scripts/ct_animation.lua"


-- ### Stunned Effect
-- A proper highly customizable stunned effect.
function init()
  initAnimation()
  mcontroller.setVelocity({0, 0})
  self.ct_stunTime = calculateImmunityToDamage(config.getParameter("stunTime", effect.duration()))
  if status.isResource("stunned") then status.setResource("stunned", math.max(status.resource("stunned"), self.ct_stunTime)) end
  if not (barelyImmune(true)) and config.getParameter("emi", false) then effect.addStatModifierGroup({{stat = "emiJam", amount = 1.0}}) end
end

function update(dt)
  mcontroller.controlModifiers({ facingSuppressed = true, movementSuppressed = true })
end

function uninit()
end

require "/stats/scripts/ct_immune.lua"
require "/stats/scripts/ct_animation.lua"


-- ### Burning Effect
-- A proper highly customizable burning effect.
function init()
  initAnimation()
  animator.playSound("burn", -1)
  script.setUpdateDelta(5)

  self.tickDamagePercentage = config.getParameter("healthPercentage", 0.025)
  self.tickDamageKind = config.getParameter("damageKind", "fire")
  self.tickTime = config.getParameter("interval", 1.0)
  self.tickTimer = self.tickTime
  if immune() then effect.expire() end
end

function update(dt)
  if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then effect.expire() end
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({damageType="IgnoresDef", damage=getDamage(), damageSourceKind=self.tickDamageKind, sourceEntityId=entity.id()})
  end
end

function getDamage()
  return calculateImmunityToDamage(math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1)
end

function uninit()
end

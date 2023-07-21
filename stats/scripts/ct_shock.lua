require "/scripts/util.lua"
require "/stats/scripts/ct_immune.lua"
require "/stats/scripts/ct_animation.lua"


-- ### Burning Effect
-- A proper highly customizable shock effect. Similar to **Electrified**, except damages the target instead of nearby entities.
function init()
  initAnimation()
  script.setUpdateDelta(5)

  self.ct_shock = {}
  self.ct_shock.clamp = config.getParameter("damageClampRange", {2, 8})
  self.ct_shock.min = self.ct_shock.clamp[1]
  self.ct_shock.max = self.ct_shock.clamp[2]
  self.ct_shock.health = config.getParameter("healthPercentage", 0.025)
  self.ct_shock.kind = config.getParameter("damageKind", "electric")

  self.tickTime = config.getParameter("interval", 1.0)
  self.tickTimer = self.tickTime
  if immune() then effect.expire() end
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({damageType="IgnoresDef", damage=getDamage(), damageSourceKind=self.ct_shock.kind, sourceEntityId=entity.id()})
  end
end

function getDamage()
  return calculateImmunityToDamage(util.clamp(status.resourceMax("health") * self.ct_shock.health, self.ct_shock.min, self.ct_shock.max), self.ct_shock.min)
end

function uninit()
end

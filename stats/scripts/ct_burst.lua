require "/scripts/util.lua"


-- ### Projectile Burst Effect
-- A periodic burst of particles. You can set accuracy, cooldown, etc.  
-- Default: burst with 8 small poison clouds every second.
function init()
  self.projectile = config.getParameter("type", "smallpoisoncloud")
  self.damageMultiplier = config.getParameter("damageMultiplier", 1.0)
  self.inaccuracy = config.getParameter("inaccuracy", 3.14)
  self.params = {
    powerMultiplier = self.damageMultiplier,
    speed = 15,
    timeToLive = 0.4
  }
  self.tickTime = config.getParameter("cooldown", 1.0)
  self.tickTimer = self.tickTime
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
    self.tickTimer = self.tickTime
    local aim = 0
    for i=1,8 do
      aim = util.randomInRange({-self.inaccuracy, self.inaccuracy})
      world.spawnProjectile(self.projectile, mcontroller.position(), entity.id(), {mcontroller.facingDirection() * math.cos(aim), math.sin(aim)}, false, self.params)
    end
  end
end

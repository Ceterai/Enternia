require "/scripts/util.lua"

function init()
  self.damageProjectileType = config.getParameter("damageProjectileType") or "smallpoisoncloud"
  self.damageMultiplier = config.getParameter("damageMultiplier") or 0.01
  script.setUpdateDelta(100)
end

function update(dt)
  local params = {
    powerMultiplier = self.damageMultiplier,
    speed = 15,
    timeToLive = 0.4
  }
  local inaccuracy = 3.14
  local aim = 0
  for i=1,8 do
    aim = util.randomInRange({-inaccuracy, inaccuracy})
    world.spawnProjectile(self.damageProjectileType, mcontroller.position(), entity.id(), {mcontroller.facingDirection() * math.cos(aim), math.sin(aim)}, false, params)
  end
end

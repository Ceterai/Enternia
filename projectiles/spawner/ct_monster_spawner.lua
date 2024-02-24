---@diagnostic disable: undefined-global
require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  self.releaseOnHit = config.getParameter("releaseOnHit", true)
  self.controlForce = config.getParameter("controlForce", 80)
  self.pickupDistance = config.getParameter("pickupDistance", 1.0)
  self.snapDistance = config.getParameter("snapDistance", 4.0)
  self.speed = config.getParameter("speed")
  self.returnCollisionDuration = config.getParameter("returnCollisionDuration", 2)
  self.pureArcDuration = config.getParameter("pureArcDuration", 1)
  self.ownerId = projectile.sourceEntity()
  self.monster = config.getParameter("monster", {type="ct_alta_scout_drone", level=3, aggressive=true})

  self.returnElapsed = 0
  self.returns = config.getParameter("returns", false)
  self.contained = true
end

function update(dt)
  if not mcontroller.isColliding() then
    self.preCollisionVelocity = mcontroller.velocity()
  end

  if self.ownerId and world.entityExists(self.ownerId) then
    if self.returns and released() then returnBack() else fly() end
  else
    projectile.die()
  end
end

function fly()
  mcontroller.setRotation(0)
  if mcontroller.isColliding() or vec2.mag(mcontroller.velocity()) < 0.1 then release() end
end

function returnBack()
  self.returnElapsed = self.returnElapsed + dt
  local toTarget = world.distance(world.entityPosition(self.ownerId), mcontroller.position())
  local targetDistance = vec2.mag(toTarget)
  if targetDistance < self.pickupDistance then
    projectile.die()
  elseif self.returnElapsed > self.returnCollisionDuration or targetDistance < self.snapDistance then
    mcontroller.applyParameters({collisionEnabled = false})
    mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), self.speed), 500)
  elseif self.returnElapsed > self.pureArcDuration then
    mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), self.speed), self.controlForce)
  end
end

function hit(entityId)
  if self.releaseOnHit and self.contained then release() end
end

function release()
  self.contained = false
  projectile.die()
  local damageTeam = entity.damageTeam()
  local entityId = world.spawnMonster(self.monster.type, mcontroller.position(), sb.jsonMerge(self.monster.params, {
    level = self.monster.level,
    damageTeam = damageTeam.team,
    damageTeamType = damageTeam.type,
    aggressive = self.monster.aggressive
  }))
  if entityId then
    local position = world.callScriptedEntity(entityId, "findGroundPosition", world.entityPosition(entityId), -10, 10, false)
    if position then world.callScriptedEntity(entityId, "mcontroller.setPosition", position) end
  end
end

function released()
  return not self.contained
end

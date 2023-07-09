require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/stances.lua"

function init()
  self.abil = config.getParameter("primaryAbility")
  self.energyUsage = self.abil.energyUsage
  self.fireTime = self.abil.fireTime or 1
  self.projectileType = self.abil.type
  self.projectileParameters = self.abil.params or {}
  self.baseDps = self.abil.baseDps or self.projectileParameters.power or 0.0
  self.projectileParameters.power = self.baseDps * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1)) * (self.fireTime or 1)
  self.cooldownTime = self.abil.fireTime or 0
  self.cooldownTimer = self.cooldownTime

  initStances()

  checkProjectiles()
  if storage.projectileIds then
    setStance("throw")
  else
    setStance("idle")
  end
end

function update(dt, fireMode, shiftHeld)
  updateStance(dt)
  checkProjectiles()

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.stanceName == "idle" and fireMode == "primary" and self.cooldownTimer == 0 then
    self.cooldownTimer = self.cooldownTime
    setStance("windup")
  end

  if self.stanceName == "throw" then
    if not storage.projectileIds then
      setStance("catch")
    end
  end

  updateAim()
end

function uninit()

end

function fire()
  if world.lineTileCollision(mcontroller.position(), firePosition()) then
    setStance("idle")
    return
  end
  if status.overConsumeResource("energy", energyPerShot()) then
    local params = copy(self.projectileParameters)
    params.powerMultiplier = activeItem.ownerPowerMultiplier()
    params.ownerAimPosition = activeItem.ownerAimPosition()
    if self.aimDirection < 0 then params.processing = "?flipx" end
    local projectileId = world.spawnProjectile(
        self.projectileType,
        firePosition(),
        activeItem.ownerEntityId(),
        aimVector(),
        false,
        params
      )
    if projectileId then
      storage.projectileIds = {projectileId}
    end
    animator.playSound("throw")
  end
end

function checkProjectiles()
  if storage.projectileIds then
    local newProjectileIds = {}
    for i, projectileId in ipairs(storage.projectileIds) do
      if world.entityExists(projectileId) then
        local updatedProjectileIds = world.callScriptedEntity(projectileId, "projectileIds")

        if updatedProjectileIds then
          for j, updatedProjectileId in ipairs(updatedProjectileIds) do
            table.insert(newProjectileIds, updatedProjectileId)
          end
        end
      end
    end
    storage.projectileIds = #newProjectileIds > 0 and newProjectileIds or nil
  end
end

function energyPerShot()
  return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0)
end

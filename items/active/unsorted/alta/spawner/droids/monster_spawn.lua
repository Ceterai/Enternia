---@diagnostic disable: lowercase-global, undefined-global
require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/stances.lua"

function init()
  initStances()

  -- local pets = config.getParameter("pets")
  -- self.pet = pets[math.random(#pets)]
  self.pet = config.getParameter("pet")
  self.level = config.getParameter("level", 6)
  self.returns = config.getParameter("returns", false)
  self.projectileId = nil
  self.returnProjectileId = nil
  setStance("idle")
end

function update(dt, fireMode, shiftHeld)
  checkProjectiles()

  updateStance(dt)

  if fireMode ~= "primary" then
    self.fired = false
  end

  if self.stanceName == "idle" then
    if fireMode == "primary" and not self.fired then
      self.fired = true
      setStance("windup")
    end
  end

  updateAim()

  if self.stanceName == "throw" then
    if not self.projectileId and not self.returnProjectileId then
      consumePod()
      setStance("idle")
    end
  end
end

function consumePod()
  local entityId = activeItem.ownerEntityId()
  if player then
    local itm = item.descriptor()
    if config.getParameter('ammoUsage') then itm.count = config.getParameter('ammoUsage') end
    player.consumeItem(itm, true, true)
  else
    world.callScriptedEntity(entityId, "setItemSlotDelayed", activeItem.hand())
  end
end

function showEnergyBall()
  animator.burstParticleEmitter("energyball")
end

function checkProjectiles()
  if self.projectileId then
    if not world.entityExists(self.projectileId) then
      self.projectileId = nil
      showEnergyBall()
    elseif self.returns and world.callScriptedEntity(self.projectileId, "released") then
      self.returnProjectileId = self.projectileId
      self.projectileId = nil
    end
  elseif self.returnProjectileId then
    if not world.entityExists(self.returnProjectileId) then
      self.returnProjectileId = nil
    end
  end
end

function fire()
  if self.pet and not self.projectileId and not self.returnProjectileId then
    throwProjectile()
    setStance("throw")
  end
end

function monsterLevel()
  local entityId = activeItem.ownerEntityId()
  if world.entityType(entityId) == "npc" then
    return world.callScriptedEntity(entityId, "npc.level") or self.level
  end
  return self.level
end

function throwProjectile()
  local position = firePosition()
  local params = config.getParameter("projectileParameters", {})

  params.monster = {
    type = self.pet,
    species = config.getParameter("petSpecies", nil),
    damageTeam = config.getParameter("damageTeam"),
    level = monsterLevel(),
    aggressive = true,
    params = config.getParameter("baseParameters", {})
  }
  params.returns = self.returns
  params.ownerAimPosition = activeItem.ownerAimPosition()
  if self.aimDirection < 0 then params.processing = "?flipx" end

  self.projectileId = world.spawnProjectile(
      config.getParameter("projectileType", "ct_monster_spawner"),
      position,
      activeItem.ownerEntityId(),
      aimVector(),
      false,
      params
    )
  animator.playSound("throw")
end

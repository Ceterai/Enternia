---@diagnostic disable: lowercase-global, undefined-global
require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/stances.lua"

function init()
  initStances()
  animator.setLightColor('glow', config.getParameter('lightColor'))
  setStance('idle')
end

function update(dt, fireMode, shiftHeld)
  updateStance(dt)

  if fireMode ~= "primary" then self.fired = false end

  if self.stanceName == "idle" then
    if fireMode == "primary" and not self.fired then
      self.fired = true
      setStance("windup")
    end
  end

  updateAim()

  if self.stanceName == "throw" then
    consumePod()
    setStance("idle")
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

function fire()
  throwProjectile()
  setStance("throw")
end

function throwProjectile()
  local position = firePosition()
  local params = config.getParameter("projectileConfig", {})
  params.ownerAimPosition = activeItem.ownerAimPosition()
  if self.aimDirection < 0 then params.processing = "?flipx" end

  self.projectileId = world.spawnProjectile(
    config.getParameter("projectileType"),
    position,
    activeItem.ownerEntityId(),
    aimVector(),
    false,
    params
  )
  animator.playSound("throw")
end

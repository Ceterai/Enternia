---@diagnostic disable: lowercase-global, undefined-global
require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/scripts/activeitem/stances.lua"

function init()
  initStances()
  animator.setLightColor('glow', config.getParameter('lightColor'))
  setStance('idle')
end

function update(dt, fireMode, shiftHeld)
  updateStance(dt)

  if fireMode ~= "primary" then
    if self.active then
      self.active = false
      if self.stanceName == "wave" or self.stanceName == "wave2" then setStance("idle") else setStance("windup") end
    end
  end

  if self.stanceName == "idle" then
    if fireMode == "primary" then
      if self.active then
        self.holdTime = self.holdTime + dt
        if self.holdTime > 0.2 then wave() end
      else
        self.holdTime = 0
        self.active = true
      end
    end
  end

  updateAim()

  if self.stanceName == "throw" then
    consumePod()
    setStance("idle")
  end
end

function consumePod()
  if player then
    local itm = item.descriptor()
    itm.count = config.getParameter('ammoUsage', 1)
    player.consumeItem(itm, true, true)
  else
    world.callScriptedEntity(activeItem.ownerEntityId(), "setItemSlotDelayed", activeItem.hand())
  end
end

function fire()
  setStance("throw")
  local proj = config.getParameter("projectileType", config.getParameter("itemName")..'-thrown')
  local params = config.getParameter("projectileConfig", {})
  params.damageKindImage = "/items/active/alta/glowsticks/"..config.getParameter("inventoryIcon")
  params.ownerAimPosition = activeItem.ownerAimPosition()
  if self.aimDirection < 0 then params.processing = "?flipx" end
  self.projectileId = world.spawnProjectile(proj, firePosition(), activeItem.ownerEntityId(), aimVector(), false, params)
  animator.playSound("throw")
end

function wave() if self.stanceName == 'wave' then setStance('wave2') else setStance('wave') end end

require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/stances.lua"

function init()
  initStances()

  self.cooldownTime = config.getParameter("cooldownTime", 0)
  self.cooldownTimer = self.cooldownTime

  setStance("idle")
  activeItem.setScriptedAnimationParameter("fireOffset", nil)
end

function update(dt, fireMode, shiftHeld)
  updateStance(dt)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.stanceName == "idle" then
    if fireMode == "primary" and self.cooldownTimer == 0 then
      setStance("windup")
      activeItem.setScriptedAnimationParameter("fireOffset", self.fireOffset)
    end
  end

  if self.stanceName == "windup" and fireMode ~= "primary" then
    self.cooldownTimer = self.cooldownTime
    fire()
    setStance("throw")
    activeItem.setScriptedAnimationParameter("fireOffset", nil)
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

  local params = {
    ownerId = activeItem.ownerEntityId(),
    direction = vec2.norm(world.distance(activeItem.ownerAimPosition(), firePosition()))
  }
  world.spawnMonster("miningdrone", firePosition(), params)

  animator.playSound("throw")
  self.thrown = true

  item.consume(1)
end

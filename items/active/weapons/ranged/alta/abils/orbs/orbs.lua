---@diagnostic disable: lowercase-global, undefined-global
require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/status.lua"
require "/scripts/activeitem/stances.lua"

function init()
  activeItem.setCursor("/cursors/reticle0.cursor")
  animator.playSound("init")

  self.abil = config.getParameter("primaryAbility")
  self.projectileType = self.abil.type
  self.projectileParameters = self.abil.params or {}
  self.baseDps = self.abil.baseDps or self.projectileParameters.power or 0.0
  self.projectileParameters.power = self.baseDps * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1)) * (self.abil.fireTime or 1)
  self.cooldownTime = config.getParameter("cooldownTime", 0)
  self.cooldownTimer = self.cooldownTime

  initStances()

  storage.projectileIds = storage.projectileIds or {false, false, false}
  checkProjectiles()

  self.orbitRate = config.getParameter("orbitRate", 1) * -2 * math.pi
  self.offset = config.getParameter("muzzleOffset", {-0.1, 1.0})

  animator.resetTransformationGroup("orbs")
  for i = 1, 3 do
    animator.setAnimationState("orb"..i, storage.projectileIds[i] == false and "orb" or "hidden")
  end
  setOrbPosition(1)

  self.holdTime = 0.0
  self.shieldActive = false
  self.shieldTransformTimer = 0
  self.shieldTransformTime = self.abil.shieldTransformTime or 0.1
  self.shieldPoly = animator.partPoly("glove", "shieldPoly")
  self.shieldEnergyCost = self.abil.shieldEnergyCost or self.abil.energyUsage or 50
  self.shieldHealth = 1000
  self.shieldKnockback = self.abil.shieldKnockback or 0
  if self.shieldKnockback > 0 then
    self.knockbackDamageSource = {
      poly = self.shieldPoly,
      damage = 0,
      damageType = "Knockback",
      sourceEntity = activeItem.ownerEntityId(),
      team = activeItem.ownerTeam(),
      knockback = self.shieldKnockback,
      rayCheck = true,
      damageRepeatTimeout = 0.5
    }
  end

  setStance("idle")

  updateHand()
end

function update(dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer)

  updateStance(dt)
  checkProjectiles()

  if fireMode == "primary" and self.holdTime >= 0.45 and availableOrbCount() == 3 and not status.resourceLocked("energy") and status.resourcePositive("shieldStamina") then
    if not self.shieldActive then
      activateShield()
    end
    setOrbAnimationState("shield")
    self.shieldTransformTimer = math.min(self.shieldTransformTime, self.shieldTransformTimer + dt)
  else
    if self.shieldTransformTimer > 0 and self.shieldTransformTimer < dt then
      setOrbPosition(1)
    end

    self.shieldTransformTimer = math.max(0, self.shieldTransformTimer - dt)
    if self.shieldTransformTimer > 0 then
      setOrbAnimationState("unshield")
    end
  end

  if self.shieldTransformTimer == 0
  and fireMode ~= "primary"
  and self.lastFireMode == "primary"
  and self.cooldownTimer == 0
  and self.holdTime < 0.45
  and not status.resourceLocked("energy") then
    local nextOrbIndex = nextOrb()
    if nextOrbIndex and status.overConsumeResource("energy", self.abil.energyUsage * self.abil.fireTime) then
      fire(nextOrbIndex)
    end
  end
  self.lastFireMode = fireMode

  if fireMode == "primary" then
    self.holdTime = self.holdTime + dt
  else
    self.holdTime = 0.0
  end

  if self.shieldActive then
    if not status.resourcePositive("shieldStamina") or not status.overConsumeResource("energy", self.shieldEnergyCost * dt) then
      deactivateShield()
    else
      self.damageListener:update()
    end
  end

  if self.shieldTransformTimer > 0 then
    local transformRatio = self.shieldTransformTimer / self.shieldTransformTime
    setOrbPosition(1 - transformRatio * 0.7, transformRatio * 0.75)
    animator.resetTransformationGroup("orbs")
    animator.translateTransformationGroup("orbs", {transformRatio * -1 * config.getParameter("orbitRate", 1), 0})
  else
    if self.shieldActive then
      deactivateShield()
    end

    animator.resetTransformationGroup("orbs")
    animator.rotateTransformationGroup("orbs", -self.armAngle or 0, self.offset)
    for i = 1, 3 do
      animator.rotateTransformationGroup("orb"..i, self.orbitRate * dt, self.offset)
      animator.setAnimationState("orb"..i, storage.projectileIds[i] == false and "orb" or "hidden")
    end
  end

  updateAim()
  updateHand()
end

function uninit()
  activeItem.setItemShieldPolys()
  activeItem.setItemDamageSources()
  status.clearPersistentEffects("plasmorbShield" .. activeItem.hand())
  animator.stopAllSounds("shieldLoop")
end

function nextOrb()
  for i = 1, 3 do
    if not storage.projectileIds[i] then
      return i
    end
  end
end

function availableOrbCount()
  local available = 0
  for i = 1, 3 do
    if not storage.projectileIds[i] then
      available = available + 1
    end
  end
  return available
end

function updateHand()
  local isFrontHand = (activeItem.hand() == "primary") == (mcontroller.facingDirection() < 0)
  -- animator.setGlobalTag("hand", isFrontHand and "front" or "back")
  activeItem.setOutsideOfHand(isFrontHand)
end

function fire(orbIndex)
  local params = copy(self.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.ownerAimPosition = activeItem.ownerAimPosition()
  local firePos = firePosition(orbIndex)
  if world.lineCollision(mcontroller.position(), firePos) then return end
  local projectileId = world.spawnProjectile(
      self.projectileType,
      firePosition(orbIndex),
      activeItem.ownerEntityId(),
      aimVector(orbIndex),
      false,
      params
    )
  if projectileId then
    storage.projectileIds[orbIndex] = projectileId
    self.cooldownTimer = self.cooldownTime
    animator.playSound("fire")
  end
end

function firePosition(orbIndex)
  return vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("orb"..orbIndex, "orbPosition")))
end

function aimVector(orbIndex)
  return vec2.norm(world.distance(activeItem.ownerAimPosition(), firePosition(orbIndex)))
end

function checkProjectiles()
  for i, projectileId in ipairs(storage.projectileIds) do
    if projectileId and not world.entityExists(projectileId) then
      storage.projectileIds[i] = false
    end
  end
end

function activateShield()
  self.shieldActive = true
  animator.resetTransformationGroup("orbs")
  animator.playSound("shieldOn")
  animator.playSound("shieldLoop", -1)
  setStance("shield")
  activeItem.setItemShieldPolys({self.shieldPoly})
  activeItem.setItemDamageSources({self.knockbackDamageSource})
  status.setPersistentEffects("plasmorbShield" .. activeItem.hand(), {{stat = "shieldHealth", amount = self.shieldHealth}})
  self.damageListener = damageListener("damageTaken", function(notifications)
    for _,notification in pairs(notifications) do
      if notification.hitType == "ShieldHit" then
        if status.resourcePositive("shieldStamina") then
          animator.playSound("shieldBlock")
        else
          animator.playSound("shieldBreak")
        end
        return
      end
    end
  end)
end

function deactivateShield()
  self.shieldActive = false
  animator.playSound("shieldOff")
  animator.stopAllSounds("shieldLoop")
  setStance("idle")
  activeItem.setItemShieldPolys()
  activeItem.setItemDamageSources()
  status.clearPersistentEffects("plasmorbShield" .. activeItem.hand())
end

function setOrbPosition(spaceFactor, distance)
  for i = 1, 3 do
    animator.resetTransformationGroup("orb"..i)
    animator.translateTransformationGroup("orb"..i, {distance or 0, 0})
    animator.rotateTransformationGroup("orb"..i, 2 * math.pi * spaceFactor * ((i - 2) / 3), self.offset)
  end
end

function setOrbAnimationState(newState)
  for i = 1, 3 do
    animator.setAnimationState("orb"..i, newState)
  end
end

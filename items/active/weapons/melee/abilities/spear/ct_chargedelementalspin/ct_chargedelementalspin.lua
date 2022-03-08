require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

ElementalSpin = WeaponAbility:new()

function ElementalSpin:init()
  self:reset()
  self.cooldownTimer = self.cooldownTime
end

function ElementalSpin:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if self.weapon.currentAbility == nil and self.cooldownTimer == 0 and fireMode == "alt" and not status.resourceLocked("energy") then
    self:setState(self.windup)
  end
end

function ElementalSpin:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  animator.setAnimationState("spinSwoosh", "spin")
  animator.setParticleEmitterActive(self.weapon.elementalType.."Spin", true)
  self.weapon.aimAngle = 0
  activeItem.setOutsideOfHand(true)

  animator.playSound(self.weapon.elementalType.."Spin", -1)

  local chargeTimer = 0
  local chargeLevel = 0
  local duration = self.stances.windup.duration
  while self.fireMode == "alt" or duration > 0 do
    duration = math.max(0, duration - self.dt)
    self.weapon.relativeWeaponRotation = self.weapon.relativeWeaponRotation + util.toRadians(self.spinRate * self.dt)
    chargeTimer = math.min(self.chargeTime, chargeTimer + self.dt)
    chargeLevel = self:setChargeLevel(chargeTimer, chargeLevel)

    if status.overConsumeResource("energy", self.energyUsage * self.dt) then
      self.damageConfig.baseDamage = self.baseDps * 1.5 * chargeLevel / 4
      local damageArea = partDamageArea("spinSwoosh")
      self.weapon:setDamage(self.damageConfig, damageArea)
    elseif duration == 0 then
      break
    end

    coroutine.yield()
  end

  animator.stopAllSounds(self.weapon.elementalType.."Spin")

  if status.overConsumeResource("energy", self.projectileEnergyCost) then
      self:setState(self.fire)
  end

  self:reset()
  self.cooldownTimer = self.cooldownTime
end

function ElementalSpin:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  animator.setParticleEmitterActive(self.weapon.elementalType.."Spin", false)
  animator.setAnimationState("spinSwoosh", "idle")
  animator.playSound(self.weapon.elementalType.."SpinFire")

  local position = vec2.add(mcontroller.position(), activeItem.handPosition())
  local params = copy(self.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.power = self.baseDps * config.getParameter("damageLevelMultiplier")
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), {self.weapon.aimDirection, 0}, false, params)

  util.wait(self.stances.fire.duration)
end

function ElementalSpin:reset()
  activeItem.setScriptedAnimationParameter("lightning", {})
  animator.setAnimationState("spinSwoosh", "idle")
  animator.setParticleEmitterActive(self.weapon.elementalType.."Spin", false)
  activeItem.setOutsideOfHand(false)
  animator.stopAllSounds(self.weapon.elementalType.."Spin")
  animator.stopAllSounds(self.weapon.elementalType.."SpinLightning")
end

function ElementalSpin:setChargeLevel(chargeTimer, currentLevel)
  local level = math.min(self.chargeLevels, math.ceil(chargeTimer / self.chargeTime * self.chargeLevels))
  if currentLevel < level then
    animator.playSound(self.weapon.elementalType.."SpinLevel")
    if level == 1 then
      animator.playSound(self.weapon.elementalType.."SpinLightning", -1)
    end
    local lightningCharge = self.lightningChargeLevels[level]
    self:setLightning(level, lightningCharge[1], lightningCharge[2], lightningCharge[3], lightningCharge[4], level)
  end
  return level
end

function ElementalSpin:setLightning(amount, width, forks, branching, color, level)
  local lightning = {}
  for i = 1, amount do
    local bolt = {
      minDisplacement = 0.125,
      forks = forks,
      forkAngleRange = 0.75,
      width = width,
      color = color,
      endPointDisplacement = -branching + (i * 2 * branching)
    }
    bolt.itemStartPosition = vec2.rotate(vec2.add(self.weapon.weaponOffset, {0, 2.85}), self.weapon.relativeWeaponRotation)
    bolt.itemEndPosition = vec2.rotate(vec2.add(self.weapon.weaponOffset, {0, -2.85}), self.weapon.relativeWeaponRotation)
    bolt.displacement = vec2.mag(vec2.sub(bolt.itemEndPosition, bolt.itemStartPosition)) / (self.chargeLevels / level + 1)
    table.insert(lightning, bolt)
  end
  activeItem.setScriptedAnimationParameter("lightning", lightning)
end

function ElementalSpin:uninit()
  self:reset()
end

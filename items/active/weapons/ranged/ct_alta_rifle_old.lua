---@diagnostic disable: undefined-global, lowercase-global
require "/items/active/weapons/ranged/ct_alta_ranged.lua"

function init()
  activeItem.setCursor("/cursors/reticle0.cursor")
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.playSound("init")

  self.weapon = Weapon:new()
  self.weapon.builder = "/items/buildscripts/buildunrandweapon.lua"
  self.weapon:addAbility(getAbil(AltaRifle, "primary"))
  self.weapon:addAbility(getAbil(AltaSwitchFiremode, "alt"))
  self.weapon:addTransformationGroup("weapon", {0,0}, 0)
  self.weapon:addTransformationGroup("muzzle", self.weapon.muzzleOffset, 0)
  self.weapon:init()
end

function getAbil(class, slot, cfg)
  if not cfg then cfg = config.getParameter(slot .. "Ability") end
  for _, script in ipairs(cfg.scripts or {}) do require(script) end
  if cfg.class then class = _ENV[cfg.class] end
  cfg.abilitySlot = slot
  return class:new(cfg)
end







-- Base rifle abilities for ranged alta weapons







AltaRifle = AltaAbil:new()

function AltaRifle:init()
  AltaAbil.init(self)
  self.weapon.onLeaveAbility()
  self.cooldownTimer = self.fireTime
end

function AltaRifle:update(dt, fireMode, shiftHeld)
  AltaAbil.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  self:muzzleFlashOff()
  if self:canFire() then self:setState(self.fireTypes[config.getParameter('fireType')]) end
end

function AltaRifle:single()
  if status.overConsumeResource("energy", self:energyPerShot()) then
    self.weapon:setStance(self.stances.fire)
    self:blast(self.fireSound, self.stances.fire.duration)
    self.cooldownTimer = self.fireTime
    self:setState(self.cooldown)
  end
end

function AltaRifle:auto()
  local energy = self:energyPerShot() / (self.fireTime / self.autoParams.interval)
  if status.overConsumeResource("energy", energy) then
    self.weapon:setStance(self.stances.fire)
    self:blast(self.autoParams.sound, self.stances.fire.duration)
    self.cooldownTimer = self.autoParams.interval
    self:setState(self.cooldown)
  end
end

function AltaRifle:burst()
  self.weapon:setStance(self.stances.fire)
  local shots = self.burstParams.count
  while shots > 0 and status.overConsumeResource("energy", self:energyPerShot()) do
    shots = shots - 1
    self:blast(self.burstParams.sound, self.burstParams.interval, 1 - shots / self.burstParams.count)
  end
  self.cooldownTimer = (self.fireTime - self.burstParams.interval) * self.burstParams.count
end

function AltaRifle:semi()
  self.weapon:setStance(self.stances.fire)
  local shots = self.semiParams.count
  while shots > 0 and status.overConsumeResource("energy", self:energyPerShot()) do
    shots = shots - 1
    self:blast(self.semiParams.sound, self.semiParams.interval)
  end
  self.cooldownTimer = (self.fireTime - self.semiParams.interval) * self.semiParams.count
end

function AltaRifle:charge()
  self.weapon:setStance(self.stances.windup or self.stances.fire)
  local holdTime = 0
  while self:isActive() do
    holdTime = holdTime + self.dt
    if holdTime == 0.15 then
      if not status.overConsumeResource("energy", self:energyPerShot()) then break end
    elseif holdTime > 0.15 then
      if holdTime > 3.00 or not status.overConsumeResource("energy", self:energyPerShot() * self.dt) then break end
    end
    coroutine.yield()
  end
  if holdTime > 0.15 then
    self.baseDamageMultiplier = 1.0 + holdTime * 1.25
    local params = self.projectileParameters or {}
    if params.knockback then
      params.knockback = params.knockback * (1.0 + holdTime)
    end
    self.weapon:setStance(self.stances.fire)
    self:blast(self.chargeParams.sound, self.stances.fire.duration, nil, self.projectileType, params)
    self.baseDamageMultiplier = 1.0
    self.cooldownTimer = self.fireTime
    self:setState(self.cooldown)
  elseif holdTime < 0.15 then
    self:setState(self.single)
  end
end

function AltaRifle:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()
  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}
    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))
    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
end

function AltaRifle:blast(sound, interval, recoil, ...)
  local ids = self:fireProjectile(...)
  self:muzzleFlash(sound)
  if recoil then
    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(recoil, 0, self.stances.fire.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(recoil, 0, self.stances.fire.armRotation))
  end
  if interval then util.wait(interval) end
  return ids
end

function AltaRifle:muzzleFlash(sound)
  animator.setPartTag("muzzleFlash", "variant", math.random(1, self.muzzleFlashVariants or 3))
  animator.setAnimationState("firing", "fire")
  animator.burstParticleEmitter("muzzleFlash")
  animator.playSound(sound or self.fireSound)
  animator.setLightActive("muzzleFlash", true)
end

function AltaRifle:muzzleFlashOff()
  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end
end

function AltaRifle:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
  params.power = self:damagePerShot()
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)
  projectileType = projectileType or self.projectileType
  if type(projectileType) == "table" then projectileType = util.randomChoice(projectileType) end
  local projectileIds = {}
  for i = 1, (projectileCount or self.projectileCount or 1) do
    params.timeToLive = util.randomInRange(params.timeToLive)
    table.insert(projectileIds, world.spawnProjectile(
        projectileType,
        firePosition or self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(inaccuracy or self.inaccuracy or 0.0),
        false,
        params
      ))
  end
  return projectileIds
end

function AltaRifle:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function AltaRifle:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function AltaRifle:energyPerShot()
  return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0)
end

function AltaRifle:damagePerShot()
  return (self.baseDamage or (self.baseDps * self.fireTime)) * (self.baseDamageMultiplier or 1.0) *
  config.getParameter("damageLevelMultiplier") * (self.weapon.stabilizerBonus or 1.0) / self.projectileCount
end

function AltaRifle:canFire()
  if not config.getParameter('fireType') then activeItem.setInstanceValue('fireType', config.getParameter('fireType') or 'single') end
  return self:isActive()
    and self.fireTypes[config.getParameter('fireType')] ~= nil
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
end

function AltaRifle:setDefaults()
  self.name = self.name or 'Alta Rifle Blast'
  self.baseDps = self.baseDps or 8
  self.energyUsage = self.energyUsage or 0
  self.projectileCount = self.projectileCount or 1
  self.inaccuracy = self.inaccuracy or 0.005
  self.fireTime = self.fireTime or 1.0
  self.fireSound = self.fireSound or 'single'
  self.fireTypes = self.fireTypes or { single=self.single, auto=self.auto, burst=self.burst, semi=self.semi, charge=self.charge, }
  self.stances = self.stances or { }
  self.stances.idle = self.stances.idle or {armRotation=0, weaponRotation=0, twoHanded=true, allowRotate=true, allowFlip=true,}
  self.stances.fire = self.stances.fire or {armRotation=3, weaponRotation=3, twoHanded=true, duration=0, allowRotate=false, allowFlip=true,}
  self.stances.cooldown = self.stances.cooldown or {armRotation=3, weaponRotation=3, twoHanded=true, duration=0.1, allowRotate=false, allowFlip=true,}
  self.burstParams = self.burstParams or {}
  self.burstParams.count = self.burstParams.count or 5
  self.burstParams.interval = self.burstParams.interval or 0.0
  self.burstParams.sound = self.burstParams.sound or self.fireSound
  self.chargeParams = self.chargeParams or {}
  self.chargeParams.sound = self.chargeParams.sound or self.fireSound
  self.semiParams = self.semiParams or {}
  self.semiParams.count = self.semiParams.count or 3
  self.semiParams.interval = self.semiParams.interval or 0.0
  self.semiParams.sound = self.semiParams.sound or self.fireSound
  self.autoParams = self.autoParams or {}
  self.autoParams.interval = self.autoParams.interval or 0.1
  self.autoParams.sound = self.autoParams.sound or self.fireSound
  self.weapon.onLeaveAbility = function() self.weapon:setStance(self.stances.idle) end
end

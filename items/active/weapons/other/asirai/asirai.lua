require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"
require "/items/active/weapons/melee/meleecombo.lua"

function init()
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.setGlobalTag("directives", "")
  animator.setGlobalTag("bladeDirectives", "")

  self.weapon = Weapon:new()

  local primary = config.getParameter("primaryAbility")
  local alt = config.getParameter("altAbility")
  primary.abilitySlot = "primary"
  alt.abilitySlot = "alt"

  self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
  self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)
  self.weapon:addAbility(AsiraiAttack:new(primary))
  self.weapon:addAbility(AsiraiCharge:new(alt))
  self.weapon:init()
end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
end

function uninit()
  self.weapon:uninit()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Ability: Asirai Attack
--   A combo melee attack, which releases projectiles on the last
--     hit in the direction of the enemy.
--   Hold to perform a dash, which will launch you into the air.

AsiraiAttack = MeleeCombo:new()

function AsiraiAttack:init()
  self:reset()
  self:initDefaults()
  self:initDamage()

  self.comboStep = 1
  self.edgeTriggerTimer = 0
  self.flashTimer = 0
  self.cooldownTimer = self.cooldowns[1]
  self.animKeyPrefix = self.animKeyPrefix or ""

  self.weapon:setStance(self.stances.idle)
  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function AsiraiAttack:reset()
  self.holdTime = 0
  animator.setAnimationState("dashSwoosh", "idle")
end

function AsiraiAttack:uninit()
  MeleeCombo.uninit(self)
  self:reset()
end

--------------------------------------------STATES--------------------------------------------

function AsiraiAttack:fire()
  local stance = self.stances["fire"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  local animStateKey = self.animKeyPrefix .. (self.comboStep > 1 and "fire"..self.comboStep or "fire")
  animator.setAnimationState("swoosh", animStateKey)
  animator.playSound(animStateKey)

  local swooshKey = self.animKeyPrefix .. (self.elementalType or self.weapon.elementalType) .. "swoosh"
  animator.setParticleEmitterOffsetRegion(swooshKey, self.swooshOffsetRegions[self.comboStep])
  animator.burstParticleEmitter(swooshKey)

  if self.comboStep == self.comboSteps then
    self:fireBolts()
  end

  util.wait(stance.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.stepDamageConfig[self.comboStep], damageArea)
  end)

  self.cooldownTimer = self.cooldowns[self.comboStep]
  self:reset()

  if self.fireMode == "primary" and not status.resourceLocked("energy") and self.allowHold ~= false then
    while self.fireMode == "primary" do
      self.holdTime = self.holdTime + self.dt
      if self.holdTime > 0.25 then
        if self.holdEnergyUsage then
          status.overConsumeResource("energy", self.holdEnergyUsage)
        end
        self:setState(self.dash)
      end
      coroutine.yield()
    end
  end

  self:setState(self.combo)
end

function AsiraiAttack:combo()
  if self.comboStep < self.comboSteps then
    self.comboStep = self.comboStep + 1
    self:setState(self.wait)
  else
    self.cooldownTimer = self.cooldowns[self.comboStep]
    self.comboStep = 1
  end
end

function AsiraiAttack:dash()
  self.weapon:setStance(self.stances.dash)
  self.weapon:updateAim()

  animator.burstParticleEmitter(self.weapon.elementalType .. "swoosh")
  animator.setAnimationState("swoosh", "fire")
  animator.setAnimationState("dashSwoosh", "full")
  animator.playSound("fire")
  
  local aimDirection = {mcontroller.facingDirection() * math.cos(self.weapon.aimAngle), math.sin(self.weapon.aimAngle)}
  util.wait(self.maxDashTime, function(dt)
    mcontroller.controlApproachVelocity(vec2.mul(aimDirection, self.dashMaxSpeed), self.dashControlForce)
    mcontroller.controlParameters({
      airFriction = 0.2,
      groundFriction = 0.2,
      liquidFriction = 0.3,
      gravityEnabled = false
    })
  
    local damageArea = partDamageArea("dashSwoosh")
    self.weapon:setDamage(self.holdDamageConfig, damageArea)
  end)
  
  -- freeze in mid air for a short amount of time
  util.wait(self.freezeTime, function(dt)
    mcontroller.controlParameters({
      gravityEnabled = false
    })
    mcontroller.controlApproachVelocity(vec2.mul(aimDirection, self.dashMaxSpeed / 50), self.dashControlForce)
  end)

  self:reset()
  self.cooldownTimer = self.holdCooldown
  self:setState(self.combo)
end

--------------------------------------------OTHER--------------------------------------------

function AsiraiAttack:fireBolts()
  local position = vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("blade", "projectileSource")))
  local inaccuracy = 0.3
  local aim = 0
  for i=1,self.projectileCount do
    aim = self.weapon.aimAngle + util.randomInRange({-inaccuracy, inaccuracy})
    world.spawnProjectile(
      self.projectileType,
      position,
      activeItem.ownerEntityId(),
      {mcontroller.facingDirection() * math.cos(aim), math.sin(aim)},
      false,
      self.projectileParameters
    )
  end
end

--------------------------------------------CONFIG--------------------------------------------

function AsiraiAttack:initDamage()
  self.power = self.power or (self.baseDps * self.fireTime) or 1
  self:initHoldDamage()
  self:initStepDamage()
  self:initBoltDamage()
end

function AsiraiAttack:initHoldDamage()
  self.holdEnergyUsage = self.holdEnergyUsage or self.energyUsage or 0

  self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
  self.holdDamageConfig.baseDamage = self.power * self.holdDamageMultiplier
end

function AsiraiAttack:initStepDamage()
  self.energyUsage = self.energyUsage or 0
  self.cooldowns = {}

  local attackTimes = {}
  for i = 1, self.comboSteps do
    local attackTime = self.stances["windup"..i].duration + self.stances["fire"..i].duration
    if self.stances["preslash"..i] then
      attackTime = attackTime + self.stances["preslash"..i].duration
    end
    table.insert(attackTimes, attackTime)
  end

  local totalAttackTime = 0
  local totalDamageFactor = 0
  for i, attackTime in ipairs(attackTimes) do
    self.stepDamageConfig[i] = util.mergeTable(copy(self.damageConfig), self.stepDamageConfig[i])
    self.stepDamageConfig[i].timeoutGroup = "primary"..i

    local damageFactor = self.stepDamageConfig[i].baseDamageFactor
    self.stepDamageConfig[i].baseDamage = self.power * damageFactor

    totalAttackTime = totalAttackTime + attackTime
    totalDamageFactor = totalDamageFactor + damageFactor

    local targetTime = totalDamageFactor * self.comboCooldown
    local speedFactor = 1.0 * (self.comboSpeedFactor ^ i)
    table.insert(self.cooldowns, (targetTime - totalAttackTime) * speedFactor)
  end
end

function AsiraiAttack:initBoltDamage()
  local power = self.projectileParameters.power or (self.power / self.projectileCount)
  self.projectileParameters.power = power * config.getParameter("damageLevelMultiplier")
  self.projectileParameters.powerMultiplier = activeItem.ownerPowerMultiplier()
end

function AsiraiAttack:initDefaults()
  self:initDamageDefaults()
  self:initDashDefaults()
  self:initStepDefaults()
end

function AsiraiAttack:initDamageDefaults()
  local baseConfig = {}
  baseConfig.damageSourceKind = "spear"
  baseConfig.knockbackMode = "aim"
  baseConfig.timeoutGroup = "primary"
  baseConfig.timeout = 0.2
  self.damageConfig = self.damageConfig or {}
  self.damageConfig = sb.jsonMerge(baseConfig, self.damageConfig)

  self.holdCooldown = self.holdCooldown or 0.4
  self.holdDamageMultiplier = self.holdDamageMultiplier or 2.0
  local holdConfig = {}
  holdConfig.timeoutGroup = "hold"
  holdConfig.timeout = 0.06
  self.holdDamageConfig = self.holdDamageConfig or {}
  self.holdDamageConfig = sb.jsonMerge(holdConfig, self.holdDamageConfig)

  self.projectileType = self.projectileType or "smallelectriccloud"
  self.projectileCount = self.projectileCount or 8
  local boltConfig = {}
  boltConfig.knockbackMode = "none"
  boltConfig.knockback = 0
  boltConfig.speed = 15
  boltConfig.timeToLive = 0.4
  self.projectileParameters = self.projectileParameters or {}
  self.projectileParameters = sb.jsonMerge(boltConfig, self.projectileParameters)
end

function AsiraiAttack:initDashDefaults()
  self.dashMaxSpeed = self.dashMaxSpeed or 100
  self.dashControlForce = self.dashControlForce or 600
  self.maxDashTime = self.maxDashTime or 0.20
  self.freezeTime = self.freezeTime or 0.1
end

function AsiraiAttack:initStepDefaults()
  self.comboCooldown = self.comboCooldown or 0.3
  self.comboSteps = self.comboSteps or 4
  self.comboSpeedFactor = self.comboSpeedFactor or 0.5

  self.flashTime = self.flashTime or 0.15
  self.flashDirectives = self.flashDirectives or "fade=FFFFFFFF=0.15"
  self.edgeTriggerGrace = self.edgeTriggerGrace or 0.25
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Ability: Asirai Charge
--   A spear charge, that damages nearby enemies, constantly consuming energy.
--   Once released, launches the spinning weapon forwards, dealing more damage.

AsiraiCharge = WeaponAbility:new()

function AsiraiCharge:init()
  self:initDefaults()
  self:initDamage()
  self.active = false
  self.activeTimer = 0
  self:reset()
end

function AsiraiCharge:reset()
  animator.setAnimationState("swoosh", "idle")
  self.weapon:setStance(self.stances.idle)
  self.weapon:updateAim()
  self.cooldownTimer = self.cooldownTime
end

function AsiraiCharge:uninit(final)
  if final then
    status.clearPersistentEffects(self.effectConfig.name)
    status.clearPersistentEffects(self.chargeEffectConfig.name)
    animator.stopAllSounds("effectActive")
  end
  self:reset()
end

--------------------------------------------STATES--------------------------------------------

function AsiraiCharge:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  if self.weapon.currentAbility == nil and self.cooldownTimer == 0 and fireMode == "alt" and not status.resourceLocked("energy") then
    self:setState(self.windup)
  end
  self:effectLoop()
end

function AsiraiCharge:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon.aimAngle = 0
  self.weapon:updateAim()
  util.wait(self.stances.windup.duration)
  if self.fireMode == "alt" then
    self:setState(self.charge)
  else
    self:effectActivate()
    self:reset()
  end
end

function AsiraiCharge:charge()
  self.weapon:setStance(self.stances.charge)
  self.weapon:updateAim()

  status.setPersistentEffects(self.chargeEffectConfig.name, { self.chargeEffectConfig.type })
  self:chargeLoop()
  status.clearPersistentEffects(self.chargeEffectConfig.name)

  if status.overConsumeResource("energy", self.holdEnergyUsage) then
    self:setState(self.aftercharge)
  else
    self:reset()
  end
end

function AsiraiCharge:aftercharge()
  if self.stances.charge.hold then
    while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
      coroutine.yield()
    end
  else
    util.wait(self.stances.charge.duration)
  end

  self:setState(self.fire)
end

function AsiraiCharge:fire()
  if self.stances["preslash"] then
    self:setState(self.preslash)
  else
    self:setState(self.slash)
  end
end

function AsiraiCharge:preslash()
  self.weapon:setStance(self.stances.preslash)
  self.weapon:updateAim()

  util.wait(self.stances.preslash.duration)
  self:setState(self.slash)
end

function AsiraiCharge:slash()
  self.weapon:setStance(self.stances.fire)

  animator.setAnimationState("swoosh", "fire4")
  animator.playSound("chargeFire")

  local swooshKey = (self.elementalType or self.weapon.elementalType) .. "swoosh"
  animator.setParticleEmitterOffsetRegion(swooshKey, {0.75, 0.0, 6.25, 5.0})
  animator.burstParticleEmitter(swooshKey)

  self.weapon:updateAim()
  self.weapon:setDamage(self.holdDamageConfig, partDamageArea("swoosh"))
  self:fireBolts()

  util.wait(self.stances.fire.duration)
  self:reset()
end

--------------------------------------------OTHER--------------------------------------------

function AsiraiCharge:effectActivate()
  status.setPersistentEffects(self.effectConfig.name, { self.effectConfig.type })
  animator.playSound(self.effectConfig.animActivate)
  self.activeTimer = self.effectConfig.duration
  if not self.active then
    animator.playSound(self.effectConfig.animActive, -1)
  end
  self.active = true
end

function AsiraiCharge:effectLoop()
  if self.active then
    self.activeTimer = math.max(0, self.activeTimer - self.dt)
    if not status.overConsumeResource("energy", self.energyUsage / 4 * self.dt) or self.activeTimer == 0 then
      self:effectDeactivate()
    end
  end
end

function AsiraiCharge:effectDeactivate()
  status.clearPersistentEffects(self.effectConfig.name)
  animator.stopAllSounds(self.effectConfig.animActive)
  animator.playSound(self.effectConfig.animDeactivate)
  self.active = false
end

function AsiraiCharge:chargeLoop()
  activeItem.setOutsideOfHand(true)
  animator.playSound(self.weapon.elementalType.."SpinLightning", -1)
  local chargeTimer = 0
  local chargeLevel = 0
  local duration = self.stances.windup.duration
  while (self.fireMode == "alt" or duration > 0) and chargeTimer < self.chargeTime do
    duration = math.max(0, duration - self.dt)
    chargeTimer = math.min(self.chargeTime, chargeTimer + self.dt)

    local swooshKey = "chargeLoop"
    animator.setParticleEmitterOffsetRegion(swooshKey, {-2.75, 0.0, 3.25, 0.0})
    animator.burstParticleEmitter(swooshKey)

    if status.overConsumeResource("energy", self.energyUsage * self.dt) then
      self.weapon:setDamage(self.damageConfig, partDamageArea("swoosh"))
    elseif duration == 0 then
      break
    end

    coroutine.yield()
  end
  animator.stopAllSounds(self.weapon.elementalType.."SpinLightning")
  activeItem.setOutsideOfHand(false)
end

function AsiraiCharge:fireBolts()
  local position = vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("blade", "projectileSource")))
  local aim = self.weapon.aimAngle
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), {mcontroller.facingDirection() * math.cos(aim), math.sin(aim)}, false, self.projectileParameters)
  local aim = self.weapon.aimAngle + 3.14
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), {mcontroller.facingDirection() * math.cos(aim), math.sin(aim)}, false, self.projectileParameters)
end

--------------------------------------------CONFIG--------------------------------------------

function AsiraiCharge:initDamage()
  self.power = self.power or (self.baseDps * self.fireTime) or 1
  self:initBaseDamage()
  self:initHoldDamage()
end

function AsiraiCharge:initBaseDamage()
  self.damageConfig.baseDamage = self.power
end

function AsiraiCharge:initHoldDamage()
  self.holdEnergyUsage = self.holdEnergyUsage or self.energyUsage or 0

  self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
  self.holdDamageConfig.baseDamage = self.power * self.holdDamageMultiplier
end

function AsiraiCharge:initDefaults()
  self.energyUsage = self.energyUsage or 20
  self.cooldownTime = self.cooldownTime or 1.0

  self.chargeTime = self.chargeTime or 4.0
  self.minChargeTime = self.minChargeTime or 0.5
  self.chargeLevels = self.chargeLevels or 5
  self.chargeIncrease = self.chargeIncrease or 0.5
  self.spinRate = self.spinRate or -1750
  self.cycleRotationOffsets = self.cycleRotationOffsets or { 0, 7.5, -7.5 }

  local baseConfig = {}
  baseConfig.damageSourceKind = "electricspear"
  baseConfig.knockbackMode = "none"
  baseConfig.knockback = 0
  baseConfig.timeoutGroup = "alt"
  baseConfig.timeout = 0.25
  self.damageConfig = self.damageConfig or {}
  self.damageConfig = sb.jsonMerge(baseConfig, self.damageConfig)

  self.holdCooldown = self.holdCooldown or 0.4
  self.holdDamageMultiplier = self.holdDamageMultiplier or 2.0
  local holdConfig = {}
  holdConfig.timeoutGroup = "hold"
  holdConfig.timeout = 0.06
  self.holdDamageConfig = self.holdDamageConfig or {}
  self.holdDamageConfig = sb.jsonMerge(holdConfig, self.holdDamageConfig)

  local effectConfig = {}
  effectConfig.duration = 12
  effectConfig.name = "Asirai Potential"
  effectConfig.type = "ct_asirai_potential"
  effectConfig.animActivate = "effectActivate"
  effectConfig.animActive = "effectActive"
  effectConfig.animDeactivate = "effectDeactivate"
  self.effectConfig = self.effectConfig or {}
  self.effectConfig = sb.jsonMerge(effectConfig, self.effectConfig)

  local chargeEffectConfig = {}
  chargeEffectConfig.name = "Asirai Energy"
  chargeEffectConfig.type = "ct_asirai_energy"
  self.chargeEffectConfig = self.chargeEffectConfig or {}
  self.chargeEffectConfig = sb.jsonMerge(chargeEffectConfig, self.chargeEffectConfig)

  self.projectileType = self.projectileType or "smallelectriccloud"
  local boltConfig = {}
  boltConfig.knockbackMode = "none"
  boltConfig.knockback = 0
  boltConfig.speed = 15
  boltConfig.timeToLive = 0.4
  self.projectileParameters = self.projectileParameters or {}
  self.projectileParameters = sb.jsonMerge(boltConfig, self.projectileParameters)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Ability: Asirai Spin
--   A charged elemental spin, that damages nearby enemies,
--     becoming stronger with time and constantly consuming energy.
--   Once released, launches the spinning weapon forwards, dealing more damage.

AsiraiSpin = WeaponAbility:new()

function AsiraiSpin:init()
  self:reset()
  self:initDefaults()
  self:initDamage()
  self.cooldownTimer = self.cooldownTime
end

function AsiraiSpin:reset()
  activeItem.setScriptedAnimationParameter("lightning", {})
  animator.setAnimationState("spinSwoosh", "idle")
  animator.setParticleEmitterActive(self.weapon.elementalType.."Spin", false)
  activeItem.setOutsideOfHand(false)
  animator.stopAllSounds(self.weapon.elementalType.."Spin")
  animator.stopAllSounds(self.weapon.elementalType.."SpinLightning")
end

function AsiraiSpin:uninit()
  self:reset()
end

--------------------------------------------STATES--------------------------------------------

function AsiraiSpin:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  if self.weapon.currentAbility == nil and self.cooldownTimer == 0 and fireMode == "alt" and not status.resourceLocked("energy") then
    self:setState(self.windup)
  end
end

function AsiraiSpin:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  animator.setAnimationState("spinSwoosh", "spin")
  animator.setParticleEmitterActive(self.weapon.elementalType.."Spin", true)
  self.weapon.aimAngle = 0
  activeItem.setOutsideOfHand(true)

  self:spin()

  if status.overConsumeResource("energy", self.projectileEnergyCost) then
      self:setState(self.fire)
  end

  self:reset()
  self.cooldownTimer = self.cooldownTime
end

function AsiraiSpin:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  animator.setParticleEmitterActive(self.weapon.elementalType.."Spin", false)
  animator.playSound(self.weapon.elementalType.."SpinFire")

  local position = vec2.add(mcontroller.position(), activeItem.handPosition())
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), {self.weapon.aimDirection, 0}, false, self.projectileParameters)

  util.wait(self.stances.fire.duration)
end

--------------------------------------------OTHER--------------------------------------------

function AsiraiSpin:spin()
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
      local damageConfig = copy(self.damageConfig)
      local damageArea = partDamageArea("spinSwoosh")
      damageConfig.baseDamage = damageConfig.baseDamage + damageConfig.chargeDamage * chargeLevel
      self.weapon:setDamage(damageConfig, damageArea)
    elseif duration == 0 then
      break
    end

    coroutine.yield()
  end
  animator.stopAllSounds(self.weapon.elementalType.."Spin")
end

function AsiraiSpin:setChargeLevel(chargeTimer, currentLevel)
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

function AsiraiSpin:setLightning(amount, width, forks, branching, color, level)
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

--------------------------------------------CONFIG--------------------------------------------

function AsiraiSpin:initDamage()
  self.power = self.power or (self.baseDps * self.fireTime) or 1
  self:initBaseDamage()
  self:initBoltDamage()
end

function AsiraiSpin:initBaseDamage()
  local power = self.power * 1.5 / 4
  self.damageConfig.chargeDamage = power * self.chargeIncrease 
  self.damageConfig.baseDamage = power - self.damageConfig.chargeDamage
end

function AsiraiSpin:initBoltDamage()
  local power = self.projectileParameters.power or self.power
  self.projectileParameters.power = power * config.getParameter("damageLevelMultiplier")
  self.projectileParameters.powerMultiplier = activeItem.ownerPowerMultiplier()
end

function AsiraiSpin:initDefaults()
  self.energyUsage = self.energyUsage or 40
  self.cooldownTime = self.cooldownTime or 1.0

  self.chargeTime = self.chargeTime or 4.0
  self.minChargeTime = self.minChargeTime or 0.5
  self.chargeLevels = self.chargeLevels or 5
  self.chargeIncrease = self.chargeIncrease or 0.5
  self.spinRate = self.spinRate or -1750
  self.cycleRotationOffsets = self.cycleRotationOffsets or { 0, 7.5, -7.5 }

  local baseConfig = {}
  baseConfig.damageSourceKind = "electricspear"
  baseConfig.knockbackMode = "none"
  baseConfig.knockback = 0
  baseConfig.timeoutGroup = "alt"
  baseConfig.timeout = 0.25
  self.damageConfig = self.damageConfig or {}
  self.damageConfig = sb.jsonMerge(baseConfig, self.damageConfig)

  self.projectileType = self.projectileType or "electricspinswoosh"
  self.projectileEnergyCost = self.projectileEnergyCost or 20
  local boltConfig = {}
  boltConfig.knockback = 15
  boltConfig.timeToLive = 2.0
  self.projectileParameters = self.projectileParameters or {}
  self.projectileParameters = sb.jsonMerge(boltConfig, self.projectileParameters)
end

---@diagnostic disable: undefined-global, lowercase-global
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/scripts/status.lua"
require "/scripts/poly.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/melee/alta/enhanced.lua"

function getDefaultPrimary() return BladeCharge end





BladeCharge = AltaMeleeDownstab:new()

function BladeCharge:init()
  AltaMeleeDownstab.init(self)
  BladeCharge:reset()
end

function BladeCharge:holdAbil() if self:canHold() then self:setState(self.windupHold) end end

function BladeCharge:windupHold()
  self.weapon:setStance(self.stances.windup)
  animator.setAnimationState("bladeCharge", "charge")
  animator.setParticleEmitterActive("bladeCharge", true)
  local chargeTimer = self.holdParams.chargeTime
  while self:isOn() do
    chargeTimer = math.max(0, chargeTimer - self.dt)
    if chargeTimer == 0 then animator.setGlobalTag("bladeDirectives", "border=3;"..self.holdParams.chargeBorder..";00000000") end
    coroutine.yield()
  end
  if chargeTimer == 0 and self:drainEnergy(self.holdParams) then self:setState(self.slash) end
end

function BladeCharge:slash()
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()
  animator.setAnimationState("bladeCharge", "idle")
  animator.setParticleEmitterActive("bladeCharge", false)
  animator.setAnimationState("swoosh", "fire")
  animator.playSound(self.abilitySlot.."_hold")
  self:countHit(self.holdParams.damageConfig)
  util.wait(self.stances.slash.duration, function() self:fireMelee(self.holdParams.damageConfig, 'swoosh') end)
  self:holdCooldownReset()
end

function BladeCharge:reset()
  animator.setGlobalTag("bladeDirectives", "")
  animator.setParticleEmitterActive("bladeCharge", false)
  animator.setAnimationState("bladeCharge", "idle")
end

function BladeCharge:uninit()
  self:reset()
  AltaMeleeDownstab.uninit(self)
end

function BladeCharge:setDefaults()
  AltaMeleeDownstab.setDefaults(self)
  self.holdParams.cooldownTime = self.holdParams.cooldownTime or 0.8
  self.holdParams.energyFactor = self.holdParams.energyFactor or 3.0
  self.holdParams.chargeTime = self.holdParams.chargeTime or 1.2
  self.holdParams.chargeBorder = self.holdParams.chargeBorder or "FFFF3388"
  self.holdParams.damageConfig = self.holdParams.damageConfig or self.damageConfig
  self.holdParams.damageConfig.damageFactor = self.holdParams.damageConfig.damageFactor or 3.0
  self.stances.windup = self.stances.windup or { duration=0.3, armRotation=70, weaponRotation=0, twoHanded=true, allowRotate=false, allowFlip=true }
  self.stances.slash = self.stances.slash or { duration=0.4, armRotation=-45, weaponRotation=-55, twoHanded=true, allowRotate=false, allowFlip=false }
end





FlipSlash = AltaMeleeDownstab:new()

function FlipSlash:holdAbil() if self:canHoldMove() then self:setState(self.windupHold) end end

function FlipSlash:windupHold()
  self:drainEnergy(self.holdParams)
  self.weapon:setStance(self.stances.windup)
  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  util.wait(self.stances.windup.duration, function(dt) mcontroller.controlCrouch() end)
  self:setState(self.flip)
end

function FlipSlash:flip()
  self.weapon:setStance(self.stances.flip)
  self.weapon:updateAim()

  animator.setAnimationState("swoosh", "flip")
  animator.playSound(self.abilitySlot.."_hold")
  animator.setParticleEmitterActive("flip", true)

  self.flipTime = self.rotations * self.rotationTime
  self.flipTimer = 0
  self.jumpTimer = self.jumpDuration

  while self.flipTimer < self.flipTime do
    self.flipTimer = self.flipTimer + self.dt
    mcontroller.controlParameters(self.flipMovementParameters)
    if self.jumpTimer > 0 then
      self.jumpTimer = self.jumpTimer - self.dt
      mcontroller.setVelocity({self.jumpVelocity[1] * self.weapon.aimDirection, self.jumpVelocity[2]})
    end
    self:countHit(self.holdParams.damageConfig)
    self:fireMelee(self.holdParams.damageConfig, 'swoosh')
    mcontroller.setRotation(-math.pi * 2 * self.weapon.aimDirection * (self.flipTimer / self.rotationTime))
    coroutine.yield()
  end
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setAnimationState("swoosh", "idle")
  mcontroller.setRotation(0)
  animator.setParticleEmitterActive("flip", false)
  self:holdCooldownReset()
end

function FlipSlash:uninit()
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setAnimationState("swoosh", "idle")
  mcontroller.setRotation(0)
  animator.setParticleEmitterActive("flip", false)
  AltaMeleeDownstab.uninit(self)
end





require "/scripts/rect.lua"
require "/items/active/weapons/melee/abilities/hammer/shockwave/shockwave.lua"

GreatWave = AltaMeleeDownstab:new()

function GreatWave:holdAbil() if self:canHoldMove() then self:setState(self.windupHold) end end

function GreatWave:windupHold()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()
  util.wait(self.stances.windup.duration)
  self:setState(self.fireHold)
end

function GreatWave:fireHold()
  self.weapon:setStance(self.stances.fire)
  self:countHit(self.holdParams.damageConfig)
  self:fireShockwave()
  animator.playSound(self.abilitySlot.."_hold")
  util.wait(self.stances.fire.duration)
  self:holdCooldownReset()
end

-- Helper functions
function GreatWave:fireShockwave() return ShockWave.fireShockwave(self, 1.0) end
function GreatWave:impactPosition() return ShockWave.impactPosition(self) end
function GreatWave:shockwaveProjectilePositions(impactPos, maxDist, dirs) return ShockWave.shockwaveProjectilePositions(self, impactPos, maxDist, dirs) end

function GreatWave:setDefaults()
  AltaMeleeDownstab.setDefaults(self)
  self.chargeTime = self.chargeTime or 1.0
  self.minChargeTime = self.minChargeTime or 0.5
  self.projectileType = self.projectileType or self.weapon.elementalType.."shockwave"
  self.projectileParameters = self.projectileParameters or { power=3.5, knockback=35, knockbackMode="facing" }
  self.shockWaveBounds = self.shockWaveBounds or {-0.4, -1.375, 0.4, 0.0}
  self.shockwaveHeight = self.shockwaveHeight or 1.375
  self.maxDistance = self.maxDistance or 10
  self.bothDirections = self.bothDirections or true
  self.impactLine = self.impactLine or { {1.25, -1.5}, {1.25, -4.5} }
  self.impactWeaponOffset = self.impactWeaponOffset or 0.75
  self.stances.windup = self.stances.windup or
    {duration=0.2,armRotation=0,endArmRotation=110,weaponRotation=180,endWeaponRotation=130,weaponOffset={0,-2.5},twoHanded=true,allowRotate=false,allowFlip=true}
  self.stances.fire = self.stances.fire or {duration=0.5,armRotation=0,weaponRotation=-180,weaponOffset={0,-0.5},twoHanded=true,allowRotate=false,allowFlip=false}
end





KunaiBlast = AltaMeleeHold:new()

function KunaiBlast:holdAbil() if self:canHold() then self:setState(self.windupHold) end end

function KunaiBlast:windupHold()
  self:drainEnergy(self.holdParams)
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()
  util.wait(self.stances.windup.duration)
  if not status.statPositive("activeMovementAbilities") then self:setState(self.fireHold) end
end

function KunaiBlast:fireHold()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()
  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  local projectileTimesAndAngles = copy(self.projectileTimesAndAngles)
  self:countHit(self.holdParams.damageConfig)
  util.wait(self.stances.fire.duration, function(dt)
    mcontroller.controlApproachVelocity({0, 0}, 1000)
    local newTimesAndAngles = {}
    for _, timeAndAngle in pairs(projectileTimesAndAngles) do
      if timeAndAngle[1] <= dt then
        self:spawnProjectile(timeAndAngle[2])
      else
        table.insert(newTimesAndAngles, {timeAndAngle[1] - dt, timeAndAngle[2]})
      end
    end
    projectileTimesAndAngles = newTimesAndAngles
  end)
  self:holdCooldownReset()
end

function KunaiBlast:spawnProjectile(angleAdjust)
  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * self.weapon.aimDirection, self.projectileOffset[2]})
  local params = self:getProjDamage({}, #self.projectileTimesAndAngles, self.holdParams.itemBonus)
  local aimVector = vec2.withAngle(util.toRadians(angleAdjust))
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  self:fireRanged(self.projectileType, params, position, nil, aimVector)
  animator.playSound(self.abilitySlot.."_hold")
end

function KunaiBlast:uninit()
  status.clearPersistentEffects("weaponMovementAbility")
  AltaMeleeHold.uninit(self)
end

function KunaiBlast:setDefaults()
  AltaMeleeHold.setDefaults(self)
  self.projectileTimesAndAngles = self.projectileTimesAndAngles or { {0.02, -20}, {0.10, -35}, {0.18, -50} }
  self.projectileOffset = self.projectileOffset or {1.75, -2.0}
  self.projectileType = self.projectileType or "energyshardplayer"
  self.stances.windup = self.stances.windup or { duration=0.2, armRotation=70, weaponRotation=0, twoHanded=true, allowRotate=false, allowFlip=false }
  self.stances.fire = self.stances.fire or { duration=0.25, armRotation=-45, weaponRotation=-55, twoHanded=true, allowRotate=false, allowFlip=false }
end








Parry = AltaMeleeDownstab:new()

function Parry:holdAbil() if self:canHold() then self:drainEnergy(self.holdParams); self:setState(self.parry) end end

function Parry:parry()
  self.weapon:setStance(self.stances.parry)
  self.weapon:updateAim()
  status.setPersistentEffects("broadswordParry", {{stat = "shieldHealth", amount = self.holdParams.shieldHealth}})
  local blockPoly = animator.partPoly("parryShield", "shieldPoly")
  activeItem.setItemShieldPolys({blockPoly})
  animator.setAnimationState("parryShield", "active")
  animator.playSound("guard")

  local damageListener = damageListener("damageTaken", function(notifications)
    for _,notification in pairs(notifications) do
      if notification.sourceEntityId ~= -65536 and notification.healthLost == 0 then
        animator.playSound("parry")
        animator.setAnimationState("parryShield", "block")
        return
      end
    end
  end)

  self:countHit(self.holdParams.damageConfig)
  util.wait(self.holdParams.parryTime, function(dt)  -- Interrupt when running out of shield stamina
    if not status.resourcePositive("shieldStamina") then return true end
    damageListener:update()
  end)
  self:holdCooldownReset()
  activeItem.setItemShieldPolys({})
end

function Parry:reset()
  animator.setAnimationState("parryShield", "inactive")
  status.clearPersistentEffects("broadswordParry")
  activeItem.setItemShieldPolys({})
end

function Parry:uninit()
  self:reset()
  AltaMeleeDownstab.uninit(self)
end

function Parry:setDefaults()
  AltaMeleeDownstab.setDefaults(self)
  self.holdParams.cooldownTime = self.holdParams.cooldownTime or 1.2
  self.holdParams.parryTime = self.holdParams.parryTime or 2.2
  self.holdParams.shieldHealth = self.holdParams.shieldHealth or 50
  self.stances.parry = self.stances.parry or { armRotation=45, weaponRotation=-205, twoHanded=true, allowRotate=false, allowFlip=true }
end











RisingSlash = AltaMeleeDownstab:new()

function RisingSlash:init()
  self:reset()
  AltaMeleeDownstab.init(self)
end

function RisingSlash:holdAbil() if self:canHold() then self:drainEnergy(self.holdParams); self:setState(self.windupHold) end end

function RisingSlash:windupHold()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()
  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  animator.setGlobalTag("directives", "?flipx")
  util.wait(self.stances.windup.duration or 0, function() return not self:canDrainEnergy(self.holdParams) end)
  self:setState(self.slash)
end

function RisingSlash:slash()
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()
  animator.setAnimationState("risingSwoosh", "slash")
  animator.playSound("upswing")
  self:countHit(self.holdParams.damageConfig)
  util.wait(self.stances.slash.duration, function()
    if math.abs(world.gravity(mcontroller.position())) > 0 then
      mcontroller.controlApproachYVelocity(self.holdParams.dashSpeed, self.holdParams.dashControlForce)
    end
    self:fireMelee(self.holdParams.damageConfig, 'risingSwoosh')
  end)
  self:holdCooldownReset()
  self:setState(self.freeze)
end

function RisingSlash:freeze()
  self.weapon:setStance(self.stances.freeze)
  self.weapon:updateAim()
  util.wait(self.stances.freeze.duration, function() mcontroller.setVelocity({0,0}) end)
end

function RisingSlash:reset()
  animator.setGlobalTag("directives", "")
  status.clearPersistentEffects("weaponMovementAbility")
end

function RisingSlash:uninit()
  self:reset()
  AltaMeleeDownstab.uninit(self)
end

function RisingSlash:setDefaults()
  AltaMeleeDownstab.setDefaults(self)
  self.holdParams.cooldownTime = self.holdParams.cooldownTime or 1.0
  self.holdParams.dashSpeed = self.holdParams.dashSpeed or 75
  self.holdParams.dashControlForce = self.holdParams.dashControlForce or 1600
  self.holdParams.damageConfig = util.mergeTable(
    { baseDamage=6, knockback={0, 50}, damageSourceKind="broadsword",knockbackMode="facing",timeoutGroup=self.abilitySlot,timeout=0.3},
    copy(self.holdParams.damageConfig or {})
  )
  self.stances.windup = self.stances.windup or { duration=0.25, armRotation=-90, weaponRotation=-170, twoHanded=true, allowRotate=false, allowFlip=false }
  self.stances.slash = self.stances.slash or { duration=0.175, armRotation=45, weaponRotation=-125, twoHanded=true, allowRotate=false, allowFlip=false }
  self.stances.freeze = self.stances.freeze or { duration=0.1, armRotation=45, weaponRotation=-125, twoHanded=true, allowRotate=false, allowFlip=false }
end










SpinSlash = AltaMeleeDownstab:new()

function SpinSlash:init()
  self:reset()
  AltaMeleeDownstab.init(self)
end

function SpinSlash:holdAbil() if self:canHold() then self:setState(self.slash) end end

function SpinSlash:slash()
  local slash = coroutine.create(self.slashAction)
  coroutine.resume(slash, self)
  local movement = function()
    mcontroller.controlModifiers({runningSuppressed = true})
    if self.hover then mcontroller.controlApproachYVelocity(self.hoverYSpeed, self.hoverForce) end
  end
  while util.parallel(slash, movement) do coroutine.yield() end
end

function SpinSlash:slashAction()
  local armRotationOffset = math.random(1, #self.armRotationOffsets)
  while self:isOn() do
    if not self:drainEnergy({energyFactor=(self.stances.windup.duration + self.stances.slash.duration)}) then return end

    self.weapon:setStance(self.stances.windup)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation - util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()
    util.wait(self.stances.windup.duration, function() return not self:canDrainEnergy(self.holdParams) end)
    self.weapon.aimDirection = -self.weapon.aimDirection
    self.weapon:setStance(self.stances.slash)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation + util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()

    armRotationOffset = armRotationOffset + 1
    if armRotationOffset > #self.armRotationOffsets then armRotationOffset = 1 end

    animator.setAnimationState("spinSwoosh", "fire", true)
    animator.playSound("flail")

    self:countHit(self.holdParams.damageConfig)
    util.wait(self.stances.slash.duration, function() self:fireMelee(self.holdParams.damageConfig, 'spinSwoosh') end)
  end
  self:holdCooldownReset()
end

function SpinSlash:reset() animator.setGlobalTag("swooshDirectives", "") end

function SpinSlash:uninit()
  self:reset()
  AltaMeleeDownstab.uninit(self)
end



















SuperSpinSlash = AltaMeleeDownstab:new()

function SuperSpinSlash:init()
  self:reset()
  AltaMeleeDownstab.init(self)
end

function SuperSpinSlash:holdAbil() if self:canHold() then self:setState(self.slash) end end

function SuperSpinSlash:slash()
  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  local slash = coroutine.create(self.slashAction)
  coroutine.resume(slash, self)

  local movement = function()
    mcontroller.controlModifiers({runningSuppressed = true})
    if self.hover and math.abs(world.gravity(mcontroller.position())) > 0 then
      mcontroller.controlApproachYVelocity(self.hoverYSpeed, self.hoverForce)
    end
  end

  while util.parallel(slash, movement) do coroutine.yield() end
end

function SuperSpinSlash:slashAction()
  local armRotationOffset = math.random(1, #self.armRotationOffsets)
  while self:isOn() do
    if not self:drainEnergy({energyFactor=(self.stances.windup.duration + self.stances.slash.duration)}) then return end

    self.weapon:setStance(self.stances.windup)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation - util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()
    util.wait(self.stances.windup.duration, function() return not self:canDrainEnergy(self.holdParams) end)
    self.weapon.aimDirection = -self.weapon.aimDirection
    self.weapon:setStance(self.stances.slash)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation + util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()

    armRotationOffset = armRotationOffset + 1
    if armRotationOffset > #self.armRotationOffsets then armRotationOffset = 1 end

    animator.setAnimationState("spinSwoosh", "fire", true)

    self:countHit(self.holdParams.damageConfig)
    util.wait(self.stances.slash.duration, function() self:fireMelee(self.holdParams.damageConfig, 'spinSwoosh') end)
  end
  self:holdCooldownReset()
end

function SuperSpinSlash:reset()
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setGlobalTag("swooshDirectives", "")
end

function SuperSpinSlash:uninit()
  self:reset()
  AltaMeleeDownstab.uninit(self)
end







TrailDash = AltaMeleeDownstab:new()

function TrailDash:holdAbil() if self:canHoldMove() then self:drainEnergy(self.holdParams); self:setState(self.windupHold) end end

function TrailDash:windupHold()
  self.weapon:setStance(self.stances.windup)
  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  animator.setParticleEmitterActive(self.weapon.elementalType.."SwordCharge", true)
  animator.playSound(self.weapon.elementalType.."TrailDashCharge")
  util.wait(self.stances.windup.duration, function(dt) mcontroller.controlModifiers({jumpingSuppressed = true}) end)
  self:setState(self.dash)
end

function TrailDash:dash()
  self.weapon:setStance(self.stances.dash)
  animator.playSound(self.weapon.elementalType.."TrailDashFire")
  local wasInvulnerable = status.stat("invulnerable") > 0
  status.addEphemeralEffect("invulnerable", self.dashTime)
  local position = mcontroller.position()
  local params = copy(self.holdParams.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.power = params.power * config.getParameter("damageLevelMultiplier")
  self:countHit(self.holdParams.damageConfig)
  util.wait(self.holdParams.dashTime, function(dt)
    if not mcontroller.onGround() then
      if not wasInvulnerable then status.removeEphemeralEffect("invulnerable") end
      return true
    end

    mcontroller.setVelocity({self.weapon.aimDirection * self.holdParams.dashSpeed, -200})
    mcontroller.controlMove(self.weapon.aimDirection)

    local direction = vec2.norm(world.distance(mcontroller.position(), position))
    while world.magnitude(mcontroller.position(), position) >= self.holdParams.trailInterval do
      position = vec2.add(position, vec2.mul(direction, self.holdParams.trailInterval))
      world.spawnProjectile(self.holdParams.type, vec2.add(position, self.holdParams.offset), activeItem.ownerEntityId(), {-mcontroller.facingDirection(),0}, false, params)
    end
    self:fireMelee(self.holdParams.damageConfig, 'blade')
  end)
  animator.setParticleEmitterActive(self.weapon.elementalType.."SwordCharge", false)
  self:holdCooldownReset()
  mcontroller.setVelocity({0,0})
end

function TrailDash:uninit()
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setParticleEmitterActive(self.weapon.elementalType.."SwordCharge", false)
  if self.weapon.currentState == self.dash then mcontroller.setVelocity({0,0}) end
  AltaMeleeDownstab.uninit(self)
end

function TrailDash:setDefaults()
  AltaMeleeDownstab.setDefaults(self)
  self.holdParams.energyFactor = self.holdParams.energyFactor or 3.0
  self.holdParams.cooldownTime = self.holdParams.cooldownTime or 0.4
  self.holdParams.dashSpeed = self.holdParams.dashSpeed or 160
  self.holdParams.dashTime = self.holdParams.dashTime or 0.2
  self.holdParams.trailInterval = self.holdParams.trailInterval or 1.0
  self.holdParams.type = self.holdParams.type or 'electrictrail'
  self.holdParams.offset = self.holdParams.offset or {0, -1.5}
  self.holdParams.projectileParameters = self.holdParams.projectileParameters or { power=1, timeToLive=2.0 }
  self.stances.windup = self.stances.windup or { duration=0.5, armRotation=-45, weaponRotation=155, twoHanded=true, allowRotate=false, allowFlip=false }
  self.stances.dash = self.stances.dash or { armRotation=45, weaponRotation=135, twoHanded=true, allowRotate=false, allowFlip=false }
end







TravelingSlash = AltaMeleeDownstab:new()

function TravelingSlash:holdAbil() if self:canHold() then self:drainEnergy(self.holdParams); self:setState(self.windupHold) end end
function TravelingSlash:slashSound() return self.weapon.elementalType.."TravelSlash" end
function TravelingSlash:aimVector() return {mcontroller.facingDirection(), 0} end
function TravelingSlash:damageAmount() return self.baseDamage * config.getParameter("damageLevelMultiplier") end

function TravelingSlash:windupHold()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()
  util.wait(self.stances.windup.duration)
  self:setState(self.fireHold)
end

function TravelingSlash:fireHold()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()
  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local params = { powerMultiplier = activeItem.ownerPowerMultiplier(), power = self:damageAmount() }
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false, params)
  animator.playSound(self:slashSound())
  self:countHit(self.holdParams.damageConfig)
  util.wait(self.stances.fire.duration)
  self:holdCooldownReset()
end

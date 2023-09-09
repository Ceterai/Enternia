---@diagnostic disable: undefined-global, lowercase-global
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/scripts/status.lua"
require "/scripts/poly.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/melee/alta/enhanced.lua"





BladeCharge = AltaMeleeDownstab:new()

function BladeCharge:init()
  BladeCharge:reset()
  AltaMeleeDownstab.init(self)
end

function BladeCharge:holdAbil() if self:canHold() then self:setState(self.windupHold) end end

function BladeCharge:windupHold()
  self.weapon:setStance(self.stances.windup)
  animator.setAnimationState("bladeCharge", "charge")
  animator.setParticleEmitterActive("bladeCharge", true)
  local chargeTimer = self.holdParams.chargeTime
  while self:isActive() do
    chargeTimer = math.max(0, chargeTimer - self.dt)
    if chargeTimer == 0 then animator.setGlobalTag("bladeDirectives", "border=3;"..self.holdParams.chargeBorder..";00000000") end
    coroutine.yield()
  end
  if chargeTimer == 0 and status.overConsumeResource("energy", self.energyUsage) then self:setState(self.slash) end
end

function BladeCharge:slash()
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()
  animator.setAnimationState("bladeCharge", "idle")
  animator.setParticleEmitterActive("bladeCharge", false)
  animator.setAnimationState("swoosh", "fire")
  animator.playSound("chargedSwing")
  util.wait(self.stances.slash.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea)
  end)
  self.cooldownTimerHold = self.holdParams.cooldownTime
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





FlipSlash = AltaMeleeDownstab:new()

function FlipSlash:holdAbil() if self:canHoldMove() then self:setState(self.windupHold) end end

function FlipSlash:windupHold()
  status.overConsumeResource("energy", self.energyUsage)
  self.weapon:setStance(self.stances.windup)
  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  util.wait(self.stances.windup.duration, function(dt) mcontroller.controlCrouch() end)
  self:setState(self.flip)
end

function FlipSlash:flip()
  self.weapon:setStance(self.stances.flip)
  self.weapon:updateAim()

  animator.setAnimationState("swoosh", "flip")
  animator.playSound("fireHold")
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
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)
    mcontroller.setRotation(-math.pi * 2 * self.weapon.aimDirection * (self.flipTimer / self.rotationTime))
    coroutine.yield()
  end
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setAnimationState("swoosh", "idle")
  mcontroller.setRotation(0)
  animator.setParticleEmitterActive("flip", false)
  self.cooldownTimerHold = self.holdParams.cooldownTime
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

-- Attack state: windup
function GreatWave:windupHold()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()
  util.wait(self.stances.windup.duration)
  self:setState(self.fireHold)
end

-- Attack state: fire
function GreatWave:fireHold()
  self.weapon:setStance(self.stances.fire)
  self:fireShockwave()
  animator.playSound("fireHold")
  util.wait(self.stances.fire.duration)
  self.cooldownTimerHold = self.holdParams.cooldownTime
end

-- Helper functions
function GreatWave:fireShockwave()
  return ShockWave.fireShockwave(self, 1.0)
end

function GreatWave:impactPosition()
  return ShockWave.impactPosition(self)
end

function GreatWave:shockwaveProjectilePositions(impactPosition, maxDistance, directions)
  return ShockWave.shockwaveProjectilePositions(self, impactPosition, maxDistance, directions)
end





KunaiBlast = AltaMeleeDownstab:new()

function KunaiBlast:holdAbil() if self:canHold() then self:setState(self.windupHold) end end

function KunaiBlast:windupHold()
  status.overConsumeResource("energy", self.energyUsage)
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
  self.cooldownTimerHold = self.holdParams.cooldownTime
end

function KunaiBlast:spawnProjectile(angleAdjust)
  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * self.weapon.aimDirection, self.projectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self:damageAmount()
  }
  local aimVector = vec2.withAngle(util.toRadians(angleAdjust))
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), aimVector, false, params)
  animator.playSound("fireKunai")
end

function KunaiBlast:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end

function KunaiBlast:uninit()
  status.clearPersistentEffects("weaponMovementAbility")
  AltaMeleeDownstab.uninit(self)
end








Parry = AltaMeleeDownstab:new()

function Parry:holdAbil() if self:canHold() then status.overConsumeResource("energy", self.energyUsage); self:setState(self.parry) end end

function Parry:parry()
  self.weapon:setStance(self.stances.parry)
  self.weapon:updateAim()
  status.setPersistentEffects("broadswordParry", {{stat = "shieldHealth", amount = self.shieldHealth}})
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

  util.wait(self.parryTime, function(dt)
    --Interrupt when running out of shield stamina
    if not status.resourcePositive("shieldStamina") then return true end
    damageListener:update()
  end)

  self.cooldownTimerHold = self.holdParams.cooldownTime
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











RisingSlash = AltaMeleeDownstab:new()

function RisingSlash:init()
  self:reset()
  AltaMeleeDownstab.init(self)
end

function RisingSlash:holdAbil() if self:canHold() then status.overConsumeResource("energy", self.energyUsage); self:setState(self.windupHold) end end

function RisingSlash:windupHold()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  animator.setGlobalTag("directives", "?flipx")

  util.wait(self.stances.windup.duration, function()
    return status.resourceLocked("energy")
  end)

  self:setState(self.slash)
end

function RisingSlash:slash()
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()

  animator.setAnimationState("risingSwoosh", "slash")
  animator.playSound("upswing")

  util.wait(self.stances.slash.duration, function()
    if math.abs(world.gravity(mcontroller.position())) > 0 then
      mcontroller.controlApproachYVelocity(self.dashSpeed, self.dashControlForce)
    end

    local damageArea = partDamageArea("risingSwoosh")
    self.weapon:setDamage(self.damageConfig, damageArea)
  end)

  self.cooldownTimerHold = self.holdParams.cooldownTime
  self:setState(self.freeze)
end

function RisingSlash:freeze()
  self.weapon:setStance(self.stances.freeze)
  self.weapon:updateAim()

  util.wait(self.stances.freeze.duration, function()
    mcontroller.setVelocity({0,0})
  end)
end

function RisingSlash:reset()
  animator.setGlobalTag("directives", "")
  status.clearPersistentEffects("weaponMovementAbility")
end

function RisingSlash:uninit()
  self:reset()
  AltaMeleeDownstab.uninit(self)
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

    if self.hover then
      mcontroller.controlApproachYVelocity(self.hoverYSpeed, self.hoverForce)
    end
  end

  while util.parallel(slash, movement) do
    coroutine.yield()
  end
end

function SpinSlash:slashAction()
  local armRotationOffset = math.random(1, #self.armRotationOffsets)
  while self:isActive() do
    if not status.overConsumeResource("energy", self.energyUsage * (self.stances.windup.duration + self.stances.slash.duration)) then return end

    self.weapon:setStance(self.stances.windup)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation - util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()

    util.wait(self.stances.windup.duration, function()
      return status.resourceLocked("energy")
    end)

    self.weapon.aimDirection = -self.weapon.aimDirection

    self.weapon:setStance(self.stances.slash)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation + util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()

    armRotationOffset = armRotationOffset + 1
    if armRotationOffset > #self.armRotationOffsets then armRotationOffset = 1 end

    animator.setAnimationState("spinSwoosh", "fire", true)
    animator.playSound("flail")

    util.wait(self.stances.slash.duration, function()
      local damageArea = partDamageArea("spinSwoosh")
      self.weapon:setDamage(self.damageConfig, damageArea)
    end)
  end

  self.cooldownTimerHold = self.holdParams.cooldownTime
end

function SpinSlash:reset()
  animator.setGlobalTag("swooshDirectives", "")
end

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

  while util.parallel(slash, movement) do
    coroutine.yield()
  end
end

function SuperSpinSlash:slashAction()
  local armRotationOffset = math.random(1, #self.armRotationOffsets)
  while self:isActive() do
    if not status.overConsumeResource("energy", self.energyUsage * (self.stances.windup.duration + self.stances.slash.duration)) then return end

    self.weapon:setStance(self.stances.windup)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation - util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()

    util.wait(self.stances.windup.duration, function()
      return status.resourceLocked("energy")
    end)

    self.weapon.aimDirection = -self.weapon.aimDirection

    self.weapon:setStance(self.stances.slash)
    self.weapon.relativeArmRotation = self.weapon.relativeArmRotation + util.toRadians(self.armRotationOffsets[armRotationOffset])
    self.weapon:updateAim()

    armRotationOffset = armRotationOffset + 1
    if armRotationOffset > #self.armRotationOffsets then armRotationOffset = 1 end

    animator.setAnimationState("spinSwoosh", "fire", true)

    util.wait(self.stances.slash.duration, function()
      local damageArea = partDamageArea("spinSwoosh")
      self.weapon:setDamage(self.damageConfig, damageArea)
    end)
  end

  self.cooldownTimerHold = self.holdParams.cooldownTime
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

function TrailDash:holdAbil() if self:canHoldMove() then status.overConsumeResource("energy", self.energyUsage); self:setState(self.windupHold) end end

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
  local params = copy(self.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.power = params.power * config.getParameter("damageLevelMultiplier")
  util.wait(self.dashTime, function(dt)
    if not mcontroller.onGround() then
      if not wasInvulnerable then status.removeEphemeralEffect("invulnerable") end
      return true
    end

    mcontroller.setVelocity({self.weapon.aimDirection * self.dashSpeed, -200})
    mcontroller.controlMove(self.weapon.aimDirection)

    local direction = vec2.norm(world.distance(mcontroller.position(), position))
    while world.magnitude(mcontroller.position(), position) >= self.trailInterval do
      position = vec2.add(position, vec2.mul(direction, self.trailInterval))
      world.spawnProjectile(self.projectileType, vec2.add(position, self.projectileOffset), activeItem.ownerEntityId(), {-mcontroller.facingDirection(),0}, false, params)
    end

    local damageArea = partDamageArea("blade")
    self.weapon:setDamage(self.damageConfig, damageArea)
  end)
  animator.setParticleEmitterActive(self.weapon.elementalType.."SwordCharge", false)

  mcontroller.setVelocity({0,0})
end

function TrailDash:uninit()
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setParticleEmitterActive(self.weapon.elementalType.."SwordCharge", false)
  if self.weapon.currentState == self.dash then mcontroller.setVelocity({0,0}) end
  AltaMeleeDownstab.uninit(self)
end







TravelingSlash = AltaMeleeDownstab:new()

function TravelingSlash:holdAbil() if self:canHold() then status.overConsumeResource("energy", self.energyUsage); self:setState(self.windupHold) end end
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
  util.wait(self.stances.fire.duration)
  self.cooldownTimerHold = self.holdParams.cooldownTime
end

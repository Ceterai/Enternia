---@diagnostic disable: undefined-global, lowercase-global
require "/scripts/util.lua"
require "/scripts/status.lua"
require "/items/active/weapons/melee/alta/melee.lua"


--- ### Basic Combo & Hold
AltaMeleeHold = AltaCombo:new()

function AltaMeleeHold:update(dt, fireMode, shiftHeld)
  self.cooldownTimerHold = math.max(0, self.cooldownTimerHold - dt)
  AltaCombo.update(self, dt, fireMode, shiftHeld)
end

function AltaMeleeHold:hold() self:holdAbil() end
function AltaMeleeHold:holdAbil() end  -- define custom logic
function AltaMeleeHold:holdCooldownReset() self.cooldownTimerHold = self.holdParams.cooldownTime end
function AltaMeleeHold:canHold() return self.cooldownTimerHold == 0 and self:canDrainEnergy(self.holdParams) and self:isOn() end
function AltaMeleeHold:canHoldMove() return self:canHold() and mcontroller.onGround() and not status.statPositive("activeMovementAbilities") end
function AltaMeleeHold:canHoldMoveAir() return self:canHold() and not mcontroller.onGround() and not status.statPositive("activeMovementAbilities") end

function AltaMeleeHold:setDefaults()
  AltaCombo.setDefaults(self)
  self.holdParams = self.holdParams or {}
  self.holdParams.damageConfig = self.holdParams.damageConfig or self.damageConfig
  self.holdParams.cooldownTime = self.holdParams.cooldownTime or 1.0
  self:holdCooldownReset()
end





--- ### Basic Combo & Hold Downstab
--- Basic melee combo ability that does a downstab on hold if in the air.  
--- Required sounds:
--- - `downstab`
AltaMeleeDownstab = AltaMeleeHold:new()

function AltaMeleeDownstab:hold() if self:canHoldMoveAir() then self:setState(self.startDownstab) else self:holdAbil() end end
function AltaMeleeDownstab:inGravity() return math.abs(world.gravity(mcontroller.position())) > 0 end

function AltaMeleeDownstab:startDownstab()
  self:drainEnergy(self.downstabParams)
  self.weapon:setStance(self.stances.hold)
  mcontroller.controlParameters({ airForce = self.downstabParams.holdAirControl })
  status.setPersistentEffects("altaMeleeDownstab", {{stat = "activeMovementAbilities", amount = 1}})
  util.wait(self.stances.hold.duration)
  while mcontroller.yVelocity() > self.downstabParams.stabVelocity and math.abs(world.gravity(mcontroller.position())) > 0 and not mcontroller.onGround() do coroutine.yield() end
  self:setState(self.fallDownstab)
end

function AltaMeleeDownstab:fallDownstab()
  self.weapon:setStance(self.stances.stab)
  self.weapon:updateAim()
  animator.playSound("downstab")
  local energyDepleted = false
  local damageListener = damageListener("inflictedHits", function()
    if math.abs(world.gravity(mcontroller.position())) > 0 then mcontroller.setYVelocity(self.downstabParams.bounceYVelocity) end
    if self:drainEnergy(self.downstabParams) then self:setState(self.fire) else energyDepleted = true end
  end)
  local stabTimer = self.stances.stab.minStabTime
  while (stabTimer > 0 or (self:isOn() and self:inGravity())) and not mcontroller.onGround() do
    stabTimer = stabTimer - self.dt
    self:fireMelee(self.downstabParams.damageConfig, 'blade')
    if self:inGravity() then
      if mcontroller.yVelocity() > 0 then self:setState(self.fire) end
      damageListener:update()
    end
    if energyDepleted then return end
    coroutine.yield()
  end
  self:countHit(self.downstabParams.damageConfig)
end

function AltaMeleeDownstab:uninit()
  if #(status.getPersistentEffects("altaMeleeDownstab")) > 0 then
    status.clearPersistentEffects("altaMeleeDownstab")
    self:holdCooldownReset()
  end
  AltaMeleeHold.uninit(self)
end

function AltaMeleeDownstab:setDefaults()
  AltaMeleeHold.setDefaults(self)
  self.downstabParams = self.downstabParams or { cooldownTime=0.5, energyFactor=0.2, holdAirControl=60, stabVelocity=-5, bounceYVelocity=35 }
  self.downstabParams.damageConfig = util.mergeTable(
    {damageSourceKind="spear",damageFactor=0.5,knockback={0,-35},timeout=0.2,timeoutGroup=self.abilitySlot}, copy(self.downstabParams.damageConfig or {})
  )
  self.stances.hold = self.stances.hold or { duration=0.2, armRotation=-70, weaponRotation=-40, twoHanded=true, allowRotate=false, allowFlip=true }
  self.stances.stab = self.stances.stab or { armRotation=-50, weaponRotation=-75, twoHanded=true, minStabTime=0.2, allowRotate=false, allowFlip=true }
end

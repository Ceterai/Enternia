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

function AltaMeleeHold:canHold()
  return self.cooldownTimerHold == 0
  -- and not self.weapon.currentAbility
  and not status.resourceLocked("energy")
  and self:isActive()
end

function AltaMeleeHold:canHoldMove()
  return self:canHold()
  and mcontroller.onGround()
  and not status.statPositive("activeMovementAbilities")
end

function AltaMeleeHold:canHoldMoveAir()
  return self:canHold()
  and not mcontroller.onGround()
  and not status.statPositive("activeMovementAbilities")
end

function AltaMeleeHold:setDefaults()
  AltaCombo.setDefaults(self)
  self.name = self.name or 'Alta Melee Abil'
  self.cooldownTimer = 0
  self.weapon:setStance(self.stances.idle)
  self.holdParams.cooldownTime = self.holdParams.cooldownTime or 0
  self.cooldownTimerHold = self.holdParams.cooldownTime

  self.damageConfig = self.damageConfig or
  { statusEffects={}, baseDamage=22.5, knockback=40, damageSourceKind="broadsword",knockbackMode="facing",timeoutGroup="alt",timeout=0.5}
  self.flashTime = self.flashTime or 0.15
  self.flashDirectives = self.flashDirectives or "fade=FFFFFFFF=0.15"
  self.comboSpeedFactor = self.comboSpeedFactor or 0.9
  self.edgeTriggerGrace = self.edgeTriggerGrace or 0.25
  self.stepConfig = self.stepConfig or {
    { damageFactor=1.0, energyFactor=0.0, knockback=10.0, swoosh="swoosh1", swooshOffsetRegion={0.75, 0.0, 4.25, 5.0} },
    { damageFactor=0.4, energyFactor=0.0, knockback=5.00, swoosh="swoosh2", swooshOffsetRegion={3.0, -0.5, 6.50, 2.0} },
    { damageFactor=1.1, energyFactor=0.0, knockback=25.0, swoosh="swoosh3", swooshOffsetRegion={1.5, -1.0, 5.50, 1.0}, statusEffects={} }
  }
  self.downstabParams=self.downstabParams or {
    cooldownTime=0.5, energyFactor=0.2, holdAirControl=60, stabVelocity=-5, bounceYVelocity=35, damageConfig={
      damageSourceKind="spear", statusEffects={}, baseDamage=6, knockback={0, -35}, timeout=0.2, timeoutGroup="alt"
    }
  }
  self.stances=self.stances or {
      idle={ armRotation=-75, weaponRotation=-10, twoHanded=true, allowRotate=true, allowFlip=true },
      windup={ armRotation=70, weaponRotation=0, twoHanded=true, allowRotate=false, allowFlip=true },
      slash={ duration=0.4, armRotation=-45, weaponRotation=-55, twoHanded=true, allowRotate=false, allowFlip=false },
      dash={ armRotation=-25, weaponRotation=-65, twoHanded=true, weaponOffset={0.0, 2.0}, allowRotate=false, allowFlip=false },
      hold={ duration=0.2, armRotation=-70, weaponRotation=-40, twoHanded=true, allowRotate=false, allowFlip=true },
      stab={ armRotation=-50, weaponRotation=-75, twoHanded=true, minStabTime=0.2, allowRotate=false, allowFlip=true },
      windup1={ duration=0.25, armRotation=90, weaponRotation=-10, twoHanded=true, allowRotate=true, allowFlip=true },
      preslash1={ duration=0.05, armRotation=55, weaponRotation=-45, twoHanded=true, allowRotate=false, allowFlip=false },
      fire1={ duration=0.25, armRotation=-45, weaponRotation=-55, twoHanded=true, allowRotate=false, allowFlip=false },
      wait1={ duration=0.2, armRotation=-45, weaponRotation=-55, allowRotate=true, allowFlip=true, twoHanded=true },
      windup2={ duration=0.25, armRotation=-15, weaponRotation=-60, weaponOffset={0, 1.1}, twoHanded=true, allowFlip=true, allowRotate=true },
      fire2={ duration=0.3, armRotation=-150, weaponRotation=55, weaponOffset={0, 1.1}, twoHanded=true, allowFlip=true, allowRotate=false },
      wait2={ duration=0.2, armRotation=-150, weaponRotation=55, weaponOffset={0, 1.1}, allowRotate=true, allowFlip=true, twoHanded=true },
      windup3={ duration=0.25, armRotation=-150, weaponRotation=55, twoHanded=true, allowRotate=true, allowFlip=true },
      fire3={ duration=0.2, armRotation=0, weaponRotation=-90, twoHanded=true, allowRotate=false, allowFlip=true }
    }
end





--- ### Basic Combo & Hold Downstab
--- Basic melee combo ability that does a downstab on hold if in the air.  
--- Required sounds:
--- - `downstab`
AltaMeleeDownstab = AltaMeleeHold:new()

function AltaMeleeDownstab:hold()
  if self:canHoldMoveAir() then self:setState(self.startDownstab) else self:holdAbil() end
end

function AltaMeleeDownstab:holdAbil() end

function AltaMeleeDownstab:startDownstab()
  status.overConsumeResource("energy", self.energyUsage * self.downstabParams.energyFactor)
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
    if status.overConsumeResource("energy", self.energyUsage * self.downstabParams.energyFactor) then self:setState(self.fire) else energyDepleted = true end
  end)
  local stabTimer = self.stances.stab.minStabTime
  while (stabTimer > 0 or (self:isActive() and self:inGravity())) and not mcontroller.onGround() do
    stabTimer = stabTimer - self.dt
    local damageArea = partDamageArea("blade")
    self.weapon:setDamage(self.damageConfig, damageArea)
    if self:inGravity() then
      if mcontroller.yVelocity() > 0 then self:setState(self.fire) end
      damageListener:update()
    end
    if energyDepleted then return end
    coroutine.yield()
  end
end

function AltaMeleeDownstab:inGravity() return math.abs(world.gravity(mcontroller.position())) > 0 end

function AltaMeleeDownstab:uninit()
  if #(status.getPersistentEffects("altaMeleeDownstab")) > 0 then
    status.clearPersistentEffects("altaMeleeDownstab")
    self.cooldownTimerHold = self.holdParams.cooldownTime
  end
  AltaMeleeHold.uninit(self)
end

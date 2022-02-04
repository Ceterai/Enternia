require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/melee/meleecombo.lua"

-- Spear stab attack
-- Extends normal melee attack and adds a hold state
SpearStab = MeleeCombo:new()

function SpearStab:init()
  self:reset()
  MeleeCombo.init(self)
  self.holdEnergyUsage = self.energyUsage or 0
  self.holdFireTime = self.holdFireTime or 0
  self.energyUsage = 0

  self.damageConfig.baseDamage = self.baseDps
  self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
  self.holdDamageConfig.baseDamage = self.holdDamageMultiplier * self.damageConfig.baseDamage
end

function SpearStab:fire()
  local stance = self.stances["fire"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  local animStateKey = self.animKeyPrefix .. (self.comboStep > 1 and "fire"..self.comboStep or "fire")
  animator.setAnimationState("swoosh", animStateKey)
  animator.playSound(animStateKey)

  local swooshKey = self.animKeyPrefix .. (self.elementalType or self.weapon.elementalType) .. "swoosh"
  animator.setParticleEmitterOffsetRegion(swooshKey, self.swooshOffsetRegions[self.comboStep])
  animator.burstParticleEmitter(swooshKey)

  util.wait(stance.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.stepDamageConfig[self.comboStep], damageArea)
  end)

  if self.comboStep == self.comboSteps then
    local position = vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("blade", "projectileSource")))
    local params = copy(self.projectileParameters)
    params.powerMultiplier = activeItem.ownerPowerMultiplier()
    params.power = params.power * config.getParameter("damageLevelMultiplier")
    self.inaccuracy = 0.3
    local aim = 0
    for i=1,8 do
      aim = self.weapon.aimAngle + util.randomInRange({-self.inaccuracy, self.inaccuracy})
      world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), {mcontroller.facingDirection() * math.cos(aim), math.sin(aim)}, false, params)
    end
  end

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

function SpearStab:combo()
  if self.comboStep < self.comboSteps then
    self.comboStep = self.comboStep + 1
    self:setState(self.wait)
  else
    self.cooldownTimer = self.cooldowns[self.comboStep]
    self.comboStep = 1
  end
end

function SpearStab:dash()
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
  self.cooldownTimer = self.holdFireTime
  self:setState(self.combo)
end

function SpearStab:reset()
  self.holdTime = 0
  animator.setAnimationState("dashSwoosh", "idle")
end

function SpearStab:uninit()
  MeleeCombo.uninit(self)
  self:reset()
end

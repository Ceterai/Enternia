---@diagnostic disable: undefined-global, lowercase-global
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/ct_alta_weapon.lua"
require "/items/active/weapons/ranged/gun.lua"
require "/items/active/weapons/ranged/gunfire.lua"
require "/items/active/weapons/ranged/beamfire.lua"

function init()
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.setGlobalTag("directives", "")
  animator.setGlobalTag("bladeDirectives", "")
  animator.playSound("init")

  self.weapon = Weapon:new()
  self.weapon.builder = "/items/buildscripts/ct_alta_item_builder.lua"
  self.weapon.isWrist = config.getParameter("isWrist", false)
  self.weapon:addAbility(getAbil(AltaMelee, "primary"))
  if config.getParameter("altAbility") then
    self.weapon:addAbility(getAbil(AltaMelee, "alt"))
  end
  self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
  self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)
  self.weapon:init()
  if self.weapon.isWrist then updateHand() end
end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
  if self.weapon.isWrist then updateHand() end
end
















--- ### Basic Combo
--- Basic melee combo ability. Each hit is configured as an object.   
--- Each hit:
--- - increase combo counter
--- - increase overall hit counter per init
--- - increase overall hit counter
--- - decrease bonus counter
--- - check if need to fire projectiles
AltaCombo = AltaUtils:new()

function AltaCombo:setDefaults()
  AltaUtils.setDefaults(self)
  self.comboStep = 1
  self.sessionStep = 1
  self.energyUsage = self.energyUsage or 0
  self:computeDamageAndCooldowns()
  self.weapon:setStance(self.stances.idle)
  self.edgeTriggerTimer = 0
  self.flashTimer = 0
  self.cooldownTimer = self.cooldowns[1]
  self.animKeyPrefix = self.animKeyPrefix or ""
  self.weapon.onLeaveAbility = function() self.weapon:setStance(self.stances.idle) end
end

-- Ticks on every update regardless if this is the active ability
function AltaCombo:update(dt, fireMode, shiftHeld)
  AltaAbil.update(self, dt, fireMode, shiftHeld)

  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
    if self.cooldownTimer == 0 then
      self:readyFlash()
    end
  end

  if self.flashTimer > 0 then
    self.flashTimer = math.max(0, self.flashTimer - self.dt)
    if self.flashTimer == 0 then
      animator.setGlobalTag("bladeDirectives", "")
    end
  end

  self.edgeTriggerTimer = math.max(0, self.edgeTriggerTimer - dt)
  if self.lastFireMode ~= (self.activatingFireMode or self.abilitySlot) and fireMode == (self.activatingFireMode or self.abilitySlot) then
    self.edgeTriggerTimer = self.edgeTriggerGrace
  end
  self.lastFireMode = fireMode

  if not self:isActive() and self.loop and self.active then self:deactivate() end
  if self:isActive() then self:setState(self.switch) end
end

function AltaCombo:isActive()
  return not self.weapon.currentAbility and self:shouldActivate()
end

function AltaCombo:press()
  self:setState(self.windup)
end

-- State: windup
function AltaCombo:windup()
  local stance = self.stances["windup"..self.comboStep]

  self.weapon:setStance(stance)

  self.edgeTriggerTimer = 0

  if stance.hold then
    while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
      coroutine.yield()
    end
  else
    util.wait(stance.duration)
  end

  if self.energyUsage then
    status.overConsumeResource("energy", self.energyUsage)
  end

  if self.stances["preslash"..self.comboStep] then
    self:setState(self.preslash)
  else
    self:setState(self.fire)
  end
end

-- State: preslash
-- brief frame in between windup and fire
function AltaCombo:preslash()
  local stance = self.stances["preslash"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  util.wait(stance.duration)

  self:setState(self.fire)
end

-- State: fire
function AltaCombo:fire()
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

  if self.comboStep < self.comboSteps then
    self.comboStep = self.comboStep + 1
    self:setState(self.wait)
  else
    self.cooldownTimer = self.cooldowns[self.comboStep]
    self.comboStep = 1
  end
end

-- State: wait
-- waiting for next combo input
function AltaCombo:wait()
  local stance = self.stances["wait"..(self.comboStep - 1)]

  self.weapon:setStance(stance)

  util.wait(stance.duration, function()
    if self:shouldActivate() then
      self:setState(self.windup)
      return
    end
  end)

  self.cooldownTimer = math.max(0, self.cooldowns[self.comboStep - 1] - stance.duration)
  self.comboStep = 1
end

function AltaCombo:shouldActivate()
  if self.cooldownTimer == 0 and (self.energyUsage == 0 or not status.resourceLocked("energy")) then
    if self.comboStep > 1 then
      return self.edgeTriggerTimer > 0
    else
      return self.fireMode == (self.activatingFireMode or self.abilitySlot)
    end
  end
end

function AltaCombo:readyFlash()
  animator.setGlobalTag("bladeDirectives", self.flashDirectives)
  self.flashTimer = self.flashTime
end

function AltaCombo:computeDamageAndCooldowns()
  local attackTimes = {}
  for i = 1, self.comboSteps do
    local attackTime = self.stances["windup"..i].duration + self.stances["fire"..i].duration
    if self.stances["preslash"..i] then
      attackTime = attackTime + self.stances["preslash"..i].duration
    end
    table.insert(attackTimes, attackTime)
  end

  self.cooldowns = {}
  local totalAttackTime = 0
  local totalDamageFactor = 0
  for i, attackTime in ipairs(attackTimes) do
    self.stepDamageConfig[i] = util.mergeTable(copy(self.damageConfig), self.stepDamageConfig[i])
    self.stepDamageConfig[i].timeoutGroup = "primary"..i

    local damageFactor = self.stepDamageConfig[i].baseDamageFactor
    self.stepDamageConfig[i].baseDamage = damageFactor * self.baseDps * self.fireTime

    totalAttackTime = totalAttackTime + attackTime
    totalDamageFactor = totalDamageFactor + damageFactor

    local targetTime = totalDamageFactor * self.fireTime
    local speedFactor = 1.0 * (self.comboSpeedFactor ^ i)
    table.insert(self.cooldowns, (targetTime - totalAttackTime) * speedFactor)
  end
end

function AltaCombo:uninit()
  self.weapon:setDamage()
end

















--- ### Basic Combo & Hold
--- Basic "switch" ability. On press iterates over a list of attachments.  
--- Supported attachments: `none`, `flashlight`, `lazer` and `stabilizer`. Any other keyword will be treated as `none`.
AltaMelee = AltaUtils:new()

function AltaMelee:update(dt, fireMode, shiftHeld)
  AltaAbil.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  self:muzzleFlashOff()
  if (not self:isActive()
  or status.resourceLocked("energy")
  or world.lineTileCollision(mcontroller.position(), self:firePosition())) and self.loop and self.active then self:deactivate() end
  if self:canFire() then self:setState(self.switch) end
end

function AltaMelee:press()
  self.pressParams.method(self, self.pressParams)
end

function AltaMelee:hold()
  self.holdParams.method(self, self.holdParams)
end

function AltaMelee:none(params)
end

function AltaMelee:blast(params)
  if status.overConsumeResource("energy", self:energyPerShot()) then
    self.weapon:setStance(self.stances.fire)
    local firedIDs = self:fireProjectile(params)
    self.cooldownTimer = self.fireTime
    self:setState(self.cooldown)
    return firedIDs
  end
end

function AltaMelee:energyPerShot()
  return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0)
end

function AltaMelee:damagePerShot(count, multi)
  return (self.baseDamage or (self.baseDps * self.fireTime)) * (self.baseDamageMultiplier or 1.0) * (multi or 1.0) * (self.holdTime + 1.0) *
  config.getParameter("damageLevelMultiplier") * config.getParameter('stabilizerBonus', 1.0) * (self.weapon.stabilizerBonus or 1.0) / (count or 1)
end

function AltaMelee:setDefaults()
  self.stances = self.stances or { }
  self.stances.idle = self.stances.idle or {armRotation=0, weaponRotation=0, twoHanded=true, allowRotate=true, allowFlip=true,}
  self.stances.fire = self.stances.fire or {armRotation=3, weaponRotation=3, twoHanded=true, duration=0, allowRotate=false, allowFlip=true,}
  self.stances.cooldown = self.stances.cooldown or {armRotation=3, weaponRotation=3, twoHanded=true, duration=0.1, allowRotate=false, allowFlip=true,}
  AltaUtils.setDefaults(self)
  self.name = self.name or 'Alta Ranged Abil'
  self.blastTypes = { 'blast', 'rocket', 'snipe', 'semi', 'burst', 'nade', 'projectile', 'explosion', 'discharge', 'clouds', 'thrower', 'beam', 'tazer' }
  self.effectTypes = { 'field', 'effect' }
  self.actionPresets = {
    none = { method=self.none, },
    blast = { method=self.blast, type='ct_plasma_medium', count=1, params={ }, inaccuracy=0.04, interval=0.0, },
    rocket = { method=self.blast, type='rocketshell', count=1, params={ knockback=40, }, inaccuracy=0.0, interval=0.0, },
    snipe = { method=self.blast, type='ct_plasma_large', count=1, params={ knockback=40, }, inaccuracy=0.008, interval=0.0, },
    semi = { method=self.blast, type='ct_impulse_small', count=3, params={ }, inaccuracy=0.008, interval=0.1, },
    burst = { method=self.blast, type='ct_impulse_small', count=7, params={ }, inaccuracy=0.12, interval=0.0, },
    nade = { method=self.blast, type='ct_alta_impulse_nade', count=1, params={ }, inaccuracy=0.0, interval=0.0, flash=false, },
    projectile = { method=self.blast, type='rocketshell', count=1, params={ }, inaccuracy=0.12, interval=0.0, },
    explosion = { method=self.blast, type='ct_alta_impulse_nade', count=1, params={ timeToLive=0.0, speed=0, }, inaccuracy=0.0, interval=0.0, },
    discharge = { method=self.blast, type='ct_impulse_wave_blast', count=3, params={ }, inaccuracy=0.0, interval=0.3, },
    clouds = { method=self.blast, type='smallelectriccloud', count=8, params={ timeToLive=4.0, }, inaccuracy=3.14, interval=0.0, },
    thrower = { method=self.blast, type='flamethrower', count=1, params={ }, inaccuracy=0.05, interval=0.065, },
    beam = { method=self.blast, type='smallelectriccloud', count=8, params={ }, inaccuracy=3.14, interval=0.0, },
    tazer = { method=self.blast, type='shock', count=1, params={ speed=5 }, inaccuracy=0.0, interval=0.0, },
    field = { method=self.effect, }, effect = { method=self.effect, }, }
  self.pressType = self.pressType or 'none'
  self.pressParams = self.pressParams or { }
  if self.pressType then
    local pressParams = { }
    for k,v in pairs(self.actionPresets[self.pressType]) do pressParams[k] = v end
    for k,v in pairs(self.pressParams) do pressParams[k] = v end
    self.pressParams = pressParams
  end
  self.pressParams.sound = self.pressParams.sound or (self.abilitySlot .. '_press')
  self.holdType = self.holdType or 'none'
  self.holdParams = self.holdParams or { }
  if self.holdType then
    local holdParams = { }
    for k,v in pairs(self.actionPresets[self.holdType]) do holdParams[k] = v end
    for k,v in pairs(self.holdParams) do holdParams[k] = v end
    self.holdParams = holdParams
  end
  self.holdParams.sound = self.holdParams.sound or (self.abilitySlot .. '_hold')

  self.weapon.onLeaveAbility = function() self.weapon:setStance(self.stances.idle) end
  self.cooldownTimer = 0
  self.weapon:setStance(self.stances.idle)
end

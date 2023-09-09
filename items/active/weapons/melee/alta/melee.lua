---@diagnostic disable: undefined-global, lowercase-global
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/ct_alta_weapon.lua"

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
  self.comboSteps = #(self.stepConfig)
  self.comboStep = 1
  self.sessionStep = 1
  self.energyUsage = self.energyUsage or 0
  self.comboSpeedFactor = self.comboSpeedFactor or 1
  self:computeDamageAndCooldowns()
  self.cooldownTimer = self.cooldowns[1]
  self.edgeTriggerTimer = 0
  self.flashTimer = 0
  self.weapon:setStance(self.stances.idle)
  self.animKeyPrefix = self.animKeyPrefix or ""
  self.holdTimeMin = self.holdTimeMin or 0.45
  self.weapon.onLeaveAbility = function() self.weapon:setStance(self.stances.idle) end
end


-- Ticks on every update regardless if this is the active ability
function AltaCombo:update(dt, fireMode, shiftHeld)
  AltaAbil.update(self, dt, fireMode, shiftHeld)

  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
    if self.cooldownTimer == 0 then self:readyFlash() end
  end

  if self.flashTimer > 0 then
    self.flashTimer = math.max(0, self.flashTimer - self.dt)
    if self.flashTimer == 0 then animator.setGlobalTag("bladeDirectives", "") end
  end

  self.edgeTriggerTimer = math.max(0, (self.edgeTriggerTimer or 0) - self.dt)
  self.lastFireMode2 = self.lastFireMode
  if self.lastFireMode ~= (self.activatingFireMode or self.abilitySlot) and fireMode == (self.activatingFireMode or self.abilitySlot) then
    self.edgeTriggerTimer = self.edgeTriggerGrace
  end
  self.lastFireMode = fireMode

  if not self:shouldActivate() and self.loop and self.active then self:deactivate() end
  if self.weapon.currentAbility == nil and self:shouldActivate() then self:setState(self.switch) end
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
  else util.wait(stance.duration) end
  if self.energyUsage then status.overConsumeResource("energy", self.energyUsage) end
  if self.stances["preslash"..self.comboStep] then self:setState(self.preslash) else self:setState(self.fire) end
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

  local animStateKey = self.animKeyPrefix .. (self.stepConfig[self.comboStep].swoosh or (self.comboStep > 1 and "fire"..self.comboStep or "fire"))
  animator.setAnimationState("swoosh", animStateKey)
  animator.playSound(animStateKey)

  local swooshKey = self.animKeyPrefix .. (self.elementalType or self.weapon.elementalType) .. "swoosh"
  animator.setParticleEmitterOffsetRegion(swooshKey, self.stepConfig[self.comboStep].swooshOffsetRegion)
  animator.burstParticleEmitter(swooshKey)

  if self.comboStep < self.comboSteps then
    self.comboStep = self.comboStep + 1
  else
    self.cooldownTimer = self.cooldowns[self.comboStep]
    self.comboStep = 1
  end

  util.wait(stance.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.stepConfig[self.comboStep], damageArea)
  end)

  if self.comboStep ~= 1 then self:setState(self.wait) end
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
    if self.comboStep > 1 then return self.edgeTriggerTimer > 0 else return self:isActive() end
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
    self.stepConfig[i] = util.mergeTable(copy(self.damageConfig), self.stepConfig[i])
    self.stepConfig[i].timeoutGroup = "primary"..i

    local damageFactor = self.stepConfig[i].damageFactor
    self.stepConfig[i].baseDamage = damageFactor * self.baseDps * self.fireTime

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

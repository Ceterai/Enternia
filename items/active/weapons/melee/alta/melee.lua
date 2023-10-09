---@diagnostic disable: undefined-global, lowercase-global
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/scripts/versioningutils.lua"
require "/items/active/weapons/ct_alta_weapon.lua"

function init()
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.setGlobalTag("directives", "")
  animator.setGlobalTag("bladeDirectives", "")
  animator.playSound("init")

  self.weapon = Weapon:new()
  self.weapon.builder = "/items/buildscripts/ct_alta_item_builder.lua"
  self.weapon.isWrist = config.getParameter("isWrist", false)
  self.weapon:addAbility(getAbil(getDefaultPrimary(), "primary"))
  if config.getParameter("altAbility") then
    self.weapon:addAbility(getAbil(getDefaultAlt(), "alt"))
  end
  self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
  self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)
  self.weapon:init()
  if self.weapon.isWrist then updateHand() end
end

function getDefaultPrimary() return AltaCombo end
function getDefaultAlt() return AltaCombo end





--- ### Basic Melee
--- Basic melee ability utils.
AltaMelee = AltaUtils:new()

function AltaMelee:setDefaults()
  AltaUtils.setDefaults(self)
  self.damageConfig = util.mergeTable(
    {knockback=40,damageSourceKind="broadsword",knockbackMode="facing",timeoutGroup=self.abilitySlot,timeout=0.5}, copy(self.damageConfig or {})
  )
  self.pressParams = self.pressParams or {}
  self.sessionStep = 1
  self.sessionHit = 0
  activeItem.setInstanceValue('overallStep', config.getParameter('overallStep', 1))
  activeItem.setInstanceValue('overallHit', config.getParameter('overallHit', 0))
  self.holdTimeMax = self.holdTimeMax or 0.15
  self.holdTimeMin = self.holdTimeMax - 0.01
end

function AltaMelee:checkCounters()
  if self.sessionBonus then
    if self.sessionStep >= self.sessionBonus.steps then
      self.sessionHit = self.sessionBonus.hits or 1
      self.sessionStep = 0
    end
  end
  if self.overallBonus then
    if self.overallStep >= self.overallBonus.steps then
      activeItem.setInstanceValue('overallHit', self.overallBonus.hits or 1)
      activeItem.setInstanceValue('overallStep', 0)
    end
  end
end

function AltaMelee:increaseCounters()
  if self.sessionBonus then self.sessionStep = self.sessionStep + 1 end
  if self.overallBonus then activeItem.setInstanceValue('overallStep', config.getParameter('overallStep') + 1) end
end

function AltaMelee:fireBursts(damageConfig)
  function blast(cfg)
    if cfg.sound then animator.playSound(cfg.sound) end
    local params = self:getProjDamage(cfg.params or {}, cfg.count, cfg.itemBonus, nil, cfg.multi)
    for i = 1, (cfg.count or 1) do self:fireRanged(cfg.type, copy(params), self:firePos(cfg.offset or {0, 0}), nil, cfg.aim, cfg.inaccuracy) end
  end
  if damageConfig.ranged then blast(damageConfig.ranged) end
  local hit = config.getParameter('overallHit', 0)
  if self.sessionBonus and self.sessionBonus.burst and self.sessionHit > 0 then self.sessionHit = self.sessionHit - 1; blast(self.sessionBonus.burst) end
  if self.overallBonus and self.overallBonus.burst and hit > 0 then activeItem.setInstanceValue('overallHit', hit - 1); blast(self.overallBonus.burst) end
end

function AltaMelee:countHit(damageConfig) self:fireBursts(damageConfig); self:increaseCounters() end
function AltaMelee:firePos(offset) return vec2.add(mcontroller.position(), {offset[1] * self.weapon.aimDirection, offset[2]}) end
function AltaMelee:uninit() self.weapon:setDamage() end





--- ### Basic Combo
--- Basic melee combo ability.  
--- Each hit:
--- - increase combo counter
--- - increase overall hit counter per init
--- - increase overall hit counter
--- - decrease bonus counter
--- - check if need to fire projectiles
AltaCombo = AltaMelee:new()

function AltaCombo:setDefaults()
  self.steps = self.steps or {
    { damageFactor=1.0, energyFactor=0.0, knockback=10.0, swoosh="swoosh1", swooshOffsetRegion={0.75, 0.0, 4.25, 5.0} },
    { damageFactor=0.4, energyFactor=0.0, knockback=5.00, swoosh="swoosh2", swooshOffsetRegion={3.0, -0.5, 6.50, 2.0} },
    { damageFactor=1.1, energyFactor=0.0, knockback=25.0, swoosh="swoosh3", swooshOffsetRegion={1.5, -1.0, 5.50, 1.0} },
  }
  self.stances = util.mergeTable({
    idle={ armRotation=-75, weaponRotation=-10, twoHanded=true, allowRotate=true, allowFlip=true },
    windup1={ duration=0.25, armRotation=90, weaponRotation=-10, twoHanded=true, allowRotate=true, allowFlip=true },
    preslash1={ duration=0.05, armRotation=55, weaponRotation=-45, twoHanded=true, allowRotate=false, allowFlip=false },
    fire1={ duration=0.25, armRotation=-45, weaponRotation=-55, twoHanded=true, allowRotate=false, allowFlip=false },
    wait1={ duration=0.2, armRotation=-45, weaponRotation=-55, allowRotate=true, allowFlip=true, twoHanded=true },
    windup2={ duration=0.25, armRotation=-15, weaponRotation=-60, weaponOffset={0, 1.1}, twoHanded=true, allowFlip=true, allowRotate=true },
    fire2={ duration=0.3, armRotation=-150, weaponRotation=55, weaponOffset={0, 1.1}, twoHanded=true, allowFlip=true, allowRotate=false },
    wait2={ duration=0.2, armRotation=-150, weaponRotation=55, weaponOffset={0, 1.1}, allowRotate=true, allowFlip=true, twoHanded=true },
    windup3={ duration=0.25, armRotation=-150, weaponRotation=55, twoHanded=true, allowRotate=true, allowFlip=true },
    fire3={ duration=0.2, armRotation=0, weaponRotation=-90, twoHanded=true, allowRotate=false, allowFlip=true },
  }, self.stances or {})
  AltaMelee.setDefaults(self)
  self.pressParams.flash = self.pressParams.flash or {}
  self.pressParams.flash.time = self.pressParams.flash.time or 0.15
  self.pressParams.flash.directives = self.pressParams.flash.directives or "fade=FFFFFFFF=0.15"
  self.pressParams.comboSpeedFactor = self.pressParams.comboSpeedFactor or 0.6  -- 0.9
  self.pressParams.edgeTriggerGrace = self.pressParams.edgeTriggerGrace or 0.25
  self:computeDamageAndCooldowns()
  self.cooldownTimer = self.cooldowns[1]
  self.waitTimer = 0
  self.flashTimer = 0
  self.comboStep = 1
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
  self.waitTimer = math.max(0, (self.waitTimer or 0) - self.dt)
  if not self:isOn(self.lastFireMode) and self:isOn() then self.waitTimer = self.pressParams.edgeTriggerGrace end
  self.lastFireMode = fireMode
  self:trySwitch(not self.weapon.currentAbility and self.cooldownTimer == 0)
end

-- State: **windup** - activated on **press** or during **wait** state.
function AltaCombo:press()
  local stance = self.stances["windup"..self.comboStep]
  self.weapon:setStance(stance)
  self.waitTimer = 0
  if stance.hold then while self:isOn() do coroutine.yield() end else util.wait(stance.duration) end
  self:drainEnergy(self.steps[self.comboStep])
  if self.stances["preslash"..self.comboStep] then self:setState(self.preslash) else self:setState(self.fire) end
end

-- State: **preslash** - brief frame in between **windup** and **fire**.
function AltaCombo:preslash()
  local stance = self.stances["preslash"..self.comboStep]
  self.weapon:setStance(stance)
  self.weapon:updateAim()
  util.wait(stance.duration)
  self:setState(self.fire)
end

-- State: **fire**
function AltaCombo:fire()
  local stance = self.stances["fire"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  animator.setAnimationState("swoosh", self.steps[self.comboStep].swoosh)
  animator.playSound(self.steps[self.comboStep].swooshSound or (self.abilitySlot..'_press'))
  local swooshKey = (self.steps[self.comboStep].element or self.weapon.elementalType).."swoosh"
  animator.setParticleEmitterOffsetRegion(swooshKey, self.steps[self.comboStep].swooshOffset)
  animator.burstParticleEmitter(swooshKey)

  self:countHit(self.steps[self.comboStep])
  util.wait(stance.duration, function() self:fireMelee(self.steps[self.comboStep]) end)
  self:switchElements()
  if self.comboStep < #self.steps then
    self.comboStep = self.comboStep + 1
    self:setState(self.wait)
  else
    self.comboStep = 1
    self.cooldownTimer = self.cooldowns[self.comboStep]
  end
end

-- State: **wait** - waiting for next combo input
function AltaCombo:wait()
  local stance = self.stances["wait"..(self.comboStep - 1)]
  self.weapon:setStance(stance)
  util.wait(stance.duration, function() if self:canFire() then self:setState(self.press); return end end)
  self.cooldownTimer = math.max(0, self.cooldowns[self.comboStep - 1] - stance.duration)
  self.comboStep = 1
end

function AltaCombo:readyFlash()
  animator.setGlobalTag("bladeDirectives", self.pressParams.flash.directives)
  self.flashTimer = self.pressParams.flash.time
end

function AltaCombo:switchElements()
  if self.switchElementConfig then
    local cfg = self.switchElementConfig[config.getParameter('elementSwitchIndex', 0) + 1] or self.switchElementConfig[1]
    self.weapon.elementalType = cfg.element
    self.elementalType = cfg.element
    activeItem.setInstanceValue('elementalType', cfg.element)
    animator.setPartTag('blade', 'partImage', cfg.sprite)
    activeItem.setInstanceValue('inventoryIcon', cfg.sprite)
    activeItem.setInstanceValue('animationParts', { handle="", blade=cfg.sprite })
    activeItem.setInstanceValue('elementSwitchIndex', (({1, 2, 3})[config.getParameter('elementSwitchIndex', 0) + 1] or 1))
    activeItem.setInventoryIcon(cfg.sprite)
  end
end

function AltaCombo:computeDamageAndCooldowns()
  self.cooldowns = {}
  local totalAttackTime = 0
  local totalDamageFactor = 0
  for i = 1, #self.steps do
    local damageFactor = self.steps[i].damageFactor
    local attackTime = self.stances["windup"..i].duration + self.stances["fire"..i].duration
    if self.stances["preslash"..i] then attackTime = attackTime + self.stances["preslash"..i].duration end
    totalAttackTime = totalAttackTime + attackTime
    totalDamageFactor = totalDamageFactor + damageFactor
    self.steps[i] = util.mergeTable(copy(self.damageConfig), self.steps[i])
    self.steps[i].timeoutGroup = self.abilitySlot..i
    self.steps[i].baseDamage = self:getDamage(damageFactor * self.baseDps * self.fireTime)
    table.insert(self.cooldowns, ((totalDamageFactor * self.fireTime) - totalAttackTime) * (self.pressParams.comboSpeedFactor ^ i))
  end
end

function AltaCombo:canFire()if self:canDrainEnergy(self.steps[self.comboStep])then if self.comboStep>1 then return self.waitTimer>0 else return self:isOn()end end end

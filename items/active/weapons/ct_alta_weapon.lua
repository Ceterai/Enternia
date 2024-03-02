---@diagnostic disable: undefined-global, lowercase-global
require "/items/active/weapons/weapon.lua"


function init()
  activeItem.setCursor("/cursors/reticle0.cursor")
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.playSound("init")

  self.weapon = Weapon:new()
  self.weapon.builder = "/items/buildscripts/alta/item.lua"
  self.weapon.isWrist = config.getParameter("isWrist", false)
  self.weapon:addAbility(getAbil(getDefaultPrimary(), "primary"))
  if config.getParameter("altAbility") then
    self.weapon:addAbility(getAbil(getDefaultAlt(), "alt"))
  end
  self.weapon:addTransformationGroup("weapon", {0,0}, 0)
  self.weapon:addTransformationGroup("muzzle", self.weapon.muzzleOffset, 0)
  self.weapon:init()
  if self.weapon.isWrist then updateHand() end
end

function getAbil(class, slot, cfg)
  if not cfg then cfg = config.getParameter(slot .. "Ability") end
  for _, script in ipairs(cfg.scripts or {}) do require(script) end
  if cfg.class then class = _ENV[cfg.class] end
  cfg.abilitySlot = slot
  return class:new(cfg)
end

function getDefaultPrimary() return AltaAbil end
function getDefaultAlt() return AltaAbil end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
  if self.weapon.isWrist then updateHand() end
end

function updateHand()
  local isFrontHand = (activeItem.hand() == "primary") == (mcontroller.facingDirection() < 0)
  -- animator.setGlobalTag("hand", isFrontHand and "front" or "back")
  activeItem.setOutsideOfHand(isFrontHand)
end





--- ### Basic Alta Abil
--- Basic alta weapon/tool ability.
AltaAbil = WeaponAbility:new()
function AltaAbil:init() self.stances = self.stances or {}; self:setDefaults() end
function AltaAbil:isOn(mode) return (mode or self.fireMode) == (self.activatingFireMode or self.abilitySlot) end
function AltaAbil:setDefaults()
  self.weapon.onLeaveAbility = function() self.weapon:setStance(self.stances.idle or {}) end
  self.weapon.onLeaveAbility()
end
function AltaAbil:debug() sb.logInfo("DEBUG: Ability '%s':\n- weapon: %s", self.name, self.weapon) end
function AltaAbil:uninit() end





--- ### Item Bonus
--- Basic util ability. Provides accounting for bonuses from having a certain amount of an item in inventory.  
--- To work, an according `damageConfig` object should have an `itemBonus` object with either `damageFactor` or `energyFactor` in it.  
--- Other params (`maxItems`, `minItems`, `actualMinItems`) are optional. Factor is how much percent is added (for damage) or removed(for energy, min 0) per item.
AltaBonusUtils = AltaAbil:new()

function AltaBonusUtils:getItemDamageBonus(cfg)
  if not cfg or not cfg.damageFactor then return 1.0 end
  return 1.0 + (cfg.damageFactor * self:getItemCount(cfg.type, cfg.max, cfg.min, cfg.actualMin))
end

function AltaBonusUtils:getItemEnergyBonus(cfg)
  if not cfg or not cfg.energyFactor then return 1.0 end
  return math.max(1.0 - (cfg.energyFactor * self:getItemCount(cfg.type, cfg.max, cfg.min, cfg.actualMin)), 0)
end

function AltaBonusUtils:getItemCount(uid, maxItems, minItems, actualMinItems)
  local count = player.hasCountOfItem(uid)
  if count <= (minItems or 0) then return 0 end
  return math.max(actualMinItems or minItems or 0, math.min(count, maxItems or 9999999))
end

--- ### Energy Utils
--- Basic util ability. Provides methods of calculating base energy (`getEnergy`) and final energy (`getEnergyFinal`) as well as usage (`consumeEnergy`).
AltaEnergyUtils = AltaBonusUtils:new()

function AltaEnergyUtils:getEnergy(baseEnergy, count, customBonus)
  return (baseEnergy or self.baseEnergy or ((self.energyUsage or 0) * (self.fireTime or 1.0))) *
  (((self.holdTime or 0.0) + 1.0) * 0.5) * (self.energyUsageMultiplier or 1.0) * (customBonus or 1.0) / (count or 1)
end

function AltaEnergyUtils:getEnergyFinal(cfg) return self:getEnergy(cfg.energyUsage, nil, cfg.energyFactor) * self:getItemEnergyBonus(cfg.itemBonus) end
function AltaEnergyUtils:tryConsumeEnergyFinal(energy) if energy > 0 then return status.overConsumeResource('energy', energy) else return true end end
function AltaEnergyUtils:drainEnergy(cfg) return self:tryConsumeEnergyFinal(self:getEnergyFinal(cfg or {})) end
function AltaEnergyUtils:canDrainEnergy(cfg) return (self:getEnergyFinal(cfg or {}) == 0) or not status.resourceLocked('energy') end

--- ### Damage Utils
--- Basic util ability. Provides methods of calculating base damage. Provides basic methods of inflicting damage (melee and ranged).
AltaAttackUtils = AltaEnergyUtils:new()

function AltaAttackUtils:getDamage(baseDamage, count, customBonus)
  return (baseDamage or self.baseDamage or (self.baseDps * self.fireTime)) * ((self.holdTime or 0.0) + 1.0) *
  (self.baseDamageMultiplier or 1.0) * (customBonus or 1.0) * (self.weapon.stabilizerBonus or config.getParameter('stabilizerBonus', 1.0)) / (count or 1)
end

function AltaAttackUtils:getProjDamage(params, count, itemBonus, customDamage, customBonus)
  params.power = self:getDamage(customDamage, count, customBonus) * self:getItemDamageBonus(itemBonus) * self.weapon.damageLevelMultiplier
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  return params
end

function AltaAttackUtils:fireMelee(cfg, area, damage)
  local damageConfig = cfg or self.damageConfig
  damageConfig.baseDamage = (damageConfig.baseDamage or self:getDamage(damage, cfg.count, cfg.damageFactor)) * self:getItemDamageBonus(cfg.itemBonus)
  self.weapon:setDamage(damageConfig, partDamageArea(area or 'swoosh'))
  return damageConfig
end

function AltaAttackUtils:fireRanged(bolt, params, pos, offset, aim, range)
  if params.speed then params.speed = util.randomInRange(params.speed) end
  if params.timeToLive then params.timeToLive = util.randomInRange(params.timeToLive) end
  if type(bolt) == "table" then bolt = util.randomChoice(bolt) end
  return world.spawnProjectile(bolt, pos or self:firePos(offset), activeItem.ownerEntityId(), aim or self:fireVector(range), false, params)
end

function AltaAttackUtils:firePos(offset) return vec2.add(mcontroller.position(), activeItem.handPosition({offset[1], offset[2] + 0.2})) end

function AltaAttackUtils:fireVector(range)
  local aim = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(range or 0, 0))
  return {aim[1] * mcontroller.facingDirection(), aim[2]}
end





--- ### Press & Hold
--- Weapon/tool ability. Does different things on `press` and on `hold`.  
--- Set `self.holdTimeMax` to 0 to only use the `press` method.
AltaUtils = AltaAttackUtils:new()

function AltaUtils:update(dt, fireMode, shiftHeld) AltaAttackUtils.update(self, dt, fireMode, shiftHeld); self:trySwitch(true) end

function AltaUtils:switch()
  while self:isOn() do
    self.holdTime = self.holdTime + self.dt
    if self.holdTime > self.holdTimeMin and not self.active then self:activate() end
    if self.holdTime >= self.holdTimeMax then break end
    coroutine.yield()
  end
  if not self.loop and self.active then self:deactivate() end
  if self.holdTime > 0 then
    if self.holdTime >= self.holdTimeMax and self.holdTimeMax > self.holdTimeMin then
      self:setState(self.hold)
      self.holdTime = 0 - self.pressCooldown - self.holdCooldown
    else
      if self.holdTime <= self.holdTimeMin then self:setState(self.press) end
      self.holdTime = 0 - self.pressCooldown
    end
  end
end

function AltaUtils:activate()
  self.active = true
  animator.playSound(self.abilitySlot .. "_start")
  animator.playSound(self.abilitySlot .. "_loop", -1)
end

function AltaUtils:deactivate()
  self.active = false
  animator.stopAllSounds(self.abilitySlot .. "_start")
  animator.stopAllSounds(self.abilitySlot .. "_loop")
  animator.playSound(self.abilitySlot .. "_end")
end

function AltaUtils:press() end  -- define custom logic
function AltaUtils:hold() end  -- define custom logic
function AltaUtils:canFire() return self:isOn() end
function AltaUtils:trySwitch(custom)
  if not self:canFire() and self.loop and self.active then self:deactivate() end
  if self:canFire() and custom then self:setState(self.switch) end
end

function AltaUtils:setDefaults()
  AltaAttackUtils.setDefaults(self)
  self.holdTimeMin = self.holdTimeMin or 0.25
  self.holdTimeMax = self.holdTimeMax or 0.75
  self.holdCooldown = self.holdCooldown or 0.15
  self.pressCooldown = 0
  self.holdTime = 0
  self.active = false
  self.loop = self.loop or false
end

---@diagnostic disable: undefined-global, lowercase-global
require "/items/active/weapons/weapon.lua"

function init()
  activeItem.setCursor("/cursors/reticle0.cursor")
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.playSound("init")

  self.weapon = Weapon:new()
  self.weapon.builder = "/items/buildscripts/ct_alta_item_builder.lua"
  self.weapon.isWrist = config.getParameter("isWrist", false)
  self.weapon:addAbility(getAbil(AltaAbil, "primary"))
  if config.getParameter("altAbility") then
    self.weapon:addAbility(getAbil(AltaAbil, "alt"))
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

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
  if self.weapon.isWrist then updateHand() end
end

function updateHand()
  local isFrontHand = (activeItem.hand() == "primary") == (mcontroller.facingDirection() < 0)
  -- animator.setGlobalTag("hand", isFrontHand and "front" or "back")
  activeItem.setOutsideOfHand(isFrontHand)
end












--- ### Basic Alta Ranged Abil
--- Basic ranged ability.
AltaAbil = WeaponAbility:new()

function AltaAbil:init()
  self:debug()
  self:setDefaults()
end

function AltaAbil:isActive()
  return self.fireMode == (self.activatingFireMode or self.abilitySlot)
end

function AltaAbil:setDefaults()
  self.name = self.name or 'Alta Ability'
end

function AltaAbil:debug()
  -- sb.logInfo("DEBUG: Ability '%s':\n- weapon: %s\n- params: %s", self.name, self.weapon, self) -- can cause crashes
end

function AltaAbil:uninit()
end












--- ### Basic Utils
--- Basic util ability. Does different things on `press` and on `hold`.  
--- Set `self.holdTimeMax` to 0 to only use the `press` method.
AltaUtils = AltaAbil:new()

function AltaUtils:update(dt, fireMode, shiftHeld)
  AltaAbil.update(self, dt, fireMode, shiftHeld)
  if not self:isActive() and self.loop and self.active then self:deactivate() end
  if self:isActive() then self:setState(self.switch) end
end

function AltaUtils:switch()
  while self:isActive() do
    self.holdTime = self.holdTime + self.dt
    if self.holdTime > self.holdTimeMin and not self.active then self:activate() end
    if self.holdTime >= self.holdTimeMax then break end
    coroutine.yield()
  end
  if not self.loop and self.active then self:deactivate() end
  if self.holdTime > 0 then
    if self.holdTime <= self.holdTimeMin then
      self:setState(self.press)
      self.holdTime = 0 - self.pressCooldown
    elseif self.holdTime >= self.holdTimeMax then
      self:setState(self.hold)
      self.holdTime = 0 - self.pressCooldown - self.holdCooldown
    else
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

function AltaUtils:press()
  -- define custom logic
end

function AltaUtils:hold()
  -- define custom logic
end

function AltaUtils:setDefaults()
  self.name = self.name or 'Alta Util Ability'
  self.holdTimeMin = self.holdTimeMin or 0.25
  self.holdTimeMax = self.holdTimeMax or 0.75
  self.holdCooldown = self.holdCooldown or 0.15
  self.pressCooldown = 0
  self.holdTime = 0
  self.active = false
  self.loop = self.loop or false
end

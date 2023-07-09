---@diagnostic disable: undefined-global, lowercase-global
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/ct_alta_weapon.lua"
require "/items/active/weapons/ranged/gun.lua"
require "/items/active/weapons/ranged/gunfire.lua"
require "/items/active/weapons/ranged/beamfire.lua"

function init()
  activeItem.setCursor("/cursors/reticle0.cursor")
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.playSound("init")

  self.weapon = Weapon:new()
  self.weapon.builder = "/items/buildscripts/ct_alta_item_builder.lua"
  self.weapon.isWrist = config.getParameter("isWrist", false)
  self.weapon:addAbility(getAbil(AltaRanged, "primary"))
  if config.getParameter("altAbility") then
    self.weapon:addAbility(getAbil(AltaRanged, "alt"))
  end
  self.weapon:addTransformationGroup("weapon", {0,0}, 0)
  self.weapon:addTransformationGroup("muzzle", self.weapon.muzzleOffset, 0)
  self.weapon:init()
  if self.weapon.isWrist then updateHand() end
end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
  if self.weapon.isWrist then updateHand() end
end












--- ### Basic Blast
--- Basic "switch" ability. On press iterates over a list of attachments.  
--- Supported attachments: `none`, `flashlight`, `lazer` and `stabilizer`. Any other keyword will be treated as `none`.
AltaRanged = AltaUtils:new()

function AltaRanged:update(dt, fireMode, shiftHeld)
  AltaAbil.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  self:muzzleFlashOff()
  if (not self:isActive()
  or status.resourceLocked("energy")
  or world.lineTileCollision(mcontroller.position(), self:firePosition())) and self.loop and self.active then self:deactivate() end
  if self:canFire() then self:setState(self.switch) end
end

function AltaRanged:press()
  self.pressParams.method(self, self.pressParams)
end

function AltaRanged:hold()
  self.holdParams.method(self, self.holdParams)
end

function AltaRanged:none(params)
end

function AltaRanged:blast(params)
  if status.overConsumeResource("energy", self:energyPerShot()) then
    self.weapon:setStance(self.stances.fire)
    local firedIDs = self:fireProjectile(params)
    self.cooldownTimer = self.fireTime
    self:setState(self.cooldown)
    return firedIDs
  end
end

function AltaRanged:effect(params)
end

function AltaRanged:fireProjectile(cfg, firePos)
  local projectileIDs = {}
  local bolt = cfg.type
  local params = cfg.params or {}
  params.power = self:damagePerShot(cfg.count, cfg.multi)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  if params.speed then params.speed = util.randomInRange(params.speed) end
  if cfg.interval == 0 then self:muzzleFlash(cfg.sound, cfg.flash) end
  if type(cfg.type) == "table" then bolt = util.randomChoice(cfg.type) end
  for i = 1, (cfg.count or 1) do
    if cfg.interval ~= 0 then self:muzzleFlash(cfg.sound, cfg.flash) end
    if params.timeToLive ~= nil then params.timeToLive = util.randomInRange(params.timeToLive) end
    local vector = self:aimVector(cfg.inaccuracy)
    local pos = self:firePosition(firePos or cfg.pos)
    table.insert(projectileIDs, world.spawnProjectile( bolt, pos, activeItem.ownerEntityId(), vector, false, params ))
    util.wait(cfg.interval or 0)
  end
  return projectileIDs
end

function AltaRanged:firePosition(firePos)
  return firePos or vec2.add(mcontroller.position(), activeItem.handPosition({self.weapon.muzzleOffset[1], self.weapon.muzzleOffset[2] + 0.2}))
end

function AltaRanged:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy or 0, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function AltaRanged:energyPerShot()
  return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0)
end

function AltaRanged:damagePerShot(count, multi)
  return (self.baseDamage or (self.baseDps * self.fireTime)) * (self.baseDamageMultiplier or 1.0) * (multi or 1.0) * (self.holdTime + 1.0) *
  config.getParameter("damageLevelMultiplier") * config.getParameter('stabilizerBonus', 1.0) * (self.weapon.stabilizerBonus or 1.0) / (count or 1)
end

function AltaRanged:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()
  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}
    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))
    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
  self.weapon:setStance(self.stances.idle)
end

function AltaRanged:canFire()
  return self:isActive()
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
end

function AltaRanged:muzzleFlash(sound, flash)
  if not (flash == false) then
    animator.setPartTag("muzzleFlash", "variant", math.random(1, self.muzzleFlashVariants or 3))
    animator.burstParticleEmitter("muzzleFlash")
    animator.setLightActive("muzzleFlash", true)
  end
  animator.setAnimationState("firing", "fire")
  animator.playSound(sound or 'press')
end

function AltaRanged:muzzleFlashOff()
  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end
end

function AltaRanged:setDefaults()
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

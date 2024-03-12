---@diagnostic disable: undefined-global, lowercase-global
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/ranged/gun.lua"
require "/items/active/weapons/ranged/gunfire.lua"
require "/items/active/weapons/ranged/beamfire.lua"
require "/items/active/weapons/ct_alta_weapon.lua"


function getDefaultPrimary() return AltaRanged end
function getDefaultAlt() return AltaRanged end


--- ### Basic Blast
--- Basic "switch" ability. Launches different projectiles with different params on `press` and `hold` of the button.
AltaRanged = AltaUtils:new()
function AltaRanged:press() self.pressParams.method(self, self.pressParams) end
function AltaRanged:hold() self.holdParams.method(self, self.holdParams) end
function AltaRanged:effect(cfg) end
function AltaRanged:muzzleFlashOff() if animator.animationState("firing") ~= "fire" then animator.setLightActive("muzzleFlash", false) end end
function AltaRanged:canFire() return self:isOn() and self:canDrainEnergy() and not world.lineTileCollision(mcontroller.position(), self:firePos(self.weapon.muzzleOffset)) end

function AltaRanged:update(dt, fireMode, shiftHeld)
  AltaAbil.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  self:muzzleFlashOff()
  self:trySwitch(not self.weapon.currentAbility and self.cooldownTimer == 0)
end

function AltaRanged:blast(cfg)
  if self:drainEnergy() then
    self.weapon:setStance(self.stances.fire)
    self:fireProjs(cfg, nil, cfg.offset or self.weapon.muzzleOffset, {})
    self:setState(self.cooldown)
  end
end

function AltaRanged:fireProjs(cfg, pos, offset, fireIDs, damage)
  self.fireTime = cfg.fireTime or self.defaultFireTime
  local params = self:getProjDamage(cfg.params or {}, cfg.count, cfg.itemBonus, damage, cfg.multi)
  for i = 1, (cfg.count or 1) do
    if i == 1 or cfg.interval ~= 0 then self:muzzleFlash(cfg.sound, cfg.flash) end
    table.insert(fireIDs, self:fireRanged(cfg.type, copy(params), pos, offset, cfg.aim, cfg.inaccuracy))
    util.wait(cfg.interval or 0)
  end
  return fireIDs
end

function AltaRanged:muzzleFlash(sound, flash)
  if not (flash == false) then
    animator.setPartTag("muzzleFlash", "variant", math.random(1, self.muzzleFlashVariants or 3))
    animator.burstParticleEmitter("muzzleFlash")
    animator.setLightActive("muzzleFlash", true)
  end
  animator.setAnimationState("firing", "fire")
  animator.playSound(sound or self.abilitySlot..'_press')
end

function AltaRanged:cooldown(cfg)
  self.cooldownTimer = self.fireTime
  self.weapon:setStance(self.stances.winddown)
  self.weapon:updateAim()
  local progress = 0
  util.wait(self.stances.winddown.duration, function()
    local from = self.stances.winddown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}
    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.winddown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.winddown.armRotation, self.stances.idle.armRotation))
    progress = math.min(1.0, progress + (self.dt / self.stances.winddown.duration))
  end)
  self.weapon:setStance(self.stances.idle)
end

function AltaRanged:setDefaults()
  self.stances.idle = self.stances.idle or {armRotation=0, weaponRotation=0, twoHanded=true, allowRotate=true, allowFlip=true,}
  self.stances.fire = self.stances.fire or {armRotation=3, weaponRotation=3, twoHanded=true, duration=0, allowRotate=false, allowFlip=true,}
  self.stances.winddown = self.stances.winddown or {armRotation=3, weaponRotation=3, twoHanded=true, duration=0.1, allowRotate=false, allowFlip=true,}
  AltaUtils.setDefaults(self)
  self.actionPresets = {
    none = { method=function(any, cfg)end, }, field = { method=self.effect, }, effect = { method=self.effect, },
    blast = { method=self.blast, type='ct_plasma_medium', count=1, params={ }, inaccuracy=0.04, interval=0.0, },
    rocket = { method=self.blast, type='rocketshell', count=1, params={ knockback=40, }, inaccuracy=0.0, interval=0.0, },
    snipe = { method=self.blast, type='ct_plasma_large', count=1, params={ knockback=40, }, inaccuracy=0.008, interval=0.0, },
    semi = { method=self.blast, type='ct_impulse_small', count=3, params={ }, inaccuracy=0.008, interval=0.1, },
    burst = { method=self.blast, type='ct_impulse_small', count=7, params={ }, inaccuracy=0.12, interval=0.0, },
    nade = { method=self.blast, type='ct_impulse_nade_charge', count=1, params={ }, inaccuracy=0.0, interval=0.0, flash=false, },
    projectile = { method=self.blast, type='rocketshell', count=1, params={ }, inaccuracy=0.12, interval=0.0, },
    explosion = { method=self.blast, type='ct_impulse_nade_charge', count=1, params={ timeToLive=0.0, speed=0, }, inaccuracy=0.0, interval=0.0, },
    discharge = { method=self.blast, type='ct_impulse_wave_blast', count=3, params={ }, inaccuracy=0.0, interval=0.3, },
    clouds = { method=self.blast, type='smallelectriccloud', count=8, params={ timeToLive=4.0, }, inaccuracy=3.14, interval=0.0, },
    thrower = { method=self.blast, type='flamethrower', count=1, params={ }, inaccuracy=0.05, interval=0.065, },
    beam = { method=self.blast, type='smallelectriccloud', count=8, params={ }, inaccuracy=3.14, interval=0.0, },
    tazer = { method=self.blast, type='shock', count=1, params={ speed=5 }, inaccuracy=0.0, interval=0.0, }, }
  self.pressParams = util.mergeTable(copy(self.actionPresets[self.pressType or 'none']), self.pressParams or {})
  self.pressParams.sound = self.pressParams.sound or (self.abilitySlot..'_press')
  self.holdParams = util.mergeTable(copy(self.actionPresets[self.holdType or 'none']), self.holdParams or {})
  self.holdParams.sound = self.holdParams.sound or (self.abilitySlot..'_hold')
  self.defaultFireTime = self.defaultFireTime or self.fireTime
  self.cooldownTimer = 0
end

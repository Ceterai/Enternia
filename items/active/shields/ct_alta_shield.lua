---@diagnostic disable: lowercase-global, undefined-global
require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/shields/shield.lua"

shield_init = init
shield_uninit = uninit
shield_raiseShield = raiseShield
shield_update = update

function init()
  shield_init()
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.playSound("init")
  self.effects = config.getParameter("statusEffects")
  self.raisedEffects = config.getParameter("raisedStatusEffects")
  self.raisedFire = config.getParameter("raisedFire")
  self.chargeFire = config.getParameter("chargeFire")
  self.chargeFired = false
  self.knockbackEffects = config.getParameter("knockbackStatusEffects")
  if self.effects then
    status.setPersistentEffects(activeItem.hand().."ShieldPassive", self.effects)
  end
end

function update(dt, fireMode, shiftHeld)
  shield_update(dt, fireMode, shiftHeld)
  if self.chargeFire and self.active and self.activeTimer > (self.chargeFire.holdTime or 1.55) and not self.chargeFired then
    self.chargeFired = true
    animator.stopAllSounds("charge_loop")
    animator.playSound("charge_end")
    fireBolts(self.chargeFire)
  end
  if self.chargeFire and not self.active and not self.chargeFired then
    animator.stopAllSounds("charge_loop")
  end
end

function uninit()
  shield_uninit()
  if self.effects then
    status.clearPersistentEffects(activeItem.hand().."ShieldPassive", self.effects)
  end
end

function raiseShield()
  shield_raiseShield()
  if self.knockback > 0 or self.knockbackEffects then
    activeItem.setItemDamageSources({ {
      poly = animator.partPoly("shield", "shieldPoly"),
      damage = 0,
      damageType = "Knockback",
      sourceEntity = activeItem.ownerEntityId(),
      team = activeItem.ownerTeam(),
      knockback = self.knockback or 0,
      statusEffcts = self.knockbackEffects,
      rayCheck = true,
      damageRepeatTimeout = 0.25
    } })
  end
  if self.raisedEffects then
    status.addPersistentEffects(activeItem.hand().."Shield", self.raisedEffects)
  end
  if self.raisedFire then
    fireBolts(self.raisedFire)
  end
  if self.chargeFire then
    animator.playSound("charge_loop", -1)
    self.chargeFired = true
  end
  self.chargeFired = false
end

function fireBolts(proj)
  local position = vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("shield", "projectileSource")))
  local inaccuracy = proj.inaccuracy or 0.3
  local aim = 0
  for i=1,(proj.count or 1) do
    aim = self.aimAngle + util.randomInRange({-inaccuracy, inaccuracy})
    world.spawnProjectile(
      proj.type, position, activeItem.ownerEntityId(), {mcontroller.facingDirection() * math.cos(aim), math.sin(aim)}, false, proj.params
    )
  end
end

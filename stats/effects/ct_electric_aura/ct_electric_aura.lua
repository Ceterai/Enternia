require "/scripts/util.lua"
require "/scripts/status.lua"

function init()
  if config.getParameter("animateAura", false) then setUpAnimation() end
  script.setUpdateDelta(5)

  self.power = 0
  self.range = config.getParameter("jumpDistance", 10)
  self.bolt = config.getParameter("projectile", "teslaboltsmall")

  self.tickTime = config.getParameter("boltInterval", 1.0)
  self.tickTimer = self.tickTime
  self.active = true

  self.electricResistance = config.getParameter("electricResistanceModifier", 0.0)
  effect.addStatModifierGroup({{stat = "electricResistance", effectiveMultiplier = self.electricResistance}})
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 and self.active then
    setUpDamage()
    local targetIds = world.entityQuery(mcontroller.position(), self.range, {
      withoutEntityId = entity.id(),
      includedTypes = {"creature"}
    } )

    shuffle(targetIds)

    for i,id in ipairs(targetIds) do
      local sourceEntityId = effect.sourceEntity() or entity.id()
      if world.entityCanDamage(sourceEntityId, id) and world.entityAggressive(id) and not world.lineTileCollision(mcontroller.position(), world.entityPosition(id)) then
        local sourceDamageTeam = world.entityDamageTeam(sourceEntityId)
        local directionTo = world.distance(world.entityPosition(id), mcontroller.position())
        world.spawnProjectile( self.bolt, mcontroller.position(), entity.id(), directionTo, false, {
          power = self.power,
          damageTeam = sourceDamageTeam
        } )
        animator.playSound("bolt")
        return
      end
    end
  end
  if self.tickTimer <= 0 then
    updateTickTime()
  end
end

function setUpAnimation()
  animator.setAnimationState("aura", "windup")
  animator.setParticleEmitterOffsetRegion("sparks", mcontroller.boundBox())
  animator.setParticleEmitterActive("sparks", true)
  -- effect.setParentDirectives("fade=7733AA=0.25")
end

function updateTickTime()
  if self.tickTime <= 0 then
    local healthCoef = status.resourcePercentage("health")
    if healthCoef > 0.5 then
      self.active = false
    else
      self.active = true
    end
    self.tickTimer = math.max(healthCoef * 2, 0.25)
  else
    self.tickTimer = self.tickTime
  end
end

function setUpDamage()
  local dmg = config.getParameter("damageBase", 0.0)

  local dmgFromHealth = config.getParameter("damageFromMaxHealth", false)
  if dmgFromHealth then
    local dmgFromHealthBase = status.resourceMax("health")
    local dmgFromHealthMod = config.getParameter("damageFromMaxHealthPercent", 0.05)
    dmg = dmg + (dmgFromHealthBase * dmgFromHealthMod)
  end

  local dmgFromEnergy = config.getParameter("damageFromMaxEnergy", false)
  if dmgFromEnergy then
    local dmgFromEnergyBase = status.stat("maxEnergy")
    local dmgFromEnergyMod = config.getParameter("damageFromMaxEnergyPercent", 0.05)
    dmg = dmg + (dmgFromEnergyBase * dmgFromEnergyMod)
  end

  local overall = config.getParameter("damageOverallModifier", 1.0)
  dmg = dmg * overall

  local dmgClamp = config.getParameter("damageClamp", false)
  if dmgClamp then
    local dmgClampRange = config.getParameter("damageClampRange", {2, 20})
    dmg = util.clamp(dmg, dmgClampRange[1], dmgClampRange[2])
  end

  self.power = math.abs(dmg)
end

function uninit()

end

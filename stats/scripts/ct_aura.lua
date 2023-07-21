require "/scripts/util.lua"
require "/scripts/status.lua"
require "/stats/scripts/ct_animation.lua"


function init()
  self.playSound = config.getParameter("playSound", true)
  script.setUpdateDelta(5)

  self.power = 0
  self.range = config.getParameter("jumpDistance", 10)
  self.bolt = config.getParameter("projectile", "teslaboltsmall")
  self.projectileConfig = config.getParameter("projectileParams", {})
  self.statusEffects = config.getParameter("statusEffects", nil)
  self.speed = config.getParameter("speed", nil)

  self.healthCoef = config.getParameter("healthCoef")
  self.tickTime = config.getParameter("boltInterval", 1.0)
  self.dependant = (self.tickTime <= 0 or self.tickTime == nil or self.healthCoef ~= nil) -- if using the scale tickTime
  self.healthCoef = self.healthCoef or 0.5
  if not self.dependant then activate() end
  resetTickTimer()

  self.electricResistance = config.getParameter("electricResistanceModifier", 0.0)
  effect.addStatModifierGroup({{stat = "electricResistance", effectiveMultiplier = self.electricResistance}})
end

function update(dt)
  self.tickTimer = math.max(self.tickTimer - dt, 0)
  if self.tickTimer <= 0 and self.active then fire() end
  if self.tickTimer <= 0 then resetTickTimer() end
end

function resetTickTimer()
  if self.dependant then
    local healthCoef = status.resourcePercentage("health")
    if healthCoef > self.healthCoef then deactivate() else activate() end
    self.tickTimer = math.max(healthCoef * (1 / self.healthCoef), 0.25)
  else
    self.tickTimer = self.tickTime
  end
end

function activate()
  self.active = true
  initAnimation()
end

function deactivate()
  self.active = false
  uninitAnimation()
end

function fire()
  local power = setUpDamage()
  local targetIds = world.entityQuery(mcontroller.position(), self.range, { withoutEntityId = entity.id(), includedTypes = {"creature"} } )

  shuffle(targetIds)

  for i,id in ipairs(targetIds) do
    local sourceEntityId = effect.sourceEntity() or entity.id()
    if world.entityCanDamage(sourceEntityId, id) and not world.lineTileCollision(mcontroller.position(), world.entityPosition(id)) then
      if (world.entityDamageTeam(sourceEntityId).type == "friendly" and world.entityAggressive(id)) or world.entityAggressive(sourceEntityId) then
        local sourceDamageTeam = world.entityDamageTeam(sourceEntityId)
        local directionTo = world.distance(world.entityPosition(id), mcontroller.position())
        local projectile = { power = power or self.power, damageTeam = sourceDamageTeam }
        if self.statusEffects then projectile.statusEffects = self.statusEffects end
        if self.speed then projectile.speed = self.speed end
        projectile = sb.jsonMerge(projectile, self.projectileConfig)
        world.spawnProjectile( self.bolt, mcontroller.position(), entity.id(), directionTo, false, projectile )
        if self.playSound then animator.playSound("bolt") end
        break
      end
    end
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
  return self.power
end

function uninit()
end

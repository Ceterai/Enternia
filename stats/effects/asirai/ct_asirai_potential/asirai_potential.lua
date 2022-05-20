require "/scripts/util.lua"
require "/scripts/status.lua"

function init()
  if config.getParameter("animateAura", false) then
    animator.setAnimationState("aura", "windup")
    animator.setParticleEmitterOffsetRegion("sparks", mcontroller.boundBox())
    animator.setParticleEmitterActive("sparks", true)
    -- effect.setParentDirectives("fade=7733AA=0.25")
  end

  script.setUpdateDelta(5)

  self.electricResistance = config.getParameter("electricResistanceModifier", 0.0)
  self.damageClampRange = config.getParameter("damageClampRange")

  self.tickTime = config.getParameter("boltInterval", 1.0)
  self.tickTimer = self.tickTime
  effect.addStatModifierGroup({{stat = "electricResistance", effectiveMultiplier = self.electricResistance}})
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  local boltPower = util.clamp(status.resourceMax("health") * config.getParameter("healthDamageFactor", 1.0), self.damageClampRange[1], self.damageClampRange[2])
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    local targetIds = world.entityQuery(mcontroller.position(), config.getParameter("jumpDistance", 10), {
      withoutEntityId = entity.id(),
      includedTypes = {"creature"}
    })

    shuffle(targetIds)

    for i,id in ipairs(targetIds) do
      local sourceEntityId = effect.sourceEntity() or entity.id()
      if world.entityCanDamage(sourceEntityId, id) and world.entityAggressive(id) and not world.lineTileCollision(mcontroller.position(), world.entityPosition(id)) then
        local sourceDamageTeam = world.entityDamageTeam(sourceEntityId)
        local directionTo = world.distance(world.entityPosition(id), mcontroller.position())
        world.spawnProjectile(
          "teslaboltsmall",
          mcontroller.position(),
          entity.id(),
          directionTo,
          false,
          {
            power = boltPower,
            damageTeam = sourceDamageTeam
          }
        )
        animator.playSound("bolt")
        return
      end
    end
  end
end

function uninit()
end

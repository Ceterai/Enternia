-- My Enternia monster behaviour scripts.
---@diagnostic disable: undefined-global, lowercase-global
require "/monsters/monster.lua"


function init()  -- Engine callback - called on initialization of entity.
  self.pathing = {}
  self.notifications = {}
  storage.spawnTime = world.time()
  if storage.spawnPosition == nil or config.getParameter("wasRelocated", false) then
    local position = mcontroller.position()
    local groundSpawnPosition
    if mcontroller.baseParameters().gravityEnabled then
      groundSpawnPosition = findGroundPosition(position, -20, 3)
    end
    storage.spawnPosition = groundSpawnPosition or position
  end
  self.collisionPoly = mcontroller.collisionPoly()
  if animator.hasSound("deathPuff") then monster.setDeathSound("deathPuff") end
  if config.getParameter("deathParticles") then monster.setDeathParticleBurst(config.getParameter("deathParticles")) end
  script.setUpdateDelta(config.getParameter("initialScriptDelta", 5))
  mcontroller.setAutoClearControls(false)
  self.behaviorTickRate = config.getParameter("behaviorUpdateDelta", 2)
  self.behaviorTick = math.random(1, self.behaviorTickRate)
  animator.setGlobalTag("flipX", "")
  if config.getParameter("customBody") then animator.setPartTag("body", "partImage", config.getParameter("customBody")) end

  capturable.init()
  self.debug = true

  message.setHandler("notify", function(_,_,notification) return notify(notification) end)
  message.setHandler("despawn", despawn)

  -- Parameters
  self.forceRegions = ControlMap:new(config.getParameter("forceRegions", {}))
  self.damageSources = ControlMap:new(config.getParameter("damageSources", {}))
  self.touchDamageEnabled = false
  self.shouldDie = config.getParameter("shouldDie", true)  -- Whether this monster can die at all.
  self.minHealth = config.getParameter("minHealth", 0) * root.evalFunction("monsterLevelHealthMultiplier", monster.level())  -- Actual min hp (def: 0).

  -- Status Effects
  if config.getParameter("statusEffects") then
    status.setPersistentEffects("effects", config.getParameter("statusEffects"))
  end

  -- Behavior
  self.behavior = behavior.behavior("monster", config.getParameter("behaviorConfig", {}), _ENV)
  self.board = self.behavior:blackboard()
  self.board:setPosition("spawn", storage.spawnPosition)
  self.board:setNumber("facingDirection", mcontroller.facingDirection())
  self.deathBehavior = behavior.behavior("monster-death", config.getParameter("behaviorConfig", {}), _ENV, self.behavior:blackboard())
  monster.setDeathParticleBurst("deathPoof")
  monster.setInteractive(config.getParameter("interactive", false))
  monster.setAnimationParameter("chains", config.getParameter("chains"))
  if config.getParameter("damageBar") then monster.setDamageBar(config.getParameter("damageBar")) end

  -- Elite
  if config.getParameter("elite", false) then status.setPersistentEffects("elite", {"elitemonster"}) end

  -- Damage listener: listen to damage taken and record it.
  self.damageTaken = damageListener("damageTaken", function(notifications)
    for _,notification in pairs(notifications) do
      if notification.healthLost > 0 then
        self.damaged = true
        self.board:setEntity("damageSource", notification.sourceEntityId)
      end
    end
  end)
end

function shouldDie()  -- Whether the monster can finally stop existing.
  return (self.shouldDie and status.resource("health") <= self.minHealth) or capturable.justCaptured
end

function despawn()  -- Despawns the monster.
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  self.deathBehavior = nil
  self.shouldDie = true
  status.addEphemeralEffect("monsterdespawn")
end

require "/scripts/util.lua"
require "/scripts/status.lua"

function init()
  self.damageModifier = config.getParameter("damageModifier", 10.0)
  self.consumeEnergy = config.getParameter("consumeEnergy", 0.0)
  self.damageListener = damageListener("inflictedDamage", function(requests)
    for _, request in pairs(requests) do
      if string.find(request.damageSourceKind, "electric") then
        local damage = request.damage or request.damageDealt
        damage = math.max(0, (damage * self.damageModifier) - damage)
        if damage > 0 then
          if self.doUpdate then
            local directionTo = world.distance(world.entityPosition(request.targetEntityId), mcontroller.position())
            world.spawnProjectile(
              "teslaboltsmall",
              mcontroller.position(),
              entity.id(),
              directionTo,
              false,
              {
                power = damage
              }
            )
            if self.consumeEnergy then
              if not status.resourceLocked("energy") then
                status.overConsumeResource("energy", self.consumeEnergy)
              else
                status.overConsumeResource("health", self.consumeEnergy)
              end
            end
            self.doUpdate = false
          else
            self.doUpdate = true
          end
        end
        break
      end
    end
  end)
  self.doUpdate = true
end


function update(dt)
  self.damageListener:update()
end

function uninit()
end

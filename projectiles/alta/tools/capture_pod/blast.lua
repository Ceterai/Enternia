require "/scripts/util.lua"
require "/scripts/companions/util.lua"
require "/scripts/messageutil.lua"

function update(dt)
  promises:update()
end

function hit(entityId)
  if self.hit then return end
  if world.isMonster(entityId) then
    self.hit = true

    -- If a monster doesn't implement pet.attemptCapture or its response is nil
    -- then it isn't caught.
    promises:add(world.sendEntityMessage(entityId, "pet.attemptCapture", projectile.sourceEntity()), function (pet)
        self.pet = pet
      end)
  end
end

function shouldDestroy()
  return projectile.timeToLive() <= 0 and promises:empty()
end

function destroy()
  if self.pet then
    spawnFilledPod(self.pet)
  else
    spawnEmptyPod()
  end
end

function spawnEmptyPod()
  world.spawnItem("ct_alta_capture_pod", mcontroller.position(), 1)
end

function createFilledPod(pet)
  return {
      name = "ct_alta_filled_capture_pod",
      count = 1,
      parameters = {
          description = pet.description,
          tooltipFields = {
              subtitle = pet.name or "Unknown",
              objectImage = pet.portrait
            },
          podUuid = sb.makeUuid(),
          collectablesOnPickup = pet.collectables,
          pets = {pet}
        }
    }
end

function spawnFilledPod(pet)
  local pod = createFilledPod(pet)
  world.spawnItem(pod.name, mcontroller.position(), pod.count, pod.parameters)
end

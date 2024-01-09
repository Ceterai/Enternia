---@diagnostic disable: undefined-global
require "/objects/wired/door/door.lua"


function init()
  setDirection(storage.doorDirection or object.direction())
  self.exists = 0
  self.delay = 0
  self.sensorConfig = config.getParameter("sensorConfig")
  if self.sensorConfig then
    self.sensorConfig.detectEntityTypes = self.sensorConfig.detectEntityTypes or {"Player", "Npc"}
    self.sensorConfig.detectBoundMode = self.sensorConfig.detectBoundMode or "CollisionArea"
    self.sensorConfig.detectDuration = self.sensorConfig.detectDuration or 3
    self.sensorConfig.detectTimer = 0
    local detectArea = self.sensorConfig.detectArea
    local pos = object.position()
    if not detectArea or detectArea == "horizontal" then
      local bb = object.boundBox()
      self.sensorConfig.detectArea = {
        {bb[1] - 1, bb[2] + 0},
        {bb[3] + 1, bb[4] - 0}
      }
    elseif detectArea == "vertical" then
      local bb = object.boundBox()
      self.sensorConfig.detectArea = {
        {bb[1] + 1, bb[2] - 4},
        {bb[3] - 1, bb[4] + 4}
      }
    elseif type(detectArea[2]) == "number" then
      --center and radius
      self.sensorConfig.detectArea = {
        {pos[1] + detectArea[1][1], pos[2] + detectArea[1][2]},
        detectArea[2]
      }
    elseif type(detectArea[2]) == "table" and #detectArea[2] == 2 then
      --rect corner1 and corner2
      self.sensorConfig.detectArea = {
        {pos[1] + detectArea[1][1], pos[2] + detectArea[1][2]},
        {pos[1] + detectArea[2][1], pos[2] + detectArea[2][2]}
      }
    end
  end

  if storage.locked == nil then
    storage.locked = config.getParameter("locked", false)
  end

  if storage.state == nil then
    if config.getParameter("defaultState") == "open" then
      openDoor()
    else
      closeDoor()
      self.delay = 0.15
    end
  else
    animator.setAnimationState("doorState", storage.state and "open" or "closed")
    animator.stopAllSounds("loop")
    if not storage.state then
      object.setDamageSources({config.getParameter("barrierDamage", {})})
      animator.setParticleEmitterActive("sparks", true)
      animator.setParticleEmitterOffsetRegion("sparks", {-0.5, 0.0, 1.5, 5.0})
      self.delay = 1.25
    else
      object.setDamageSources({})
      animator.setParticleEmitterActive("sparks", false)
    end
  end

  updateCollisionAndWires()
  updateInteractive()
  updateLight()

  message.setHandler("openDoor", function() openDoor() end)
  message.setHandler("closeDoor", function() closeDoor() end)
  message.setHandler("lockDoor", function() lockDoor() end)
end

function update(dt)
  if self.sensorConfig then
    self.sensorConfig.detectTimer = math.max(0, self.sensorConfig.detectTimer - dt)

    if not storage.locked and not object.isInputNodeConnected(0) then
      local entityIds = world.entityQuery(self.sensorConfig.detectArea[1], self.sensorConfig.detectArea[2], {
          withoutEntityId = entity.id(),
          includedTypes = self.sensorConfig.detectEntityTypes,
          boundMode = self.sensorConfig.detectBoundMode
        })

      if #entityIds > 0 then
        self.sensorConfig.detectTimer = self.sensorConfig.detectDuration
      end

      if self.sensorConfig.detectTimer > 0 then
        openDoor()
      else
        closeDoor()
      end
    end
  end
  if self.delay > 0 then
    if self.exists > self.delay then
      sb.logInfo('\nwehere!\n')
      animator.playSound("loop", -1)
      self.delay = 0
    else
      self.exists = self.exists + dt
    end
  end
end

function closeDoor()
  if storage.state ~= false then
    storage.state = false
    updateInteractive()
    animator.playSound("close")
    animator.setAnimationState("doorState", "closing")
    updateCollisionAndWires()
    updateLight()
    object.setDamageSources({config.getParameter("barrierDamage", {})})
    animator.setParticleEmitterActive("sparks", true)
    animator.setParticleEmitterOffsetRegion("sparks", {-0.5, 0.0, 1.5, 5.0})
    if self.delay == 0 then
      animator.playSound("loop", -1)
    end
  end
end

function openDoor(direction)
  if not storage.state then
    storage.state = true
    storage.locked = false -- make sure we don't get out of sync when wired
    updateInteractive()
    setDirection((direction == nil or direction * object.direction() < 0) and -1 or 1)
    animator.stopAllSounds("loop")
    animator.playSound("open")
    animator.setAnimationState("doorState", "open")
    updateCollisionAndWires()
    updateLight()
    object.setDamageSources({})
    animator.setParticleEmitterActive("sparks", false)
  end
end

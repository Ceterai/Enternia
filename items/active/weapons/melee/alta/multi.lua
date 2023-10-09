---@diagnostic disable: undefined-global, lowercase-global
require "/scripts/util.lua"
require "/scripts/rope.lua"
require "/items/active/weapons/melee/alta/enhanced.lua"


function getDefaultPrimary() return GrapplePick end

function Weapon:update(dt, fireMode, shiftHeld, moves)
  self.attackTimer = math.max(0, self.attackTimer - dt)

  for _,ability in pairs(self.abilities) do
    ability:update(dt, fireMode, shiftHeld, moves)
  end

  if self.currentState then
    if coroutine.status(self.stateThread) ~= "dead" then
      local status, result = coroutine.resume(self.stateThread)
      if not status then error(result) end
    else
      self.currentAbility:uninit()
      self.currentAbility = nil
      self.currentState = nil
      self.stateThread = nil
      if self.onLeaveAbility then
        self.onLeaveAbility()
      end
    end
  end

  if self.stance then
    self:updateAim()
    self.relativeArmRotation = self.relativeArmRotation + self.armAngularVelocity * dt
    self.relativeWeaponRotation = self.relativeWeaponRotation + self.weaponAngularVelocity * dt
  end

  if self.handGrip == "wrap" then
    activeItem.setOutsideOfHand(self:isFrontHand())
  elseif self.handGrip == "embed" then
    activeItem.setOutsideOfHand(not self:isFrontHand())
  elseif self.handGrip == "outside" then
    activeItem.setOutsideOfHand(true)
  elseif self.handGrip == "inside" then
    activeItem.setOutsideOfHand(false)
  end

  self:clearDamageSources()
end

function update(dt, fireMode, shiftHeld, moves)
  self.weapon:update(dt, fireMode, shiftHeld, moves)
  if self.weapon.isWrist then updateHand() end
end


Grapple = AltaMeleeDownstab:new()

function Grapple:setDefaults()
  AltaMeleeDownstab.setDefaults(self)
  self.fireOffset = self.fireOffset or {0, 0.3}
  self.ropeOffset = self.ropeOffset or {-1.75, 0.3}
  self.ropeVisualOffset = self.ropeVisualOffset or {0.75, 0.3}
  self.consumeOnUse = self.consumeOnUse or false
  self.pressParams.type = self.pressParams.type or 'grapplehook'
  self.pressParams.params = self.pressParams.params or { speed=100, timeToLive=2.35 }
  self.reelInDistance = self.reelInDistance or 3.5
  self.reelOutLength = self.reelOutLength or 50
  self.breakLength = self.breakLength or 60
  self.minSwingDistance = self.minSwingDistance or 1.5
  self.reelSpeed = self.reelSpeed or 15
  self.controlForce = self.controlForce or 1000
  self.groundLagTime = self.groundLagTime or 0.2

  self.rope = {}
  self.ropeLength = 0
  self.aimAngle = 0
  self.onGround = false
  self.onGroundTimer = 0
  self.facingDirection = 0
  self.grapple = { id=nil, pos=nil }
  self.anchored = false
  self.previousMoves = {}
  self.previousFireMode = nil
end

function Grapple:uninit() AltaMeleeDownstab.uninit(self); self:cancelGrapple() end

function Grapple:update(dt, fireMode, shiftHeld, moves)
  AltaAbil.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimerHold = math.max(0, self.cooldownTimerHold - dt)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  self:trySwitch(not self.weapon.currentAbility and self.cooldownTimer == 0)

  self.aimAngle, self.facingDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
  activeItem.setFacingDirection(self.facingDirection)
  self:trackGround(dt)
  self:trackProjectile()
  if self.grapple.id then
    if world.entityExists(self.grapple.id) then
      local position = mcontroller.position()
      local handPosition = vec2.add(position, activeItem.handPosition(self.ropeOffset))
      local newRope
      if #self.rope == 0 then
        newRope = {handPosition, self.grapple.pos}
      else
        newRope = copy(self.rope)
        table.insert(newRope, 1, world.nearestTo(newRope[1], handPosition))
        table.insert(newRope, world.nearestTo(newRope[#newRope], self.grapple.pos))
      end
      windRope(newRope)
      self:updateRope(newRope)
      if not self.anchored and self.ropeLength > self.reelOutLength then self:cancelGrapple() end
    else self:cancelGrapple() end
  end
  if self.ropeLength > self.breakLength then self:cancelGrapple() end
  if self.anchored then self:swing(moves) else activeItem.setArmAngle(self.aimAngle) end
end

function Grapple:trackProjectile()
  if self.grapple.id then
    if world.entityExists(self.grapple.id) then
      local position = mcontroller.position()
      self.grapple.pos = vec2.add(world.distance(world.entityPosition(self.grapple.id), position), position)
      if not self.anchored then self.anchored = world.callScriptedEntity(self.grapple.id, "anchored") end
    else self:cancelGrapple() end
  end
end

function Grapple:trackGround(dt)
  if mcontroller.onGround() then
    self.onGround = true
    self.onGroundTimer = self.groundLagTime
  else
    self.onGroundTimer = self.onGroundTimer - dt
    if self.onGroundTimer < 0 then self.onGround = false end
  end
end

function Grapple:press()
  if self.grapple.id then self:cancelGrapple() elseif status.stat("activeMovementAbilities") < 1 then self:fireGrapple(self.pressParams) end
  self.cooldownTimer = self.fireTime
end
function Grapple:fireGrapple(cfg)
  self:cancelGrapple()
  local aimVector = vec2.rotate({1, 0}, self.aimAngle)
  self.grapple.id = self:fireRanged(cfg.type, cfg.params, self:grapplePos(), nil, {aimVector[1] * self.facingDirection, aimVector[2]}, nil)
  if self.grapple.id then
    animator.playSound(cfg.sound or (self.abilitySlot..'_press'))
    status.setPersistentEffects("grapplingHook"..activeItem.hand(), {{stat = "activeMovementAbilities", amount = 0.5}})
  end
end

function Grapple:cancelGrapple()
  if self.grapple.id and world.entityExists(self.grapple.id) then world.callScriptedEntity(self.grapple.id, "kill") end
  if self.grapple.id and self.anchored and self.consumeOnUse then item.consume(1) end
  self.grapple.id = nil
  self.grapple.pos = nil
  self.anchored = false
  self:updateRope({})
  status.clearPersistentEffects("grapplingHook"..activeItem.hand())
end

function Grapple:swing(moves)
  local canReel = self.ropeLength > self.reelInDistance or world.magnitude(self.rope[2], mcontroller.position()) > self.reelInDistance
  local armAngle = activeItem.aimAngle(self.fireOffset[2], self.rope[2])
  local pullDirection = vec2.withAngle(armAngle)
  activeItem.setArmAngle(self.facingDirection == 1 and armAngle or math.pi - armAngle)
  if world.magnitude(self.grapple.pos, mcontroller.position()) < self.minSwingDistance then
    --do nothing
  elseif self.onGround then
    if (moves.up and canReel) or self.ropeLength > self.reelOutLength then
      mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), self.reelSpeed, self.controlForce, true)
    end
  else
    if moves.down and self.ropeLength < self.reelOutLength then
      mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), -self.reelSpeed, self.controlForce, true)
    elseif moves.up and canReel then
      mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), self.reelSpeed, self.controlForce, true)
    elseif pullDirection[2] > 0 or self.ropeLength > self.reelOutLength then
      mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), 0, self.controlForce, true)
    end
    if moves.jump and not self.previousMoves.jump then
      if not mcontroller.canJump() then
        mcontroller.controlJump(true)
      end
      self:cancelGrapple()
    end
  end
  self.previousMoves = moves
end

function Grapple:grapplePos()
  local entityPos = mcontroller.position()
  local barrelOffset = activeItem.handPosition(self.fireOffset)
  local barrelPosition = vec2.add(entityPos, barrelOffset)
  local collidePoint = world.lineCollision(entityPos, barrelPosition)
  if collidePoint then return vec2.add(entityPos, vec2.mul(barrelOffset, vec2.mag(barrelOffset) - 0.5))
  else return barrelPosition end
end

function Grapple:updateRope(newRope)
  local position = mcontroller.position()
  local previousRopeCount = #self.rope
  self.rope = newRope
  self.ropeLength = 0
  activeItem.setScriptedAnimationParameter("ropeOffset", self.ropeVisualOffset)
  for i = 2, #self.rope do
    self.ropeLength = self.ropeLength + world.magnitude(self.rope[i], self.rope[i - 1])
    activeItem.setScriptedAnimationParameter("p" .. i, self.rope[i])
  end
  for i = #self.rope + 1, previousRopeCount do
    activeItem.setScriptedAnimationParameter("p" .. i, nil)
  end
end








require "/scripts/vec2.lua"

-- Pickaxe primary ability
GrapplePick = Grapple:new()

function GrapplePick:setAnimationStates(states)
  for stateType, state in pairs(states or {}) do
    animator.setAnimationState(stateType, state)
  end
end

-- State: windup
function GrapplePick:holdAbil()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()
  if self:canHold() then self:setState(self.firePick) end
end

-- State: fire
function GrapplePick:firePick()
  local entityPosition = world.entityPosition(activeItem.ownerEntityId())
  self.hitPosition = activeItem.ownerAimPosition()
  local distance = vec2.mag(world.distance(entityPosition, self.hitPosition))
  if distance > self.toolRange then
    coroutine.yield()
    self:setState(self.hold)
    return
  end

  local radius = self.shiftHeld and self.altBlockRadius or self.blockRadius
  local brushArea = self:tileAreaBrush(radius, self.hitPosition)

  if not world.damageTiles(brushArea, self.layer, entityPosition, self.tileDamageType, self.tileDamage, self.harvestLevel, activeItem.ownerEntityId()) then
    coroutine.yield()
    self:setState(self.hold)
    return
  end
  status.overConsumeResource("energy", self.energyUsage or 0)
  animator.setSoundPool("blockSound", {self:getBlockSound(brushArea)})
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()
  coroutine.yield()
  animator.playSound("blockSound")
  animator.playSound("firePick")
  util.wait(self.stances.fire.duration)
  if self:canHold() then self:setState(self.firePick) end
end

function GrapplePick:getBlockSound(brushArea)
  local defaultFootstepSound = root.assetJson("/client.config:defaultFootstepSound")

  for _,pos in pairs(brushArea) do
    if world.isTileProtected(pos) then
      return root.assetJson("/client.config:defaultDingSound")
    end
  end

  for _,pos in pairs(brushArea) do
    local material = world.material(pos, self.layer)
    local mod = world.mod(pos, self.layer)
    local blockSound = type(material) == "string" and root.materialMiningSound(material, mod)
    if blockSound then return blockSound end
  end

  for _,pos in pairs(brushArea) do
    local material = world.material(pos, self.layer)
    local mod = world.mod(pos, self.layer)
    local blockSound = type(material) == "string" and root.materialFootstepSound(material, mod)
    if blockSound and blockSound ~= defaultFootstepSound then
      return blockSound
    end
  end

  return nil
end

function GrapplePick:tileAreaBrush(radius, centerPosition)
  local result = jarray()
  local offset = {-radius/2, -radius/2}
  local intOffset = util.map(vec2.add(offset, centerPosition), util.round)

  for x = 0, radius-1 do
    for y = 0, radius-1 do
      local intPos = util.map({x, y}, util.round)
      table.insert(result, vec2.add(intPos, intOffset))
    end
  end
  return result
end

function GrapplePick:setDefaults()
  Grapple.setDefaults(self)
  self.layer = self.layer or 'foreground'
  self.toolRange=self.toolRange or 5.5
  self.blockRadius=self.blockRadius or 3
  self.altBlockRadius=self.altBlockRadius or 1
  self.tileDamage=self.tileDamage or 4.8
  self.tileDamageType=self.tileDamageType or "beamish"
  self.harvestLevel=self.harvestLevel or 99
  self.stances.windup = self.stances.windup or { duration=0.0, armRotation=-90, weaponRotation=-10, weaponOffset={0, 2.25}, allowRotate=true, allowFlip=true }
  self.stances.fire = self.stances.fire or { duration=0.3, armRotation=-45, weaponRotation=-10, weaponOffset={0, 2.25}, armAngularVelocity=360, twoHanded=true, allowRotate=true, allowFlip=true }
end



-- whip primary attack
WhipCrack = AltaMeleeDownstab:new()

function WhipCrack:setDefaults()
  AltaMeleeDownstab.setDefaults(self)
  self.damageConfig.baseDamage = self.chainDps * self.fireTime

  self.weapon:setStance(self.stances.idle)
  animator.setAnimationState("attack", "idle")
  activeItem.setScriptedAnimationParameter("chains", nil)

  self.cooldownTimer = self:cooldownTimeF()

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end

  self.projectileConfig = self.projectileConfig or {}

  self.chain = config.getParameter("chain")
end

-- State: windup
function WhipCrack:hold()
  self.weapon:setStance(self.stances.windup)

  animator.setAnimationState("attack", "windup")

  util.wait(self.stances.windup.duration)

  self:setState(self.extend)
end

-- State: extend
function WhipCrack:extend()
  self.weapon:setStance(self.stances.extend)

  animator.setAnimationState("attack", "extend")
  animator.playSound("swing")

  util.wait(self.stances.extend.duration)

  animator.setAnimationState("attack", "fire")
  self:setState(self.fireWhip)
end

-- State: fire
function WhipCrack:fireWhip()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local chainStartPos = vec2.add(mcontroller.position(), activeItem.handPosition(self.chain.startOffset))
  local chainLength = world.magnitude(chainStartPos, activeItem.ownerAimPosition())
  chainLength = math.min(self.chain.length[2], math.max(self.chain.length[1], chainLength))

  self.chain.endOffset = vec2.add(self.chain.startOffset, {chainLength, 0})
  local collidePoint = world.lineCollision(chainStartPos, vec2.add(mcontroller.position(), activeItem.handPosition(self.chain.endOffset)))
  if collidePoint then
    chainLength = world.magnitude(chainStartPos, collidePoint) - 0.25
    if chainLength < self.chain.length[1] then
      animator.setAnimationState("attack", "idle")
      return
    else
      self.chain.endOffset = vec2.add(self.chain.startOffset, {chainLength, 0})
    end
  end

  local chainEndPos = vec2.add(mcontroller.position(), activeItem.handPosition(self.chain.endOffset))

  activeItem.setScriptedAnimationParameter("chains", {self.chain})

  animator.resetTransformationGroup("endpoint")
  animator.translateTransformationGroup("endpoint", self.chain.endOffset)
  animator.burstParticleEmitter("crack")
  animator.playSound("crack")

  self.projectileConfig.power = self:crackDamage()
  self.projectileConfig.powerMultiplier = activeItem.ownerPowerMultiplier()

  local projectileAngle = vec2.withAngle(self.weapon.aimAngle)
  if self.weapon.aimDirection < 0 then projectileAngle[1] = -projectileAngle[1] end

  world.spawnProjectile(
    self.projectileType,
    chainEndPos,
    activeItem.ownerEntityId(),
    projectileAngle,
    false,
    self.projectileConfig
  )

  util.wait(self.stances.fire.duration, function()
    if self.damageConfig.baseDamage > 0 then
      self.weapon:setDamage(self.damageConfig, {self.chain.startOffset, {self.chain.endOffset[1] + 0.75, self.chain.endOffset[2]}}, self.fireTime)
    end
  end)

  animator.setAnimationState("attack", "idle")
  activeItem.setScriptedAnimationParameter("chains", nil)

  self.cooldownTimer = self:cooldownTimeF()
end

function WhipCrack:cooldownTimeF()
  return self.fireTime - (self.stances.windup.duration + self.stances.extend.duration + self.stances.fire.duration)
end

function WhipCrack:uninit(unloaded)
  self.weapon:setDamage()
  activeItem.setScriptedAnimationParameter("chains", nil)
  AltaMeleeDownstab.uninit(self)
end

function WhipCrack:chainDamage()
  return (self.chainDps * self.fireTime) * config.getParameter("damageLevelMultiplier")
end

function WhipCrack:crackDamage()
  return (self.crackDps * self.fireTime) * config.getParameter("damageLevelMultiplier")
end


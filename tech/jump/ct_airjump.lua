function init()
  self.airJumpModifier = config.getParameter("airJumpModifier")
  self.airJumpTimeout = config.getParameter("airJumpTimeout")

  refreshJumps()
end

function update(args)
  local jumpActivated = args.moves["jump"] and not self.lastJump
  self.lastJump = args.moves["jump"]

  updateJumpModifier()

  if jumpActivated and canMultiJump() then
    doMultiJump()
  else
    if mcontroller.groundMovement() or mcontroller.liquidMovement() then
      refreshJumps()
    else
      if self.airJumpSince < self.airJumpTimeout then
        self.airJumpSince = math.min(self.airJumpTimeout, self.airJumpSince + args.dt)
      end
    end
  end
end

-- after the original ground jump has finished, start applying the new jump modifier
function updateJumpModifier()
  if self.airJumpModifier then
    if not self.applyJumpModifier
        and not mcontroller.jumping()
        and not mcontroller.groundMovement() then
      self.applyJumpModifier = true
    end
    if self.applyJumpModifier then mcontroller.controlModifiers({airJumpModifier = self.airJumpModifier}) end
  end
end

function canMultiJump()
  return self.airJumpSince == self.airJumpTimeout
      and not mcontroller.jumping()
      and not mcontroller.canJump()
      and not mcontroller.liquidMovement()
      and not status.statPositive("activeMovementAbilities")
      and math.abs(world.gravity(mcontroller.position())) > 0
end

function doMultiJump()
  mcontroller.controlJump(true)
  mcontroller.setYVelocity(math.max(0, mcontroller.yVelocity()))
  self.airJumpSince = 0
  animator.burstParticleEmitter("airJumpParticles")
  animator.playSound("airJumpSound")
end

function refreshJumps()
  self.airJumpSince = self.airJumpTimeout
  self.applyJumpModifier = false
end

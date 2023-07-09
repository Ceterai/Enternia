require "/scripts/util.lua"

singState = {}

function singState.enter()
  local singTime = util.randomInRange(config.getParameter("sing.singTime"))
  return {
    singTime = singTime,
    timer = singTime,
  }
end

function singState.enteringState(stateData)
end

function singState.stateDesc()
  return "singAction"
end

function singState.update(dt, stateData)
  local now = world.time()
  if self.lastSing == nil then self.lastSing = now end
  if now - self.lastSing > (self.singCooldown or 180) then
    stateData.timer = stateData.timer - dt
    setSingState()

    if stateData.timer < 0 then
      self.lastSing = now
      return true, 1
    else
      return false
    end
  else
    stateData.timer = 0
    return true, 1
  end
end

function setSingState()
  local currentState = animator.animationState("movement")
  if not mcontroller.onGround() then setJumpState()
  elseif currentState ~= "sing" then
    animator.setAnimationState("movement", "sing")
  end
end

require "/scripts/util.lua"

soundState = {}

function soundState.enter()
  local soundTime = util.randomInRange(config.getParameter("sound.soundTime"))
  return {
    soundTime = soundTime,
    timer = soundTime,
  }
end

function soundState.enteringState(stateData)
end

function soundState.stateDesc()
  return "soundAction"
end

function soundState.update(dt, stateData)
  local now = world.time()
  if self.lastSound == nil then self.lastSound = now end
  if now - self.lastSound > (self.soundCooldown or 20) then
    stateData.timer = stateData.timer - dt
    setSoundState()

    if stateData.timer < 0 then
      self.lastSound = now
      return true, 1
    else
      return false
    end
  else
    stateData.timer = 0
    return true, 1
  end
end

function setSoundState()
  local currentState = animator.animationState("movement")
  if not mcontroller.onGround() then setJumpState()
  elseif currentState ~= "sound" then
    animator.setAnimationState("movement", "sound")
  end
end

function init()
  if status.isResource("stunned") then
    status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
  end
  mcontroller.setVelocity({0, 0})
  if status.stat("electricStatusImmunity") == 0.0 then effect.addStatModifierGroup({{stat = "emiJam", amount = 1.0}}) end
end

function update(dt)
  mcontroller.controlModifiers({
      facingSuppressed = true,
      movementSuppressed = true
    })
end

function uninit()
  
end

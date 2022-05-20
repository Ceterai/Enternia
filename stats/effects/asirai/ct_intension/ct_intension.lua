function init()
  local mStat = config.getParameter("modifiedStat", "electricResistance")
  local mValue = 1.0 - config.getParameter("modifiedValue", 0.01)
  effect.addStatModifierGroup({
    {stat = mStat, effectiveMultiplier = mValue}
  })
end

function update(dt)
end

function uninit()
end

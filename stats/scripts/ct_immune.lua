function init()
end

function update(dt)
end

-- Checks whether an entity has **full immunity** stat that is set via an optional `fullImmunity` parameter.  
-- Example: if `fullImmunity` is set to `iceStatusImmunity`, and the entity has `iceStatusImmunity` > 0, this returns `true`.
function immune()
  return ct_immune_check(config.getParameter("fullImmunity"))
end

-- Checks whether an entity has **partial immunity** stat that is set via an optional `semiImmunity` parameter.  
-- Example: if `semiImmunity` is set to `iceStatusImmunity`, and the entity has `iceStatusImmunity` > 0, this returns `true`.  
-- If `stack` is set to `true`, checks for `fullImmunity` as well.
function semiImmune(stack)
  if stack then return (semiImmune() or immune()) end
  return ct_immune_check(config.getParameter("semiImmunity"))
end

-- Checks whether an entity has **minimal immunity** stat that is set via an optional `miniImmunity` parameter.  
-- Example: if `miniImmunity` is set to `iceStatusImmunity`, and the entity has `iceStatusImmunity` > 0, this returns `true`.  
-- If `stack` is set to `true`, checks for `semiImmunity` and `fullImmunity` as well.
function barelyImmune(stack)
  if stack then return (barelyImmune() or semiImmune() or immune()) end
  return ct_immune_check(config.getParameter("miniImmunity"))
end

-- Checks whether an entity has **susceptibility** stat that is set via an optional `vulnerability` parameter.  
-- This can be used to check whether an entity should experience inreased negative effects from a status effect.  
-- Example: if `vulnerability` is set to `emiJam`, and the entity has `emiJam` > 0, this returns `true`.
function vulnerable()
  return ct_immune_check(config.getParameter("vulnerability"))
end

-- Modify the `damage` variable based on entity's immunities and vulnerabilities.
function calculateImmunityToDamage(damage, damageMin, damageZero, damageMultiplier)
  if vulnerable() then damage = damage * (damageMultiplier or config.getParameter("immunityMultiplier", 2)) end
  if barelyImmune() then damage = damage / (damageMultiplier or config.getParameter("immunityMultiplier", 2)) end
  if semiImmune() then damage = damageMin or 1 end
  if immune() then damage = damageZero or 0 end
  return tonumber(damage)
end

function ct_immune_check(stats)
  if stats ~= nil then
    if type(stats) == "string" then return _ct_immune_check(stats) end
    for _,stat in ipairs(stats) do if _ct_immune_check(stat) then return true end end
  end
  return false
end

function _ct_immune_check(stat)
  return (status.stat(stat) > 0.0)
end

function uninit()
end

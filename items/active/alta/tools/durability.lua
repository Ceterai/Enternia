require "/items/active/weapons/bow/abilities/bowshot.lua"

LimitedShot = BowShot:new()

function LimitedShot:fire()
  local durabilityHit = config.getParameter("durabilityHit") or config.getParameter("durability")
  local durabilityOld = durabilityHit
  local durability = config.getParameter("durabilityLabel")
  local tips = config.getParameter("tooltipFields", {})
  BowShot.fire(self)
  durabilityHit = durabilityHit - config.getParameter("durabilityPerShot", 1)
  if durabilityHit <= 0 then
    item.consume(1)
  end
  tips.loreLabel = tips.loreLabel:gsub(durability:format(math.ceil(durabilityOld)), durability:format(math.ceil(durabilityHit)))
  activeItem.setInstanceValue("durabilityHit", durabilityHit)
  activeItem.setInstanceValue("tooltipFields", tips)
end

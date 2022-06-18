function init()
  self.statName = config.getParameter("statName", "protection")
  self.statAmount = config.getParameter("statAmount", 2)
  effect.addStatModifierGroup({{stat = self.statName, amount = self.statAmount}})
end

function update(dt)
  
end

function uninit()
  
end
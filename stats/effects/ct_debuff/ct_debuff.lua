function init()
  self.statName = config.getParameter("statName", "protection")
  self.statAmount = config.getParameter("statAmount", 2)
  effect.addStatModifierGroup({{stat = self.statName, amount = self.statAmount}})
  self.statName2 = config.getParameter("statName2", nil)
  self.statAmount2 = config.getParameter("statAmount2", 2)
  if self.statName2 then effect.addStatModifierGroup({{stat = self.statName2, amount = self.statAmount2}}) end
end

function update(dt)
  
end

function uninit()
  
end
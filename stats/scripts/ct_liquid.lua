require "/stats/scripts/ct_immune.lua"
require "/stats/scripts/ct_animation.lua"


-- ### Liquid Effect
-- Applies certain periodic actions when entity is in a liquid.  
-- Can drain energy, damage and set movement modifiers.
function init()
  initAnimation()
  initLiquidStats()
end
function update(dt) liquidTick(dt) end
function uninit() end

-- Initiate all stats related to the **Liquid Effect**.  
-- Supported parameters are listed below and are available via the `self.ct_lqd` variable.
function initLiquidStats()
  self.ct_lqd = {}
  self.ct_lqd.id = config.getParameter("liquidID")  -- Required to do anything. Water is 1.
  self.ct_lqd.movementModifiers = config.getParameter("liquidMovementModifiers")
  self.ct_lqd.energyCost = config.getParameter("liquidEnergyCost")
  self.ct_lqd.damage = config.getParameter("liquidDamage")
  self.ct_lqd.damageKind = config.getParameter("liquidDamageKind", "physical")
  self.ct_lqd.tickTime = config.getParameter("liquidCooldown", 1.0)
  self.ct_lqd.tickTimer = self.ct_lqd.tickTime
end

function liquidTick(dt)
  if self.ct_lqd.id ~= nil then
    self.ct_lqd.tickTimer = self.ct_lqd.tickTimer - dt
    if self.ct_lqd.tickTimer <= 0 then
      self.ct_lqd.tickTimer = self.ct_lqd.tickTime
      if mcontroller.liquidId() == self.ct_lqd.id and not semiImmune(true) then
        if self.ct_lqd.movementModifiers ~= nil then mcontroller.controlModifiers(self.ct_lqd.movementModifiers) end
        if self.ct_lqd.damage then
          status.applySelfDamageRequest({damageType="IgnoresDef", damage=self.ct_lqd.damage, damageSourceKind=self.ct_lqd.damageKind, sourceEntityId=entity.id()})
        end
      end
    end
  end
end

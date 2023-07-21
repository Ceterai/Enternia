require "/stats/scripts/ct_immune.lua"
require "/stats/scripts/ct_animation.lua"
require "/stats/scripts/ct_message.lua"


-- ### Draining Effect
-- Periodically degrades entity's energy. If energy is at 0, optionally damages them instead.  
-- Additionally, sets optional movement parameters.
--
-- Relies on **Immune Effect** to check for immunity.
function init()
  queueImmuneMessage()
  initAnimation()
  initDrainStats()
end

function update(dt) drainTick(dt) end
function uninit() end

function initDrainStats()
  self.ct_drain = {}
  self.ct_drain.movementModifiers = config.getParameter("movementModifiers")
  self.ct_drain.energyCost = config.getParameter("energyCost", 0)
  self.ct_drain.damage = config.getParameter("damage", 0)
  if semiImmune() then
    self.ct_drain.energyCost = self.ct_drain.energyCost / 4
    self.ct_drain.damage = self.ct_drain.damage / 4
  end
  -- effect.addStatModifierGroup({{stat = "energyRegenPercentageRate", effectiveMultiplier = 1}})
  self.ct_drain.tickTime = config.getParameter("cooldown", 10.0)
  self.ct_drain.tickTimer = self.ct_drain.tickTime
end

function drainTick(dt)
  self.ct_drain.tickTimer = self.ct_drain.tickTimer - dt
  if self.ct_drain.tickTimer <= 0 then
    self.ct_drain.tickTimer = self.ct_drain.tickTime
    if not immune() then
      if not status.overConsumeResource("energy", self.ct_drain.energyCost) then
        if self.ct_drain.movementModifiers ~= nil then mcontroller.controlModifiers(self.ct_drain.movementModifiers) end
        if self.ct_drain.damage > 0 then
          status.applySelfDamageRequest({ damageType = "IgnoresDef", damage = self.ct_drain.damage, damageSourceKind = "electric", sourceEntityId=entity.id()})
        end
      end
    end
  end
end

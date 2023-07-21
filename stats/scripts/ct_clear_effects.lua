-- ### Catalyst Effect
-- Clears all effects from the entity. Persistent effects from items will go back immediatelly.
function init()
  status.clearAllPersistentEffects()
  status.clearEphemeralEffects()
end
function update(dt) end
function uninit() end

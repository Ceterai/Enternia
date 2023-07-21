-- ### Light Effect
-- Simply adds a light effect.
function init() script.setUpdateDelta(5) end
function update(dt) animator.setFlipped(mcontroller.facingDirection() == -1) end
function uninit() end

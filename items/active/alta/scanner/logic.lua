function init()
    self.fireOffset = config.getParameter("fireOffset", {0.5, 0.0})
    updateAim()
end

function activate() player.interact('ScriptPane', '/items/active/alta/scanner/gui.config') end

function update(dt, fireMode, shiftHeld) updateAim() end

function updateAim()
    self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
    activeItem.setArmAngle(self.aimAngle)
    activeItem.setFacingDirection(self.aimDirection)
end

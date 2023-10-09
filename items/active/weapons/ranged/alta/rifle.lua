---@diagnostic disable: undefined-global, lowercase-global
require "/items/active/weapons/ranged/alta/ranged.lua"

function getDefaultPrimary() return AltaRifle end
function getDefaultAlt() return AltaRifleSwitch end





--- ### Attachments Switch
--- Basic "switch" ability. On press iterates over a list of attachments.  
--- Supported attachments: `none`, `flashlight`, `lazer` and `stabilizer`. Any other keyword will be treated as `none`.
AltaSwitchAttachments = AltaRanged:new()

function AltaSwitchAttachments:switchAttachments()
  for i, attachment in ipairs(self.attachments) do
    if config.getParameter('attachment') == attachment then
      activeItem.setInstanceValue('attachment', self.attachments[i + 1] or self.attachments[1])
      self:toggle()
      animator.playSound('toggle')
      break
    end
  end
end

function AltaSwitchAttachments:toggle()

  if config.getParameter('attachment') == 'flashlight' then
    animator.setLightActive("flashlight", true)
    animator.setLightActive("flashlightSpread", true)
    animator.setGlobalTag("flashlight", "/items/active/weapons/ranged/alta/abils/utils/flashlight.png")
  else
    animator.setLightActive("flashlight", false)
    animator.setLightActive("flashlightSpread", false)
    animator.setGlobalTag("flashlight", "")
  end

  if config.getParameter('attachment') == 'laserpointer' or config.getParameter('attachment') == 'laser' then
    animator.setLightActive("laser", true)
    animator.setGlobalTag("laser", "/items/active/weapons/ranged/alta/abils/utils/laser.png")
    activeItem.setScriptedAnimationParameter('beams', { self.lazerParams })
  else
    animator.setLightActive("laser", false)
    activeItem.setScriptedAnimationParameter('beams', { { offset={1.875, 0}, color={0, 0, 0, 0}, length=0, segments=0, angle=0 } })
    animator.setGlobalTag("laser", "")
  end

  if config.getParameter('attachment') == 'stabilizer' then
    activeItem.setInstanceValue('stabilizerBonus', 1.25)
    animator.setGlobalTag("stabilizer", "/items/active/weapons/ranged/alta/abils/utils/stabilizer.png")
  else
    activeItem.setInstanceValue('stabilizerBonus', 1.0)
    animator.setGlobalTag("stabilizer", "")
  end

  if config.getParameter('attachment') == 'legs' then
    animator.setGlobalTag("legs", "/items/active/weapons/ranged/alta/abils/utils/legs.png")
  else
    animator.setGlobalTag("legs", "")
  end
end

function AltaSwitchAttachments:setDefaults()
  AltaRanged.setDefaults(self)
  self.attachments = self.attachments or { 'none', 'flashlight', 'laserpointer', 'stabilizer', }
  activeItem.setInstanceValue('attachment', config.getParameter('attachment') or self.attachments[1])
  self.lazerParams = self.lazerParams or { offset={2.875, 0}, color={255, 0, 0, 128}, length=60, segments=6, angle=0 }
  self:toggle()
end





--- ### Firemode&Attachments Switch
--- Advanced "switch" ability. On press iterates over a list of attachments, on hold iterates over firemodes.  
--- Supported firemodes: `single`, `charge`, `burst` and `auto`, or a list of custom firemodes.  
--- Supported attachments: `none`, `flashlight`, `lazer` and `stabilizer`. Any other keyword will be treated as `none`.
AltaSwitchFiremodes = AltaSwitchAttachments:new()

function AltaSwitchFiremodes:switchFiremodes()
  for i, fireType in ipairs(self.fireTypes) do
    if config.getParameter('fireType') == fireType then
      activeItem.setInstanceValue('fireType', self.fireTypes[i + 1] or self.fireTypes[1])
      animator.playSound('toggleFire')
      break
    end
  end
end

function AltaSwitchFiremodes:setDefaults()
  AltaSwitchAttachments.setDefaults(self)
  self.fireTypes = self.fireTypes or { 'single', 'charge', 'burst', 'auto', }
  activeItem.setInstanceValue('fireType', config.getParameter('fireType') or self.fireTypes[1])
end





--- ### Alta Ranged Attachments and/or Firemode Switch
--- Basic "switch" ability. On press iterates over a list of attachments.  
--- Supported attachments: `none`, `flashlight`, `lazer` and `stabilizer`. Any other keyword will be treated as `none`.
AltaSwitch = AltaSwitchFiremodes:new()

function AltaSwitch:setDefaults()
  AltaSwitchFiremodes.setDefaults(self)
  self.holdTimeMin = self.holdTimeMin or 0.75
  self.holdCooldown = self.holdCooldown or 0.35
  self.pressAttachments = self.pressAttachments or false
  self.holdAttachments = self.holdAttachments or false
  self.pressFiremodes = self.pressFiremodes or false
  self.holdFiremodes = self.holdFiremodes or false
  if self.pressAttachments then self.press = self.switchAttachments end
  if self.holdAttachments then self.hold = self.switchAttachments end
  if self.pressFiremodes then self.press = self.switchFiremodes end
  if self.holdFiremodes then self.hold = self.switchFiremodes end
end





--- ### Alta Rifle Attachments&Firemode Switch
--- Basic "switch" ability. On press iterates over a list of attachments.  
--- Supported attachments: `none`, `flashlight`, `lazer` and `stabilizer`. Any other keyword will be treated as `none`.
AltaRifleSwitch = AltaSwitch:new()

function AltaRifleSwitch:setDefaults()
  self.pressAttachments = self.pressAttachments or true
  self.holdFiremodes = self.holdFiremodes or true
  AltaSwitch.setDefaults(self)
end





--- ### Alta Rifle With Firemodes
AltaRifle = AltaRanged:new()

function AltaRifle:press()
  if self.fireType ~= config.getParameter('fireType') then self:setParams() end
  self.pressParams.method(self, self.pressParams)
end

function AltaRifle:hold()
  if self.fireType ~= config.getParameter('fireType') then self:setParams() end
  self.holdParams.method(self, self.holdParams)
end

function AltaRifle:activate()
  self.active = true
  animator.playSound(self.holdStart)
  animator.playSound(self.holdLoop, -1)
end

function AltaRifle:deactivate()
  self.active = false
  animator.stopAllSounds(self.holdStart)
  animator.stopAllSounds(self.holdLoop)
end

function AltaRifle:setParams()
  self.fireType = config.getParameter('fireType') or self.defaultFireType
  local params = self.fireTypes[self.fireType]
  self.pressParams = util.mergeTable(copy(self.actionPresets[params.pressType or 'none']), copy(params.pressParams or {}))
  self.pressParams.sound = self.pressParams.sound or (self.abilitySlot .. '_press')
  self.holdParams = util.mergeTable(copy(self.actionPresets[params.holdType or 'none']), copy(params.holdParams or {}))
  self.holdParams.sound = self.holdParams.sound or (self.abilitySlot .. '_hold')
  self.holdStart = params.holdStart or (self.abilitySlot .. "_start")
  self.holdLoop = params.holdLoop or (self.abilitySlot .. "_loop")
  self.holdTimeMin = params.holdTimeMin or 0.25
  self.holdTimeMax = params.holdTimeMax or 0.75
  self.holdCooldown = params.holdCooldown or 0.15
  self.pressCooldown = params.cooldown or 0
end

function AltaRifle:setDefaults()
  AltaRanged.setDefaults(self)
  self.defaultFireType = self.defaultFireType or 'charge'
  self.fireTypes = self.fireTypes or {
    charge = {
      pressType = 'blast', pressParams = { type = 'ct_impulse_medium', sound = 'primary_press', },
      holdType = 'blast', holdParams = { type = 'ct_impulse_large', sound = 'primary_hold', }, holdStart = 'charge', holdLoop = 'charging',
    },
    semi = { pressType = 'semi', pressParams = { type = 'ct_impulse_medium', count = 2, }, holdTimeMax = 0, },
  }
  self:setParams()
end

require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"
require "/items/buildscripts/alta/object.lua"

local ct_alta_object_builder = build

function build(directory, config, parameters, level, seed)
  local configParameter = function(key, default) return getValue(key, default, config, parameters) end
  local item = configParameter("newItemChange")
  if item then
    local itemConfig = root.itemConfig(item)
    config = itemConfig.config
    parameters = itemConfig.parameters or parameters
  else
    config.itemName = configParameter("newItem", "ct_combat_mask_mk2")
    config.objectName = configParameter("newItem", "ct_combat_mask_mk2")
  end
  parameters.deprecated = true
  config, parameters = ct_alta_object_builder(directory, config, parameters, level, seed)
  return config, parameters
end

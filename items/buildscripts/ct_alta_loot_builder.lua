require "/scripts/util.lua"
require "/items/buildscripts/ct_alta_item_builder.lua"

local ct_alta_item_builder = build

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then return parameters[keyName]
    elseif config[keyName] ~= nil then return config[keyName]
    else return defaultValue end
  end
  sb.logInfo("\n\n\n\nyes!!!1 %s", parameters)
  sb.logInfo("\nyes!!!2 %s", config.treasure)
  sb.logInfo("\nyes!!!2 %s", config.otreasure)

  -- Item stats
  config, parameters = ct_alta_item_builder(directory, config, parameters, level, seed)
  if parameters.treasure then
    local t = parameters.treasure
    local item_list = "Possible contents:"
    local treasure = root.createTreasure(t.pool, t.level, t.seed)
    for _,item in pairs(treasure) do item_list = item_list .. "\n- " .. root.itemConfig(item).config.shortdescription end
    config.tooltipFields.treasureLabel = item_list
  else
    parameters.treasure = config.treasure
    config.otreasure = config.treasure
    config.tooltipFields.treasureLabel = "gggg"
  end
  return config, parameters
end

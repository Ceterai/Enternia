require "/scripts/util.lua"
require "/items/buildscripts/alta/item.lua"


-- # My Enternia Glowstick Builder
function build(directory, config, params, level, seed)
  config, params = getPresetParams(config, params)
  if not config.animationParts then config.animationParts = {item = config.inventoryIcon} end
  config = sb.jsonMerge(getItemTypeDefaults('glowstick'), config)
  config, params = buildItem(directory, config, params, level, seed)

  return config, params
end

require "/scripts/util.lua"
require "/items/buildscripts/alta/item.lua"


-- # My Enternia Tool Builder
function build(directory, config, params, level, seed)
  config, params = getPresetParams(config, params)
  if not config.animationParts then config.animationParts = {item = config.inventoryIcon} end
  if not config.price then
    if config.twoHanded then config.price = 720 else config.price = 480 end
  end
  config = sb.jsonMerge(getItemTypeDefaults('tool'), config)
  config, params = buildItem(directory, config, params, level, seed)

  return config, params
end

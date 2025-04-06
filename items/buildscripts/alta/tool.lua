require "/scripts/util.lua"
require "/items/buildscripts/alta/item.lua"


-- # My Enternia Tool Builder
function build(directory, config, params, level, seed)
  config, params = getPresetParams(config, params)
  config.build = sb.jsonMerge((config.build or {}), (params.build or {}))
  if not config.animationParts then config.animationParts = {item = config.inventoryIcon} end
  if not config.build.price then
    if config.twoHanded then config.build.price = 720 else config.build.price = 480 end
  end
  config = sb.jsonMerge(getItemTypeDefaults('tool'), config)
  config, params = buildItem(directory, config, params, level, seed)

  return config, params
end

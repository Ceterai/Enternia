require "/scripts/util.lua"
require "/items/buildscripts/alta/item.lua"


-- # My Enternia Codex Builder
function build(directory, config, params, level, seed)
  config, params = getPresetParams(config, params)
  config.rarity = nil
  config = sb.jsonMerge(getItemTypeDefaults('codex'), config)
  config, params = buildItem(directory, config, params, level, seed)

  return config, params
end

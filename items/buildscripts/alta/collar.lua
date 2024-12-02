require "/scripts/util.lua"
require "/items/buildscripts/alta/item.lua"


-- # My Enternia Collar Builder
function build(directory, config, params, level, seed)
  config, params = getPresetParams(config, params)
  config = sb.jsonMerge(getItemTypeDefaults('collar'), config)
  config, params = buildItem(directory, config, params, level, seed)

  return config, params
end

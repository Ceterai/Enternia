require "/scripts/util.lua"
require "/items/buildscripts/ct_alta_object_builder.lua"

local ct_alta_object_builder = build

function build(directory, config, parameters, level, seed)
  local configParameter = function(key, default) return getValue(key, default, config, parameters) end

  -- Object stats
  config, parameters = ct_alta_object_builder(directory, config, parameters, level, seed)

  -- Fixed params
  parameters = setTreeParams(inif(config.treePool, sb.jsonMerge(config, rand(config.treePool)), config), parameters)
  if not configParameter("stemName") then
    parameters.stemName = "ct_ayaka_garden_stem"
    parameters.foliageName = parameters.foliageName or "ct_ayaka_garden_leaves"
  end

  -- Icon
  if not config.fixedIcon then
    local icon = config.iconSuffix or "saplingicon.png"
    config.inventoryIcon = jarray()
    table.insert(config.inventoryIcon, {
      image = string.format("%s?hueshift=%s", util.absolutePath(root.treeStemDirectory(parameters.stemName), icon), parameters.stemHueShift or 0)
    })
    if config.middleLayerSuffix then
      table.insert(config.inventoryIcon, {
        image = string.format("%s?hueshift=%s", util.absolutePath(root.treeStemDirectory(parameters.stemName), parameters.stemName .. config.middleLayerSuffix), parameters.stemHueShift or 0)
      })
    end
    if parameters.foliageName then
      table.insert(config.inventoryIcon, {
        image = string.format("%s?hueshift=%s", util.absolutePath(root.treeFoliageDirectory(parameters.foliageName), icon), parameters.foliageHueShift or 0)
      })
    end
  end

  return config, parameters
end

function setTreeParams(config, parameters)
  if config.fixedStem then parameters.stemName = config.fixedStem end
  if config.fixedFoliage then parameters.foliageName = config.fixedFoliage end
  if config.fixedStemHues then parameters.stemHueShift = rand(config.fixedStemHues) end
  if config.fixedFoliageHues then parameters.foliageHueShift = rand(config.fixedFoliageHues) end
  return parameters
end

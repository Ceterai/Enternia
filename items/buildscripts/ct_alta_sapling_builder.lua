require "/scripts/util.lua"
require "/items/buildscripts/ct_alta_object_builder.lua"

local ct_alta_object_builder = build

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then return parameters[keyName]
    elseif config[keyName] ~= nil then return config[keyName]
    else return defaultValue end
  end

  -- Object stats
  config, parameters = ct_alta_object_builder(directory, config, parameters, level, seed)

  -- Fixed params
  if config.treePool then
    setTreeParams(sb.jsonMerge(config, util.randomChoice(config.treePool)), parameters)
  else
    setTreeParams(config, parameters)
  end
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
  if config.fixedStemHues then
    if type(config.fixedStemHues) == "table"
    then parameters.stemHueShift = util.randomChoice(config.fixedStemHues)
    else parameters.stemHueShift = config.fixedStemHues end
  end
  if config.fixedFoliageHues then
    if type(config.fixedFoliageHues) == "table"
    then parameters.foliageHueShift = util.randomChoice(config.fixedFoliageHues)
    else parameters.foliageHueShift = config.fixedFoliageHues end
  end
  return parameters
end

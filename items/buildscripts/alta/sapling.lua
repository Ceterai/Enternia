require "/scripts/util.lua"
require "/items/buildscripts/alta/object.lua"

local ct_alta_object_builder = build


-- # My Enternia Sapling Builder
-- This enhanced sapling builder is based on enhanced object and item builders, and is able to provide an extended amount of functions.
-- Sapling builder is able to handle additional functions like setting stem & foliage type based on direct inputs or from a randomized pool.
-- ## Randomized parts
-- Supports randomized config:
-- - `treePool` (`list`) - a pool of possible stems and foliages. If provided, a random entry from it will be selected and applied to the sapling.
-- - `fixedStem` (`str`) - a stem type to override current one. Can be set through `treePool`.
-- - `fixedFoliage` (`str`) - a foliage type to override current one. Can be set through `treePool`.
-- - `fixedStemHues` (`int`|`list`) - a hue shift (or a list of them). If a list is provided, a random one will be chosen. Can be set through `treePool`.
-- - `fixedStemHues` (`int`|`list`) - a hue shift (or a list of them). If a list is provided, a random one will be chosen. Can be set through `treePool`.
-- ## Procedural Icon
-- The item icon can be set directly or generated based on sapling parts and the icon suffix:
-- - `fixedIcon` (`bool`) - if set to `true`, the original `inventoryIcon` value will be used as the icon;
-- - `iconSuffix` (`str`) - if set and `fixedIcon` is not `true`, will be used instead of a default suffix `saplingicon.png`;
-- - `middleLayerSuffix` (`str`) - if set and `fixedIcon` is not `true`, will add a third layer to the genrated icon.
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

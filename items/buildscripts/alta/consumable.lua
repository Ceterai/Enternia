require "/scripts/util.lua"
require "/items/buildscripts/alta/item.lua"
local ct_alta_item_builder = build
require "/items/buildscripts/buildfood.lua"
local food_build = build


-- # My Enternia Food Builder
-- This enhanced food builder is based on the enhanced item builder, and is able to provide an extended amount of functions. This includes cuisine prefixes,
-- the **Perfect Cooking** mechanic, and even more tooltips. More info: https://github.com/Ceterai/Enternia/wiki/Modding-Items#consumable-items
-- ## Cuisine
-- Can add a prefix to the description denoting what cuisine the item belongs to (https://github.com/Ceterai/Enternia/wiki/Alta#food):
-- - `itemTags` (`list`) - if this list contains any tags listed in the `cuisines` dict in the config file, an according prefix will be added to description.
-- ## Perfect Cooking
-- Supports a chance to turn into a specific preset after cooking. Find out more: https://github.com/Ceterai/Enternia/wiki/Modding-Items#variants
-- - `variants` (`list`) - if set, will go over corresponding presets in the `presets` field after item creation;
-- - `presets` (`dict`) - the dict containing item configurations, check out the **Presets** section in the item builder description.
-- ## Tooltips
-- A big variety of supported tooltip fields, including:
-- - everything from the item builder
-- - food value info (if set - usually not displayed for medicine an other non-food consumables)
-- - effect info (if **Improved Food Descriptions** is installed, else will be replaced with food value)
-- - expiration info
-- > Note that all tooltip text is located in a separate config file.
function build(directory, config, parameters, level, seed)
  local configParameter = function(key, default) return getValue(key, default, config, parameters) end

  config.fixedPrice = config.fixedPrice or true
  config, parameters = ct_alta_item_builder(directory, config, parameters, level, seed)

  local rot_config = configParameter("rotConfig", "/items/generic/food/ct_ionic_rotting.config")
  local timeToRotMax = configParameter("timeToRotMax", config.timeToRot)
  local timeToRot = parameters.timeToRot
  if not timeToRotMax then timeToRotMax = root.assetJson(rot_config..":baseTimeToRot") * configParameter("rottingMultiplier", 1.0) end
  if not timeToRot then timeToRot = timeToRotMax end  -- important to do here to skip similar logic in food_build()

  config.pFoodValue = config.foodValue
  config.foodValue = parameters.foodValue or config.pFoodValue
  config, parameters = food_build(directory, config, parameters, level, seed)

  if level and not configParameter("fixedLevel", true) then parameters.level = level end
  if parameters.price ~= nil then parameters.oPrice = parameters.price; parameters.price = nil end
  if not configParameter("fixedPrice", true) then
    config.price = (parameters.oPrice or configParameter("price", 0)) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))
  end
  parameters.timeToRot = timeToRot
  parameters.timeToRotMax = timeToRotMax

  -- TOOLTIPS --
  local tips = getTextConfig()
  config.tooltipFields.rotTimeLabel = inif(config.itemAgingScripts == nil, "", getRotTimeDescription(timeToRot, rot_config))
  if configParameter("foodValue") == nil then config.tooltipFields.foodAmountLabel = "" end
  -- Effects override (if no Improved Food Descriptions installed)
  if config.tooltipFields.effectLabel == nil and config.tooltipFields.foodAmountLabel ~= "" then
    config.tooltipFields.effectLabel = tips.food.format(configParameter("foodValue", 0))
  end
  -- Tags
  for _, tag in ipairs(config.itemTags) do
    if tips.cuisines[tag] then config.tooltipFields.loreLabel = tips.cuisines[tag]..config.tooltipFields.loreLabel end
  end
  -- Variants
  if config.variants and config.presets and not configParameter("variant", false) then
    local names = {}
    for _, variant in ipairs(config.variants) do
      local name = config.presets[variant].shortdescription
      if name and name ~= configParameter("shortdescription", "") then table.insert(names, name) end
    end
    if #names > 0 then config.tooltipFields.loreLabel = config.tooltipFields.loreLabel.."\n"..tips.perfect..table.concat(names, ", ") end
  end

  return config, parameters
end

function getRotTimeDescription(rotTime, rotConfig)
  if rotTime then
    rotConfig = rotConfig or "/items/generic/food/ct_ionic_rotting.config"
    local descList = root.assetJson(rotConfig .. ":rotTimeDescriptions")
    for i, desc in ipairs(descList) do
      if rotTime <= desc[1] then return desc[2] end
    end
    return descList[#descList]
  end
  return ""
end

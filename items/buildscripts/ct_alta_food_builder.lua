require "/scripts/util.lua"
require "/items/buildscripts/ct_alta_item_builder.lua"
local ct_alta_item_builder = build
require "/items/buildscripts/buildfood.lua"
local food_build = build

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then return parameters[keyName]
    elseif config[keyName] ~= nil then return config[keyName]
    else return defaultValue end
  end

  config.fixedPrice = true
  config, parameters = ct_alta_item_builder(directory, config, parameters, level, seed)

  local rot_config = configParameter("rotConfig", "/items/generic/food/ct_ionic_rotting.config")
  local timeToRotMax = configParameter("timeToRotMax", config.timeToRot)
  local timeToRot = parameters.timeToRot
  if not timeToRotMax then timeToRotMax = root.assetJson(rot_config..":baseTimeToRot") * configParameter("rottingMultiplier", 1.0) end
  if not timeToRot then timeToRot = timeToRotMax end  -- important to do here so it skips similar logic in food_build()

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
  config.tooltipFields.rotTimeLabel = getRotTimeDescription(timeToRot, rot_config)
  config.tooltipFields.levelLabel = util.round(configParameter("level", 1), 1)
  config.tooltipFields.raceLabel = "^gray;" .. string.gsub(" "..configParameter("race", ""), "%W%l", string.upper):sub(2) .. "^reset;"
  if configParameter("foodValue") == nil then config.tooltipFields.foodAmountLabel = "" end

  -- Variants
  if config.variants and config.presets and not configParameter("variant", false) then
    local names = {}
    for _, variant in ipairs(config.variants) do
      local name = config.presets[variant].shortdescription
      if name and name ~= configParameter("shortdescription", "") then table.insert(names, name) end
    end
    if #names > 0 then config.tooltipFields.fullDescriptionLabel = config.tooltipFields.fullDescriptionLabel.."\n^gray;Variants:^reset; "..table.concat(names, ", ") end
  end
  local cuisines = {
    alta_cuisine = "An ^#b0e0fc;alta^reset; cuisine. ",
    calin_cuisine = "^#b0e0fc;Calin alta cuisine^reset;. ",
    nia_cuisine = "^#b0e0fc;Nia alta cuisine^reset;. ",
    runeva_cuisine = "^#b0e0fc;Runeva alta cuisine^reset;. ",
    yava_cuisine = "^#b0e0fc;Yava alta cuisine^reset;. ",
  }
  for _, tag in ipairs(configParameter("itemTags", {})) do
    if cuisines[tag] then config.tooltipFields.fullDescriptionLabel = cuisines[tag]..config.tooltipFields.fullDescriptionLabel end
  end

  if config.tooltipFields.effectLabel == nil and config.tooltipFields.foodAmountLabel ~= "" then
    config.tooltipFields.effectLabel = "Food Value: " .. configParameter("foodValue", 0)
  end
  if config.itemAgingScripts == nil then config.tooltipFields.rotTimeLabel = "" end

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

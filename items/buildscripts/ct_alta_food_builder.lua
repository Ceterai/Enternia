require "/scripts/util.lua"
require "/items/buildscripts/buildfood.lua"

food_build = build

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then return parameters[keyName]
    elseif config[keyName] ~= nil then return config[keyName]
    else return defaultValue end
  end

  local rot_config = configParameter("rotConfig", "/items/generic/food/ct_ionic_rotting.config")
  local timeToRotMax = configParameter("timeToRotMax", config.timeToRot)
  local timeToRot = parameters.timeToRot
  if not timeToRotMax then
    local rottingMultiplier = configParameter("rottingMultiplier", 1.0)
    timeToRotMax = root.assetJson(rot_config .. ":baseTimeToRot") * rottingMultiplier
  end
  if not timeToRot then
    timeToRot = timeToRotMax  -- important to do here so it skips similar logic in food_build()
  end

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
  local full_desc = ""
  if config.variants then
    full_desc = full_desc .. "\n^gray;Variants:^reset; "
    for i, variant in ipairs(config.variants) do
      local name = variant.shortdescription
      if name and name ~= configParameter("shortdescription", {}) then
        if i == 1 then full_desc = full_desc .. name else full_desc = full_desc .. ", " .. name end
      end
    end
    for i, variant in ipairs(config.variants) do
      if variant.shortdescription == configParameter("shortdescription", {}) then full_desc = "" end
    end
  end
  config.tooltipFields.fullDescriptionLabel = configParameter("description", "") .. full_desc

  if config.tooltipFields.effectLabel == nil then
    config.tooltipFields.effectLabel = "Food Value: " .. configParameter("foodValue", 0)
  end

  return config, parameters
end

function getRotTimeDescription(rotTime, rotConfig)
  rotConfig = rotConfig or "/items/generic/food/ct_ionic_rotting.config"
  local descList = root.assetJson(rotConfig .. ":rotTimeDescriptions")
  for i, desc in ipairs(descList) do
    if rotTime <= desc[1] then return desc[2] end
  end
  return descList[#descList]
end

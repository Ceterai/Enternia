require "/scripts/util.lua"
require "/items/buildscripts/alta/item.lua"
require "/items/buildscripts/buildfood.lua"
local buildFoodOld = build
local DEFAULT_ROT_CONFIG = "/items/buildscripts/ct_texts.config"


function build(directory, config, params, level, seed)
  config, params = getPresetParams(config, params)
  config, params = buildItem(directory, config, params, level, seed)
  config, params = buildConsumable(directory, config, params, level, seed)
  return config, params
end


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
-- ## Balance
-- A balancing system is in place to make sure all consumable items are relatively balanced.  
-- The **Alta BGMR2** balancing method can be accessed as `ABGMR2()`.
---@return table, table
function buildConsumable(directory, config, params, level, seed)
  local get = function(key, default) return getValue(key, default, config, params) end

  config = sb.jsonMerge(config, ABGMR2(config.build, get("foodValue")))
  params.timeToRot = config.timeToRot
  config, params = buildFoodOld(directory, config, params, level, seed)

  -- TOOLTIPS --
  local tips = getTextConfig()
  config.tooltipFields.rotTimeLabel = getRotTimeTooltip(params.timeToRot, get("rotConfig"), config.itemAgingScripts)
  config.tooltipFields = getFoodTooltip(config.tooltipFields, get("foodValue"), tips.food)
  config.tooltipFields.loreLabel = config.tooltipFields.loreLabel..
  getVariantTooltip(config.presets, config.variants, get("variant"), tips.perfect)
  for _, tag in ipairs(get("itemTags", {})) do
    if tips.cuisines[tag] then config.tooltipFields.loreLabel = tips.cuisines[tag]..config.tooltipFields.loreLabel end
  end

  return config, params
end


---@return string
function getVariantTooltip(presets, variants, isVariant, prefix)
  if not isVariant and variants and presets then
    local names = {}
    for _, variant in ipairs(variants) do
      local name = presets[variant].shortdescription
      if name then table.insert(names, name) end
    end
    if #names > 0 then return "\n"..prefix..table.concat(names, ", ") end
  end
  return ""
end


---@return string
function getRotTimeTooltip(rotTime, rotConfig, doesAge)
  if doesAge and rotTime then
    local aging = root.assetJson((rotConfig or DEFAULT_ROT_CONFIG) .. ":aging")
    for i, stage in ipairs(aging.stages) do
      if rotTime <= stage[1] then return aging.descriptions[stage[2]] end
    end
    return aging.descriptions[aging.stages[#aging.stages]]
  end
  return ""
end


---@return table
function getFoodTooltip(tooltipFields, foodValue, prefix)
  if foodValue == nil or foodValue == 0 then tooltipFields.foodAmountLabel = ""
  elseif tooltipFields.effectLabel == nil then  -- Effects override (if no Improved Food Descriptions installed)
    tooltipFields.effectLabel = prefix.format(foodValue)
  end
  return tooltipFields
end


-- # Alta Bromatology, Gastronomy & Medicine Regulation M2
-- Alta BGMR2 is a balancing system aimed at making consumable items fair and, well, balanced - at least to some extent.
-- ## Parameters
-- - `build.power` - power value of the item, autoset based on item level but can be overriden;
-- - `build.foodValue` - base food value pre power scaling, empty food value won't affect effect/rotting time;
-- - `build.rotting` - path to a rot config file. To exclude rotting, just set `rotToEffectRatio` to 0 and no rotting logic;
-- - `build.goodEffects` - a `list` of effect IDs that are affected by power, food value, rot coef and bad & mood effects;
-- - `build.badEffects` - a `list` of 5-second negative effect IDs - each increases shared good effect time by 5 seconds;
-- - `build.moodEffects` - a `list` of emotion effect IDs - each mood decreases shared good effect time by 1 second;
-- - `build.rotToEffectRatio` - 1.0 is 50% rot time coef to 50% effect time coef, 3.0 is 75% to 25%.
---@param config table A `build` config object containing necessary base parameters.
---@param overrideValue? number|nil An override `foodValue` - if present, the calculations will be skipped.
---@return { foodValue: number | nil, timeToRot: number, effects: [ { effect: string, duration: number } ] } | { }
function ABGMR2(config, overrideValue)

  if not overrideValue then
    -- Setting defaults
    config.power = config.power or 1.0
    config.foodValue = config.foodValue or nil
    config.goodEffects = config.goodEffects or {}
    config.badEffects = config.badEffects or {}
    config.moodEffects = config.moodEffects or {}
    config.rotToEffectRatio = config.rotToEffectRatio or 1.0

    -- Setting base values
    local baseFoodValue = 10
    local baseEffectTime = 60
    local baseRotTime = 10800
    local baseBadEffectTime = 5
    local baseMoodTime = 30

    local coefEffectTime = 1.0 / (1.0 + config.rotToEffectRatio)
    local coefRotTime = 1.0 - coefEffectTime
    local coefFoodValue = baseFoodValue / (config.foodValue or 1)

    if (not config.goodEffects) or (#config.goodEffects == 0) then
      coefEffectTime = 0.0
      coefRotTime = 1.0 * config.rotToEffectRatio
    end

    local resultFoodValue = (config.foodValue or 0) * config.power
    local resultEffectTime = coefFoodValue * baseEffectTime * (coefEffectTime * 2) * config.power  -- more food = more effect time
    local resultMoodTime = coefFoodValue * baseMoodTime * (coefEffectTime * 2) * config.power  -- more food = more effect time
    local resultRotTime = coefFoodValue * baseRotTime * (coefRotTime * 2)  -- more food = less rot time
    resultEffectTime = resultEffectTime + (#config.badEffects * baseBadEffectTime) - #config.moodEffects  -- scale good effect time from bad & mood
    local result = {
      foodValue = util.round(resultFoodValue, 1) or nil,
      timeToRot = math.floor(resultRotTime),
      effects = {{}},
    }
    for _, effect in ipairs(config.goodEffects) do
      table.insert(result.effects[1], { effect = effect, duration = util.round(resultEffectTime / #config.goodEffects, 2) })
    end
    for _, effect in ipairs(config.badEffects) do
      table.insert(result.effects[1], { effect = effect, duration = util.round(baseBadEffectTime, 2) })
    end
    for _, effect in ipairs(config.moodEffects) do
      table.insert(result.effects[1], { effect = effect, duration = util.round(resultMoodTime / #config.moodEffects, 2) })
    end
    return result
  end
  return {}
end

require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"
require "/items/buildscripts/ct_utils.lua"


function build(directory, config, params, level, seed)
  config, params = getPresetParams(config, params)
  config, params = buildItem(directory, config, params, level, seed)
  return config, params
end


-- # My Enternia Item Builder
-- This enhanced item builder, as well as its derivatives, are able to process and handle a large number of functions,
-- including coloring, presets and tooltips. To learn more, visit this Wiki page: https://github.com/Ceterai/Enternia/wiki/Modding-Items
-- ## Coloring
-- Supported coloring methods:
-- - `paletteSwap` (`dict`) - a set of hex color replacements, supports transparency and `#`: `{"#d0c0a8":"#f6f6f667","a58862":"#d8dcf0"}`
-- - `colorOptions` (`list`, len=12) - currently wearable items only, basic color change parameter from Starbound, works similarly to `paletteSwap`.
-- - `colorIndex` (`int`|`list`) - only if `colorOptions` is set, selects which color option set should be used. Can be used along with `paletteSwap`.
-- ## Presets
-- Presets are used to apply predefined sets of parameters to an item, similar to `upgradeParameters`.
-- Options for presets:
-- - `preset` (`str`) - select a preset if a `presets` field is defined;
-- - `baseAsset` (`str`) - loads data from a JSON asset and uses it as base preset parameters (mainly used by mimic items in `ct_mimics`);
-- - `upgraded` (`bool`) - use upgrade parameters as a preset if `upgradeParameters` field is defined.
-- ## Tooltips
-- A big variety of supported tooltip fields, including:
-- - weapon info (damage/energy/cooldown)
-- - shield info
-- - common info (name, description, price, rarity, image)
-- - extended info (level, species, extended description, where the item can be found, element, handedness)
-- - abilities and upgrades - supports `primaryAbility`, `altAbility`, `passiveAbility` and `upgradeParameters`
-- - usage tooltips (for EPP augments and pet collars)
-- > Note that all tooltip text is located in a separate config file.
function buildItem(directory, config, params, level, seed)
  local get = function(key, default) return getValue(key, default, config, params) end
  local tips = getTextConfig()

  -- BASIC PARAMS --
  config = getDefaults(config, get("category"), get("race"))
  config.build = sb.jsonMerge((config.build or {}), (params.build or {}))
  params.level = getLevel(params.level, level, get("fixedLevel", true))
  level = get("level")
  if not get("fixedPrice", false) then
    local price = get("price") or config.build.price or 0
    config.price = price * root.evalFunction("itemLevelPriceMultiplier", level)
    config.price = config.price + (math.floor((price / 100) + 0.5) * 10 * getBonus(config, params))
  end
  config.build.power = config.build.power or (get("price", 1) / (config.build.price or get("price", 1) or 1))
  config.rarity = getRarity(config, level, tips)
  -- Damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", level)
  -- Elemental type and config
  local elementalType = get("elementalType", "physical")
  replacePatternInData(config, nil, "<elementalType>", elementalType)
  for i, abil_type in ipairs({"primary", "alt"}) do
    setupAbility(config, params, abil_type)
    local a = abil_type .. "Ability"
    if config[a] and config[a].elementalConfig then util.mergeTable(config[a], config[a].elementalConfig[elementalType] or {}) end
  end
  config.radioMessagesOnPickup = getPickupMsgs(get("radioMessagesOnPickup", {}), get("itemTags", {}))


  -- GRAPHICS --

  -- Palette Swaps
  config, params = getColorChanges(
    config, params, directory, params.colorIndex, get("paletteSwap"), get("paletteSwaps"), get("inventoryIcon"), get("colorOptions")
  )
  -- Scripted Animation
  if params.scriptedAnimationParameters ~= nil then config.scriptedAnimationParameters = params.scriptedAnimationParameters end
  -- Offsets
  if config.baseOffset then
    construct(config, "animationCustom", "animatedParts", "parts", "middle", "properties")
    config.animationCustom.animatedParts.parts.middle.properties.offset = config.baseOffset
    if config.muzzleOffset then config.muzzleOffset = vec2.add(config.muzzleOffset, config.baseOffset) end
  end


  -- TOOLTIPS --
  config, params = getTooltips(config, params, level, elementalType, tips, directory)

  return config, params
end


function getPresetParams(config, parameters)
  if parameters.shop then parameters.level = parameters.levelShop end
  if not parameters.cfg and parameters.preset and config.presets then config, parameters = getPreset(config, parameters) end
  if parameters.cfg then config = sb.jsonMerge(config, parameters.cfg) end
  if parameters.upgraded and config.upgradeParameters then config, parameters = getUpgrade(config, parameters) end
  return config, parameters
end


function getPreset(config, parameters)  -- applying a preset from `presets`
  if config.deprecation and config.deprecation[parameters.preset] then parameters.preset = config.deprecation[parameters.preset] end
  if config.presets and config.presets[parameters.preset] ~= nil then
    parameters.cfg = config.presets[parameters.preset]
    if parameters.cfg.baseAsset then parameters.cfg = sb.jsonMerge(getBaseAsset(parameters.cfg.baseAsset) or {}, parameters.cfg or {}) end
  end
  return config, parameters
end


function getBaseAsset(baseAsset)  -- applying asset params as a preset
  local base = root.assetJson(baseAsset)
  nullify(base, {"price", "rarity", "level", "baseAsset", "cfg", "wiki", "itemName", "upgradeParameters", "shortdescription", "tooltipKind"})
  replaceRegexInData(base, baseAsset:gsub('[^/]+$', ''))
  return base
end


function getUpgrade(config, parameters)  -- applying upgrade params as a preset
  config = sb.jsonMerge(config, config.upgradeParameters)
  config.upgradeParameters = nil
  config.level = 6
  return config, parameters
end


function getColorChanges(config, parameters, directory, index, preset_swap, swaps, icon, options)  -- applying color swaps and directives
  if type(parameters.colorIndex) == "table" then parameters.colorIndex = util.randomChoice(parameters.colorIndex) end
  config.colorOptions = getPalette(options, preset_swap, directory)
  if config.colorOptions or preset_swap then
    config.dirs = getDirectivesList(config.colorOptions or {preset_swap,}, index or 0)
    config.paletteSwaps = swaps or getDirectivesString(config.dirs, "")
  end
  if parameters.lastDirs or config.paletteSwaps then
    config.inventoryIcon = getColoredImage(icon, config.paletteSwaps, parameters.lastDirs or {})
  end
  if config.dirs and #config.dirs > 0 then parameters.lastDirs = config.dirs end
  nullify(parameters, {"colorOptions",})
  return config, parameters
end


function getTooltips(config, parameters, level, elementalType, tips, directory)
  local get = function(key, default) return getValue(key, default, config, parameters) end
  config = applyLevelPrefix(config, parameters, level, tips)  -- Apply level-based prefix if appropriate
  config.tooltipFields = config.tooltipFields or {}
  config.tooltipFields.rarityLabel = tips.rarities[level..""]
  config.tooltipFields.levelLabel = level
  config.tooltipFields.levelTitleLabel = tips.level
  config.tooltipFields.armorTitleLabel = tips.armor
  config.tooltipFields.toolLabel = tips.tool
  config.tooltipFields.raceLabel = getColored(getTitle(get('race', '')))
  if get('objectImage') then config.tooltipFields.objectImage = directory..get('objectImage') end
  if elementalType ~= "physical" and elementalType ~= "" then config.tooltipFields.damageKindImage = "/interface/elements/"..elementalType..".png" end

  local lore = get("description", "")  -- Full description constructor in form of a string variable.
  if config.tooltipKind ~= 'ct_alta_item' and config.tooltipKind ~= 'ct_alta_item_long' then
    local abil1 = sb.jsonMerge(config.primaryAbility or config.projectileParameters or {}, parameters.primaryAbility or parameters.projectileParameters or {})
    local dmg = abil1.power or 0
    local dps = (abil1.baseDps or get("baseDps", 0)) * (config.damageLevelMultiplier or 1)
    local rate = (abil1.fireTime or get("fireTime") or get("cooldownTime") or 0.0)
    if dps == 0 and dmg ~= 0 then dps = dmg * rate * (config.damageLevelMultiplier or 1) end
    local eps = (abil1.energyUsage or get("energyUsage", 0))
    local hp = get("baseShieldHealth", 0) * root.evalFunction("shieldLevelMultiplier", level)
    local cd = parameters.cooldownTime or config.cooldownTime or 0
    if hp > 0 and cd > 0 then
      config.tooltipFields.healthTitleLabel = tips.HP
      config.tooltipFields.healthLabel = util.round(hp, 0)
      config.tooltipFields.energyTitleLabel = tips.EPS
      config.tooltipFields.energyLabel = util.round(eps, 1)
      config.tooltipFields.cooldownTitleLabel = tips.CD
      config.tooltipFields.cooldownLabel = parameters.cooldownTime or config.cooldownTime
      config.tooltipFields.knockbackTitleLabel = tips.KB
      config.tooltipFields.knockbackLabel = get("knockback", 0)
      config.tooltipFields.minTimeTitleLabel = tips.MT
      config.tooltipFields.minTimeLabel = get("minActiveTime", 0)
      config.tooltipFields.perfectTimeTitleLabel = tips.PT
      config.tooltipFields.perfectTimeLabel = get("perfectBlockTime", 0)
      -- config.tooltipFields.heavyTitleLabel = tips.HV
      -- config.tooltipFields.heavyLabel = (get("forceWalk", false) and tips.HY or tips.HN)
    elseif dps > 0 or rate > 0 then
      config.tooltipFields.dpsTitleLabel = tips.DPS
      config.tooltipFields.dpsLabel = util.round(dps, 1)
      config.tooltipFields.fireRateTitleLabel = tips.FSR
      config.tooltipFields.fireRateLabel = util.round(1 / (rate or 1.0), 1)
      config.tooltipFields.energyTitleLabel = tips.EPS
      config.tooltipFields.energyLabel = util.round(eps, 1)
      config.tooltipFields.damagePerShotTitleLabel = tips.DPC
      config.tooltipFields.damagePerShotLabel = util.round(dps * (rate or 1.0), 1)
      config.tooltipFields.energyPerShotTitleLabel = tips.EPC
      config.tooltipFields.energyPerShotLabel = util.round(eps * (rate or 1.0), 1)
      config.tooltipFields.damagePerEnergyTitleLabel = tips.DPE
      config.tooltipFields.damagePerEnergyLabel = util.round(dps / eps, 1)
    end

    function getAbil(old, abilType, tooltips)
      local abil = abilType..'Ability'
      local params = get(abil)
      if params ~= nil then
        local name = (params.name or config[abil].name or tooltips.none)
        local desc = (params.description or config[abil].description or '')
        if abilType == 'passive' then abil = 'altAbility' end
        if name then
          config.tooltipFields[abil..'Label'] = name
          config.tooltipFields[abil..'TitleLabel'] = tooltips[abilType].title
          old = appendText(old, getColored(name, 'cyan')..' '..tooltips[abilType].full, '\n\n    ')
        end
        if desc then
          config.tooltipFields[abil..'DescriptionLabel'] = desc
          old = appendText(old, desc, '\n')
        end
      end
      return old
    end

    lore = getAbil(lore, 'primary', tips)  -- Primary Ability
    lore = getAbil(lore, 'alt', tips)      -- Special Ability
    lore = getAbil(lore, 'passive', tips)  -- Passive Ability (currently replaces special in some tootips)
  end

  -- Upgrade
  if config.upgradeParameters and config.upgradeParameters.shortdescription and config.upgradeParameters.shortdescription:len() > 0 then
    local name = config.upgradeParameters.shortdescription
    if name and name ~= get("shortdescription", "") then
      config.tooltipFields.upgradeLabel = name
      config.tooltipFields.upgradeTitleLabel = tips.upgrade
      lore = appendText(lore, tips.upgfull..name, '\n\n    ')
    end
  end

  -- EPP
  if config.category == "eppAugment" then lore = appendText(lore, tips.augment, '\n') end
  if config.category == "petCollar" then lore = appendText(lore, tips.collar, '\n') end
  config.tooltipFields.loreLabel = lore

  -- Tooltip showing where this item can be found
  if get("foundIn") then config.tooltipFields.foundOnLabel = tips.found .. table.concat(get("foundIn"), "^gray;,^reset; ") end

  return config, parameters
end


function getDefaults(config, category, race)
  local defs = getTextConfig('/items/buildscripts/alta/defaults.config')
  config = sb.jsonMerge((defs.species[race or 'default'] or {})[category or 'default'] or {}, config)
  config = sb.jsonMerge(defs.species.default[category or 'default'] or {}, config)
  config = sb.jsonMerge(defs.default, config)
  return config
end


function getLevel(level, gen, fixed) if gen and not fixed then return gen elseif level ~= nil then return math.floor(tonumber(level) or 0) end end


function getRarity(config, level, tips) return config.build.rarity or tips.rarityTypes[tostring(math.floor(level))] end


function getBonus(config, params) return select(2, getValue("shortdescription", "", config, params):gsub("%", "")) end


function applyLevelPrefix(config, params, level, tips)
  local originalLevel = config.level
  local currentLevel = level

  -- Only apply prefix if there's a level difference
  if originalLevel and currentLevel and originalLevel ~= currentLevel then
    local levelDiff = currentLevel - originalLevel

    -- Clamp level difference to [-10, 10]
    if levelDiff < -10 then levelDiff = -10 end
    if levelDiff > 10 then levelDiff = 10 end

    -- Skip if no difference after clamping
    if levelDiff == 0 then return config end

    -- Determine which prefix set to use based on category
    local category = config.category or params.category
    local prefixSet = "default"
    if category == "food" or category == "preparedFood" or category == "drink" then
      prefixSet = "food"
    end

    -- Get the prefix from tips
    local prefix = tips.prefixes and tips.prefixes[prefixSet] and tips.prefixes[prefixSet][tostring(levelDiff)]

    -- Apply prefix to shortdescription if found
    if prefix and config.shortdescription then
      config.shortdescription = prefix .. config.shortdescription
    end
  end

  return config
end

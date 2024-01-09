require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"
require "/items/buildscripts/ct_utils.lua"


function build(directory, config, parameters, level, seed)
  local configParameter = function(key, default) return getValue(key, default, config, parameters) end

  -- CUSTOM PARAMS --
  if parameters.preset and config.presets and config.presets[parameters.preset] then
    parameters = sb.jsonMerge(config.presets[parameters.preset], parameters)
    if parameters.upgradeParameters then config.upgradeParameters = parameters.upgradeParameters end
    if parameters.shortdescription then config.shortdescription = parameters.shortdescription end
    if parameters.price then config.price = parameters.price end
  end
  if parameters.baseAsset then
    if not parameters.cfg then
      local cfg = sb.jsonMerge(root.assetJson(parameters.baseAsset), copy(parameters))
      cfg.tooltipKind = parameters.tooltipKind or config.tooltipKind
      replaceRegexInData(cfg, parameters.baseAsset:gsub('[^/]+$', ''))
      parameters = {baseAsset=parameters.baseAsset, cfg=cfg}
      nullify(parameters.cfg, {"baseAsset", "cfg", "itemName", "wiki", "preset"})
    end
    for k, v in pairs(parameters.cfg) do if v ~= nil then config[k] = v end end
  end

  -- BASIC PARAMS --

  -- Level
  if level and not configParameter("fixedLevel", true) then parameters.level = level end
  level = configParameter("level", 1)
  -- Price
  if not configParameter("fixedPrice", false) then
    if parameters.price ~= nil then parameters.oPrice = parameters.price; parameters.price = nil end
    config.price = (parameters.oPrice or configParameter("price", 0)) * root.evalFunction("itemLevelPriceMultiplier", level)
  end
  -- Damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", level)
  -- Elemental type and config
  local elementalType = configParameter("elementalType", "physical")
  replacePatternInData(config, nil, "<elementalType>", elementalType)
  for i, abil_type in ipairs({"primary", "alt"}) do
    setupAbility(config, parameters, abil_type)
    local a = abil_type .. "Ability"
    if config[a] and config[a].elementalConfig then util.mergeTable(config[a] or {}, config[a].elementalConfig[elementalType] or {}) end
  end
  config.itemTags = getTags(configParameter("itemTags"), configParameter("race"), configParameter("rarity", "common"), elementalType)
  config.radioMessagesOnPickup = getPickupMsgs(configParameter("radioMessagesOnPickup", {}), config.itemTags)


  -- GRAPHICS --

  -- Palette Swaps
  if type(parameters.colorIndex) == "table" then parameters.colorIndex = util.randomChoice(parameters.colorIndex) end
  config.dirs = getDirectivesTable(directory, config.palette, configParameter("colorIndex"), configParameter("paletteSwap"), {})
  config.paletteSwaps = getColorDirectives(config.dirs, "")
  config.inventoryIcon = getColorsIcon(configParameter("inventoryIcon"), config.paletteSwaps, parameters.lastDirs or {})
  config.colorOptions = getColorsArmor(configParameter("colorOptions"), configParameter("paletteSwap"))
  if #config.dirs > 0 then parameters.lastDirs = config.dirs end
  nullify(parameters, {"colorOptions",})
  -- Scripted Animation
  if parameters.scriptedAnimationParameters ~= nil then config.scriptedAnimationParameters = parameters.scriptedAnimationParameters end
  -- Offsets
  if config.baseOffset then
    construct(config, "animationCustom", "animatedParts", "parts", "middle", "properties")
    config.animationCustom.animatedParts.parts.middle.properties.offset = config.baseOffset
    if config.muzzleOffset then config.muzzleOffset = vec2.add(config.muzzleOffset, config.baseOffset) end
  end


  -- TOOLTIPS --
  local tips = getTextConfig()
  config.tooltipFields = config.tooltipFields or {}
  config.tooltipFields.levelLabel = level
  config.tooltipFields.raceLabel = getColored(getTitle(configParameter('race', '')))
  if elementalType ~= "physical" then config.tooltipFields.damageKindImage = "/interface/elements/"..elementalType..".png" end

  local abil1 = sb.jsonMerge(config.primaryAbility or {}, parameters.primaryAbility or {})
  local dps = (abil1.baseDps or configParameter("baseDps", 0)) * (config.damageLevelMultiplier or 1)
  local rate = (abil1.fireTime or configParameter("fireTime", 0.0))
  local eps = (abil1.energyUsage or configParameter("energyUsage", 0))
  if dps > 0 or rate > 0 then
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

  local hp = configParameter("baseShieldHealth", 0) * root.evalFunction("shieldLevelMultiplier", level)
  local cd = parameters.cooldownTime or config.cooldownTime or 0
  if hp > 0 or cd > 0 then
    config.tooltipFields.healthTitleLabel = tips.HP
    config.tooltipFields.healthLabel = util.round(hp, 0)
    config.tooltipFields.energyTitleLabel = tips.EPS
    config.tooltipFields.energyLabel = util.round(eps, 1)
    config.tooltipFields.cooldownTitleLabel = tips.CD
    config.tooltipFields.cooldownLabel = parameters.cooldownTime or config.cooldownTime
    config.tooltipFields.knockbackTitleLabel = tips.KB
    config.tooltipFields.knockbackLabel = configParameter("knockback", 0)
    config.tooltipFields.minTimeTitleLabel = tips.MT
    config.tooltipFields.minTimeLabel = configParameter("minActiveTime", 0)
    config.tooltipFields.perfectTimeTitleLabel = tips.PT
    config.tooltipFields.perfectTimeLabel = configParameter("perfectBlockTime", 0)
    -- config.tooltipFields.heavyTitleLabel = tips.HV
    -- config.tooltipFields.heavyLabel = (configParameter("forceWalk", false) and tips.HY or tips.HN)
  end

  function getAbil(old, abilType, tooltips)
    local abil = abilType..'Ability'
    local params = configParameter(abil)
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

  local lore = configParameter("description", "")  -- Full description constructor in form of a string variable.
  lore = getAbil(lore, 'primary', tips)  -- Primary Ability
  lore = getAbil(lore, 'alt', tips)      -- Special Ability
  lore = getAbil(lore, 'passive', tips)  -- Passive Ability (currently replaces special in some tootips)

  -- Upgrade
  if config.upgradeParameters and config.upgradeParameters.shortdescription and config.upgradeParameters.shortdescription:len() > 0 then
    local name = config.upgradeParameters.shortdescription
    if name and name ~= configParameter("shortdescription", "") then
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
  if configParameter("foundIn") then config.tooltipFields.foundOnLabel = tips.found .. table.concat(configParameter("foundIn"), "^gray;,^reset; ") end

  return config, parameters
end

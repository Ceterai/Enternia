require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then return parameters[keyName]
    elseif config[keyName] ~= nil then return config[keyName]
    else return defaultValue end
  end

  -- BASIC PARAMS --

  -- Level
  if level and not configParameter("fixedLevel", true) then parameters.level = level end
  -- Price
  if parameters.price ~= nil then parameters.oPrice = parameters.price; parameters.price = nil end
  if not configParameter("fixedPrice", false) then
    config.price = (parameters.oPrice or configParameter("price", 0)) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))
  end
  -- Damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))
  -- Elemental type and config
  local elementalType = configParameter("elementalType", "physical")
  replacePatternInData(config, nil, "<elementalType>", elementalType)
  for i, abil_type in ipairs({"primary", "alt"}) do
    setupAbility(config, parameters, abil_type)
    local a = abil_type .. "Ability"
    if config[a] and config[a].elementalConfig then util.mergeTable(config[a] or {}, config[a].elementalConfig[elementalType] or {}) end
  end
  config.itemTags = config.itemTags or {}
  if configParameter("race") then table.insert(config.itemTags, configParameter("race")) end
  table.insert(config.itemTags, configParameter("rarity"))
  if elementalType then table.insert(config.itemTags, elementalType) end


  -- GRAPHICS --

  -- Palette Swaps
  config.paletteSwaps = ""
  if config.palette then
    local palette = root.assetJson(util.absolutePath(directory, config.palette))
    local selectedSwaps = palette.swaps[configParameter("colorIndex", 1)]
    for k, v in pairs(selectedSwaps) do
      config.paletteSwaps = string.format("%s?replace=%s=%s", config.paletteSwaps, k, v)
    end
  end
  if type(config.inventoryIcon) == "string" then
    config.inventoryIcon = config.inventoryIcon .. config.paletteSwaps
  elseif config.inventoryIcon then
    for i, drawable in ipairs(config.inventoryIcon) do
      if drawable.image then drawable.image = drawable.image .. config.paletteSwaps end
    end
  end
  -- Scripted Animation
  if parameters.scriptedAnimationParameters ~= nil then config.scriptedAnimationParameters = parameters.scriptedAnimationParameters end
  -- Offsets
  if config.baseOffset then
    construct(config, "animationCustom", "animatedParts", "parts", "middle", "properties")
    config.animationCustom.animatedParts.parts.middle.properties.offset = config.baseOffset
    if config.muzzleOffset then config.muzzleOffset = vec2.add(config.muzzleOffset, config.baseOffset) end
  end


  -- TOOLTIPS --
  config.tooltipFields = {}
  config.tooltipFields.levelLabel = util.round(configParameter("level", 1), 1)
  config.tooltipFields.raceLabel = "^gray;" .. string.gsub(" "..configParameter("race", ""), "%W%l", string.upper):sub(2) .. "^reset;"
  if elementalType ~= "physical" then config.tooltipFields.damageKindImage = "/interface/elements/"..elementalType..".png" end

  local abil = sb.jsonMerge(config.primaryAbility or {}, parameters.primaryAbility or {})
  local dps = (abil.baseDps or configParameter("baseDps", 0)) * (config.damageLevelMultiplier or 1)
  local rate = (abil.fireTime or configParameter("fireTime", 0.0))
  local eps = (abil.energyUsage or configParameter("energyUsage", 0))
  if dps > 0 or rate > 0 then
    config.tooltipFields.dpsTitleLabel = "^blue;DPS^reset;:"
    config.tooltipFields.dpsLabel = util.round(dps, 1)
    config.tooltipFields.fireRateTitleLabel = "FireRate:"
    config.tooltipFields.fireRateLabel = util.round(1 / (rate or 1.0), 1)
    config.tooltipFields.energyTitleLabel = "^cyan;EPS^reset;:"
    config.tooltipFields.energyLabel = util.round(eps, 1)
    config.tooltipFields.damagePerShotTitleLabel = "^blue;DMG^reset;/Shot:"
    config.tooltipFields.damagePerShotLabel = util.round(dps * (rate or 1.0), 1)
    config.tooltipFields.energyPerShotTitleLabel = "^cyan;ERG^reset;/Shot:"
    config.tooltipFields.energyPerShotLabel = util.round(eps * (rate or 1.0), 1)
    config.tooltipFields.damagePerEnergyTitleLabel = "^blue;DMG^reset;/^cyan;ERG^reset;:"
    config.tooltipFields.damagePerEnergyLabel = util.round(dps / eps, 1)
  end

  local hp = configParameter("baseShieldHealth", 0) * root.evalFunction("shieldLevelMultiplier", configParameter("level", 1))
  local cd = parameters.cooldownTime or config.cooldownTime or 0
  if hp > 0 or cd > 0 then
    config.tooltipFields.healthTitleLabel = "^green;HP^reset;:"
    config.tooltipFields.healthLabel = util.round(hp, 0)
    config.tooltipFields.energyTitleLabel = "^cyan;EPS^reset;:"
    config.tooltipFields.energyLabel = util.round(eps, 1)
    config.tooltipFields.cooldownTitleLabel = "Cooldown:"
    config.tooltipFields.cooldownLabel = parameters.cooldownTime or config.cooldownTime
    config.tooltipFields.knockbackTitleLabel = "Knockback:"
    config.tooltipFields.knockbackLabel = configParameter("knockback", 0)
    config.tooltipFields.minTimeTitleLabel = "Min Time:"
    config.tooltipFields.minTimeLabel = configParameter("minActiveTime", 0)
    config.tooltipFields.perfectTimeTitleLabel = "Parry Time:"
    config.tooltipFields.perfectTimeLabel = configParameter("perfectBlockTime", 0)
    -- config.tooltipFields.heavyTitleLabel = "Heavy:"
    -- config.tooltipFields.heavyLabel = (configParameter("forceWalk", false) and "Yes" or "No")
  end

  -- Primary Ability
  local full_desc = configParameter("description", "")
  if config.primaryAbility or parameters.primaryAbility then
    local abil_params = configParameter("primaryAbility", {})
    local name = (abil_params.name or config.primaryAbility.name or "unknown")
    if name then
      config.tooltipFields.primaryAbilityLabel = name
      config.tooltipFields.primaryAbilityTitleLabel = "^gray;Primary: ^reset;"
      name = "^cyan;" .. name .. "^reset; ^gray;(primary)^reset;"
      if full_desc then full_desc = full_desc .. "\n\n    " .. name else full_desc = name end
    end
    local desc = (abil_params.description or config.primaryAbility.description or "")
    if desc then
      config.tooltipFields.primaryAbilityDescriptionLabel = desc
      if full_desc then full_desc = full_desc .. "\n" .. desc else full_desc = desc end
    end
  end

  -- Special Ability
  if config.altAbility or parameters.altAbility then
    local abil_params = configParameter("altAbility", {})
    local name = (abil_params.name or config.altAbility.name or "unknown")
    if name then
      config.tooltipFields.altAbilityLabel = name
      config.tooltipFields.altAbilityTitleLabel = "^gray;Special: ^reset;"
      name = "^cyan;" .. name .. "^reset; ^gray;(special)^reset;"
      if full_desc then full_desc = full_desc .. "\n\n    " .. name else full_desc = name end
    end
    local desc = (abil_params.description or config.altAbility.description or "")
    if desc then
      config.tooltipFields.altAbilityDescriptionLabel = desc
      if full_desc then full_desc = full_desc .. "\n" .. desc else full_desc = desc end
    end
  end

  -- Passive Ability (replaces special)
  if config.passiveAbility or parameters.passiveAbility then
    local abil_params = configParameter("passiveAbility", {})
    local name = (abil_params.name or config.passiveAbility.name or "unknown")
    if name then
      config.tooltipFields.altAbilityLabel = name
      config.tooltipFields.altAbilityTitleLabel = "^gray;Passive: ^reset;"
      name = "^cyan;" .. name .. "^reset; ^gray;(passive)^reset;"
      if full_desc then full_desc = full_desc .. "\n\n    " .. name else full_desc = name end
    end
    local desc = (abil_params.description or config.passiveAbility.description or "")
    if desc then
      config.tooltipFields.altAbilityDescriptionLabel = desc
      if full_desc then full_desc = full_desc .. "\n" .. desc else full_desc = desc end
    end
  end

  -- Upgrade
  if config.upgradeParameters then
    local name = config.upgradeParameters.shortdescription
    if name and name ~= configParameter("shortdescription", "") then
      config.tooltipFields.upgradeLabel = name
      config.tooltipFields.upgradeTitleLabel = "^gray;Upgrade: ^reset;"
      name = "^gray;Upgraded to: ^reset;" .. name
      if full_desc then full_desc = full_desc .. "\n\n    " .. name else full_desc = "\n\n    " .. name end
    end
  end

  -- EPP
  if config.category == "eppAugment" then
    full_desc = full_desc .. "\n^gray;Equip to EPP with right-click^reset;"
  elseif config.category == "petCollar" then
    full_desc = full_desc .. "\n^gray;Equip to capture pod with right-click^reset;"
  end

  config.tooltipFields.fullDescriptionLabel = full_desc
  if configParameter("foundOn") then config.tooltipFields.foundOnLabel = "^gray;Found in:^reset; " .. table.concat(configParameter("foundOn"), "^gray;,^reset; ") end

  return config, parameters
end

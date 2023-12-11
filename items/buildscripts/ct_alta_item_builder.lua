require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"

function replaceRegexInData(data, replacevalue)
  if type(data) == "table" then
    for k, v in pairs(data) do
      if (type(v) == "string" and v:len() > 4 and (v:find('.png') or v:find('.animation')) and v:sub(1, 1) ~= '/') then
        data[k] = replacevalue..v  -- sb.logInfo("\nReplacing value %s of key %s with value %s\n", v, k, data[k])
      else replaceRegexInData(v, replacevalue) end
    end
  end
end

function getSortedUnique(list)
  local hash = {}
  local res = {}
  for _,v in ipairs(list or {}) do if (not hash[v]) and v then res[#res+1] = v; hash[v] = true end end
  table.sort(res)
  return res
end

function getTags(tagList, race, rarity, element)
  for _,v in ipairs({race, rarity, element}) do table.insert(tagList, v:lower()) end
  return getSortedUnique(tagList)
end

function getPickupMsgs(msgList, tagList)
  for _,v in ipairs(tagList) do
    if v == 'gsr' then table.insert(msgList, 'ct_gsr_msg') end
    if v == 'set' then table.insert(msgList, 'ct_set_msg') end
    if v == 'loot' then table.insert(msgList, 'ct_loot_crate_msg') end
    if v == 'datamass' then table.insert(msgList, 'ct_datamass_msg') end
    if v == 'faradea' then table.insert(msgList, 'ct_faradea_msg') end
    if v == 'haven' then table.insert(msgList, 'ct_haven_msg') end
    if v == 'warped' then table.insert(msgList, 'ct_warped_msg') end
    if v == 'eds' then table.insert(msgList, 'ct_eds_msg') end
    if v == 'shield' then table.insert(msgList, 'ct_alta_shield_msg') end
    if v == 'weapon' then table.insert(msgList, 'ct_alta_weapon_msg') end
    if v == 'energy_shielder' then table.insert(msgList, 'ct_energy_shielder_msg') end
    if v == 'drone' or v == 'droid' then table.insert(msgList, 'ct_robot_spawner_msg') end
  end
  if #msgList > 0 then return getSortedUnique(msgList) end
end

function getColorDirectives(dirT, dirs)
  for _, v in ipairs(dirT) do dirs = string.format("%s%s", dirs, v) end
  return dirs
end

function getDirectivesTable(dir, palette, option, swaps, dirs)
  swaps = copy(swaps or {})
  if palette then for k, v in pairs(root.assetJson(util.absolutePath(dir, palette)).swaps[option or 1]) do swaps[k] = v end end
  for k, v in pairs(swaps) do table.insert(dirs, string.format("?replace=%s=%s", k:gsub('#', ''), v:gsub('#', ''))) end
  return dirs
end

function getCleanImage(img, swaps)
  for _, swap in ipairs(swaps) do img = img:gsub(swap, '') end
  return img
end

function getColorsIcon(icon, dirs, oldSwaps)
  if type(icon) == "string" then icon = getCleanImage(icon, oldSwaps)..dirs
  elseif icon then for i, drawable in ipairs(icon) do if drawable.image then drawable.image = getCleanImage(drawable.image, oldSwaps)..dirs end end end
  return icon
end

function getColorsArmor(options, swaps)
  if options and swaps then for i, _ in ipairs(options) do for key, swap in pairs(swaps) do options[i][key:gsub('#', '')] = swap:gsub('#', '') end end end
  return options
end

function nullify(data, keys) for _, key in ipairs(keys) do if data[key] then data[key] = nil end end end

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then return parameters[keyName]
    elseif config[keyName] ~= nil then return config[keyName]
    else return defaultValue end
  end

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
  config.itemTags = getTags(configParameter("itemTags", {}), configParameter("race"), configParameter("rarity", "common"), elementalType)
  config.radioMessagesOnPickup = getPickupMsgs(configParameter("radioMessagesOnPickup", {}), config.itemTags)


  -- GRAPHICS --

  -- Palette Swaps
  if type(parameters.colorIndex) == "table" then parameters.colorIndex = util.randomChoice(parameters.colorIndex) end
  config.dirs = getDirectivesTable(directory, config.palette, configParameter("colorIndex"), configParameter("paletteSwap"), {})
  config.paletteSwaps = getColorDirectives(config.dirs, "")
  config.inventoryIcon = getColorsIcon(configParameter("inventoryIcon"), config.paletteSwaps, parameters.lastDirs or {})
  config.colorOptions = getColorsArmor(configParameter("colorOptions"), configParameter("paletteSwap"))
  if #config.dirs > 0 then parameters.lastDirs = config.dirs end
  nullify(parameters, {"inventoryIcon","colorOptions",})
  -- Scripted Animation
  if parameters.scriptedAnimationParameters ~= nil then config.scriptedAnimationParameters = parameters.scriptedAnimationParameters end
  -- Offsets
  if config.baseOffset then
    construct(config, "animationCustom", "animatedParts", "parts", "middle", "properties")
    config.animationCustom.animatedParts.parts.middle.properties.offset = config.baseOffset
    if config.muzzleOffset then config.muzzleOffset = vec2.add(config.muzzleOffset, config.baseOffset) end
  end


  -- TOOLTIPS --
  config.tooltipFields = config.tooltipFields or {}
  config.tooltipFields.levelLabel = level
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

  local hp = configParameter("baseShieldHealth", 0) * root.evalFunction("shieldLevelMultiplier", level)
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
  if config.upgradeParameters and config.upgradeParameters.shortdescription and config.upgradeParameters.shortdescription:len() > 0 then
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
  if configParameter("foundIn") then config.tooltipFields.foundOnLabel = "^gray;Found in:^reset; " .. table.concat(configParameter("foundIn"), "^gray;,^reset; ") end

  return config, parameters
end

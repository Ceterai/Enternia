require "/scripts/util.lua"
require "/items/buildscripts/alta/item.lua"

local ct_alta_item_builder = build


-- # My Enternia Object Builder
-- This enhanced object builder is based on the enhanced item builder, and is able to provide an extended amount of functions.
-- This includes extended tenant tags, as well as even more tooltips. Find out more: https://github.com/Ceterai/Enternia/wiki/Modding-Items#objects
-- ## Tooltips
-- A big variety of supported tooltip fields, including:
-- - everything from the item builder
-- - damage info (for hazardous objects and traps)
-- - health info
-- - light color/intensity info
-- - slot count info (for storage items)
-- - drop info (whether the object drops itself when broken)
-- > Note that all tooltip text is located in a separate config file.
function build(directory, config, parameters, level, seed)
  local configParameter = function(key, default) return getValue(key, default, config, parameters) end

  -- Item stats
  config, parameters = ct_alta_item_builder(directory, config, parameters, level, seed)
  if config.paletteSwaps then parameters.color = "default"..config.paletteSwaps end
  if parameters.cfg and config.itemName == 'ct_obj_mimic' then parameters = sb.jsonMerge(parameters, parameters.cfg) end
  if parameters.deprecated then parameters.colonyTags = nil end
  config.colonyTags = getTags(configParameter("colonyTags"), configParameter("race"), configParameter("rarity", "common"), configParameter("elementalType"))
  if parameters.colonyTags and parameters.colonyTags ~= config.colonyTags then parameters.colonyTags = config.colonyTags end
  config.radioMessagesOnPickup = getPickupMsgs(configParameter("radioMessagesOnPickup", {}), config.colonyTags)
  local tips = getTextConfig()

  -- Basic stats (Health, Tags, Slots, Drop Warning)
  if config.tooltipKind == 'object' then config.tooltipKind = 'ct_alta_object' end
  config.printable = config.printable or false
  if configParameter("smashOnBreak", false) or configParameter("smashable", false) then
    config.tooltipFields.smashLabel = tips.breaks
  end
  if configParameter("slotCount") ~= nil and configParameter("slotCount") > 0 then
    config.tooltipFields.slotCountLabel = string.format(tips.store, configParameter("slotCount"))
  end
  local light = configParameter("lightColor")
  if light ~= nil then
    for i = 1, #light do light[i] = string.format("%02s", string.format("%x", light[i])) end
    config.tooltipFields.lightTitleLabel = tips.light
    config.tooltipFields.lightLabel = "^#"..table.concat(light)..";^reset;"
  end
  config.tooltipFields.tagsTitleLabel = tips.tags
  config.tooltipFields.tagsLabel = getColored(table.concat(configParameter("colonyTags"), ", "))
  config.tooltipFields.healthTitleLabel = tips.health
  config.tooltipFields.healthLabel = configParameter("health", 1) * 10

  -- Damage (Traps, Turrets, Mines, Hazards)
  local abil = sb.jsonMerge(config.touchDamage or config.barrierDamage or {}, parameters.touchDamage or {})
  local dmg = abil.damage or abil.baseDamage or abil.power or configParameter("baseDamage") or configParameter("damage") or configParameter("power")
  local rate = (abil.fireTime or configParameter("fireTime"))
  local eps = (abil.energyUsage or configParameter("energyUsage"))
  local kb = (abil.knockback or configParameter("knockback"))
  if dmg ~= nil and dmg > 0 then
    dmg = dmg * (config.damageLevelMultiplier or 1)
    config.tooltipFields.damagePerShotTitleLabel = tips.DPC
    config.tooltipFields.damagePerShotLabel = util.round(dmg, 1)
    if rate ~= nil then
      local dps = dmg / rate
      config.tooltipFields.dpsTitleLabel = tips.DPS
      config.tooltipFields.dpsLabel = util.round(dps, 1)
      config.tooltipFields.fireRateTitleLabel = tips.FSR
      config.tooltipFields.fireRateLabel = util.round(1 / rate, 1)
      if eps ~= nil then
        config.tooltipFields.energyPerShotTitleLabel = tips.EPC
        config.tooltipFields.energyPerShotLabel = util.round(eps * (rate or 1.0), 1)
        config.tooltipFields.damagePerEnergyTitleLabel = tips.DPE
        config.tooltipFields.damagePerEnergyLabel = util.round(dps / eps, 1)
      end
    end
    if eps ~= nil then
      config.tooltipFields.energyTitleLabel = tips.EPS
      config.tooltipFields.energyLabel = util.round(eps, 1)
    end
    if kb ~= nil then
      config.tooltipFields.knockbackTitleLabel = tips.KB
      config.tooltipFields.knockbackLabel = kb
    end
  end
  if not parameters.colonyTags and not parameters.deprecated then parameters.colonyTags = config.colonyTags end
  if parameters.deprecated then parameters.deprecated = nil end
  return config, parameters
end
